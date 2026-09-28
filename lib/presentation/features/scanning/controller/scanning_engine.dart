import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/tts_service.dart';
import '../../../../domain/models/aac_board.dart';
import '../../../../domain/models/scanning_settings.dart';

/// Resultado del estado actual del cursor de barrido
class ScanCursorState {
  /// -1 indica barrido de fila completa activo; >=0 indica índice de columna activa
  final int rowIndex;
  final int colIndex; // -1 = fila entera seleccionada, >= 0 = columna específica
  final bool isRowPhase; // true = barrido en filas, false = barrido en columnas de la fila elegida
  final bool isPaused;

  const ScanCursorState({
    this.rowIndex = 0,
    this.colIndex = -1,
    this.isRowPhase = true,
    this.isPaused = false,
  });

  ScanCursorState copyWith({
    int? rowIndex,
    int? colIndex,
    bool? isRowPhase,
    bool? isPaused,
  }) {
    return ScanCursorState(
      rowIndex: rowIndex ?? this.rowIndex,
      colIndex: colIndex ?? this.colIndex,
      isRowPhase: isRowPhase ?? this.isRowPhase,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  /// Verifica si un botón en (row, col) está resaltado por el barrido
  bool isHighlighted(int row, int col) {
    if (isPaused) return false;
    if (isRowPhase) {
      return row == rowIndex; // Resalta toda la fila
    } else {
      return row == rowIndex && col == colIndex; // Resalta la celda específica
    }
  }

  /// Verifica si una fila entera está resaltada (fase de fila)
  bool isRowHighlighted(int row) {
    return isRowPhase && row == rowIndex && !isPaused;
  }
}

typedef OnScanSelect = void Function(int row, int col);

class ScanningEngine extends ChangeNotifier {
  ScanningSettings _settings;
  AACBoard? _board;
  OnScanSelect? _onSelect;
  final TTSService? _ttsService;
  final AudioPlayer _audioPlayer;

  ScanCursorState _cursor = const ScanCursorState();
  Timer? _autoTimer;
  int _loopCount = 0;

  ScanningEngine({
    required ScanningSettings settings,
    TTSService? ttsService,
    AudioPlayer? audioPlayer,
  })  : _settings = settings,
        _ttsService = ttsService,
        _audioPlayer = audioPlayer ?? AudioPlayer() {
    _initAudio();
  }

  void _initAudio() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  ScanCursorState get cursor => _cursor;
  bool get isActive => _settings.enabled && _board != null;

  void configure({
    required ScanningSettings settings,
    required AACBoard board,
    required OnScanSelect onSelect,
  }) {
    final boardChanged = _board?.id != board.id;
    final settingsChanged = _settings != settings;
    _settings = settings;
    _board = board;
    _onSelect = onSelect;

    if (settings.enabled) {
      if (boardChanged || settingsChanged || _autoTimer == null) {
        _resetCursor(triggerFeedback: true);
        _startAutoScanIfNeeded();
      }
    } else {
      _stopTimer();
      _cursor = const ScanCursorState(isPaused: true);
      notifyListeners();
    }
  }

  void updateSettings(ScanningSettings settings) {
    final wasEnabled = _settings.enabled;
    _settings = settings;

    if (settings.enabled && _board != null) {
      if (!wasEnabled || _autoTimer == null) {
        _resetCursor(triggerFeedback: true);
        _startAutoScanIfNeeded();
      }
    } else if (!settings.enabled) {
      _stopTimer();
      _cursor = const ScanCursorState(isPaused: true);
      notifyListeners();
    }
  }

  void updateBoard(AACBoard board) {
    final boardChanged = _board?.id != board.id;
    _board = board;
    if (_settings.enabled && boardChanged) {
      _resetCursor(triggerFeedback: true);
      _startAutoScanIfNeeded();
    }
  }

  // ----- FEEDBACK ACÚSTICO Y AUDITIVO -----

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('sounds/scan_beep.wav'),
        mode: PlayerMode.lowLatency,
        volume: 0.6,
      );
    } catch (_) {
      // Ignorar fallas de audio en entornos sin backend de audio
    }
  }

  void _playAuditoryCue() {
    final board = _board;
    if (board == null) return;

    if (_cursor.isRowPhase) {
      _ttsService?.speakCue('Fila ${_cursor.rowIndex + 1}');
    } else {
      final button = board.getButtonAt(_cursor.rowIndex, _cursor.colIndex);
      if (button != null && button.label.trim().isNotEmpty) {
        _ttsService?.speakCue(button.label);
      }
    }
  }

  void _triggerFeedback() {
    if (!_settings.enabled || _cursor.isPaused) return;

    if (_settings.enableAcousticBeep) {
      _playBeep();
    }
    if (_settings.enableAuditoryCue) {
      _playAuditoryCue();
    }
  }

  // ----- ENTRADA DE USUARIO (Switch 1: Avanzar / Seleccionar) -----

  /// Llamado cuando el usuario pulsa el conmutador de acción / toca la pantalla
  void onSwitchActivate() {
    if (!isActive) return;

    switch (_settings.mode) {
      case ScanningMode.autoScan:
        _handleAutoScanSelect();
        break;
      case ScanningMode.stepScan:
        // En modo paso, switch 1 avanza
        _advanceCursor();
        break;
      case ScanningMode.inverseScan:
        _handleAutoScanSelect();
        break;
    }
  }

  /// Llamado cuando el usuario pulsa el conmutador 2 (solo en stepScan)
  void onSwitch2Activate() {
    if (!isActive) return;
    if (_settings.mode == ScanningMode.stepScan) {
      _handleAutoScanSelect();
    }
  }

  // ----- LÓGICA INTERNA -----

  void _handleAutoScanSelect() {
    final board = _board;
    if (board == null) return;

    if (_settings.pattern == ScanningPattern.rowColumn) {
      if (_cursor.isRowPhase) {
        // Confirmar fila → entrar en barrido de columnas
        _stopTimer();
        _loopCount = 0;
        _cursor = _cursor.copyWith(colIndex: 0, isRowPhase: false);
        notifyListeners();
        _triggerFeedback();
        _startAutoScanIfNeeded();
      } else {
        // Confirmar columna → seleccionar el botón
        _stopTimer();
        _onSelect?.call(_cursor.rowIndex, _cursor.colIndex);
        Future.delayed(const Duration(milliseconds: 300), () {
          _resetCursor(triggerFeedback: true);
          _startAutoScanIfNeeded();
        });
      }
    } else {
      // Patrón lineal: seleccionar directamente
      final col = _cursor.colIndex >= 0 ? _cursor.colIndex : 0;
      _stopTimer();
      _onSelect?.call(_cursor.rowIndex, col);
      Future.delayed(const Duration(milliseconds: 300), () {
        _resetCursor(triggerFeedback: true);
        _startAutoScanIfNeeded();
      });
    }
  }

  void _advanceCursor() {
    final board = _board;
    if (board == null) return;

    if (_settings.pattern == ScanningPattern.rowColumn) {
      if (_cursor.isRowPhase) {
        final nextRow = (_cursor.rowIndex + 1) % board.rows;
        _cursor = _cursor.copyWith(rowIndex: nextRow);
      } else {
        final nextCol = (_cursor.colIndex + 1) % board.columns;
        _cursor = _cursor.copyWith(colIndex: nextCol);
      }
    } else {
      // Patrón lineal
      final totalCells = board.rows * board.columns;
      final currentCell = _cursor.rowIndex * board.columns + _cursor.colIndex.clamp(0, board.columns - 1);
      final nextCell = (currentCell + 1) % totalCells;
      _cursor = _cursor.copyWith(
        rowIndex: nextCell ~/ board.columns,
        colIndex: nextCell % board.columns,
        isRowPhase: false,
      );
    }
    notifyListeners();
    _triggerFeedback();
  }

  void _startAutoScanIfNeeded() {
    if (_settings.mode == ScanningMode.stepScan) return; // Step scan no usa timer
    _stopTimer();

    final duration = Duration(
      milliseconds: (_settings.scanSpeedSeconds * 1000).round(),
    );

    _autoTimer = Timer.periodic(duration, (timer) {
      final board = _board;
      if (board == null || !_settings.enabled) {
        timer.cancel();
        return;
      }

      // Verificar loops completados
      if (_settings.pattern == ScanningPattern.rowColumn && _cursor.isRowPhase) {
        if (_cursor.rowIndex == 0 && _loopCount > 0) {
          if (_loopCount >= _settings.maxLoops) {
            _stopTimer();
            _cursor = _cursor.copyWith(isPaused: true);
            notifyListeners();
            return;
          }
          _loopCount++;
        }
        if (_cursor.rowIndex == 0) _loopCount = (_loopCount == 0) ? 1 : _loopCount;
      }

      _advanceCursor();
    });
  }

  void _resetCursor({bool triggerFeedback = false}) {
    _loopCount = 0;
    final useRowPhase = _settings.pattern == ScanningPattern.rowColumn;
    _cursor = ScanCursorState(
      rowIndex: 0,
      colIndex: useRowPhase ? -1 : 0,
      isRowPhase: useRowPhase,
      isPaused: false,
    );
    notifyListeners();
    if (triggerFeedback) {
      _triggerFeedback();
    }
  }

  void _stopTimer() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// ----- WIDGET RECEPTOR DE EVENTOS DE TECLADO Y GESTOS -----

class ScanningInputHandler extends StatefulWidget {
  final ScanningEngine engine;
  final ScanningSettings settings;
  final Widget child;

  const ScanningInputHandler({
    super.key,
    required this.engine,
    required this.settings,
    required this.child,
  });

  @override
  State<ScanningInputHandler> createState() => _ScanningInputHandlerState();
}

class _ScanningInputHandlerState extends State<ScanningInputHandler> {
  @override
  Widget build(BuildContext context) {
    if (!widget.settings.enabled) return widget.child;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        // Teclas para Switch 1 (Avanzar / Seleccionar en autoScan)
        if (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          widget.engine.onSwitchActivate();
        }

        // Teclas para Switch 2 (Seleccionar en stepScan)
        if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          widget.engine.onSwitch2Activate();
        }
      },
      child: widget.settings.screenAsSwitch
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.engine.onSwitchActivate,
              child: widget.child,
            )
          : widget.child,
    );
  }
}
