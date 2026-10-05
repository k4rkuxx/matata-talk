import '../../head_pointer/bloc/head_pointer_bloc.dart';
import '../../head_pointer/controller/head_pointer_controller.dart';
import '../../head_pointer/widgets/head_pointer_overlay.dart';
import '../../head_pointer/widgets/head_pointer_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../../domain/models/button_action.dart';
import '../../../../domain/models/part_of_speech.dart';

import '../../../../data/services/tts_service.dart';
import '../../../../domain/services/pathfinder_service.dart';
import '../../grammar_popup/widgets/morphology_popup_dialog.dart';
import '../../grid/bloc/grid_bloc.dart';
import '../../grid/widgets/motor_grid_view.dart';
import '../../message_bar/bloc/message_bar_bloc.dart';
import '../../message_bar/widgets/message_bar_view.dart';
import '../../phrases/bloc/phrases_bloc.dart';
import '../../phrases/widgets/quick_phrases_dialog.dart';
import '../../scanning/bloc/scanning_bloc.dart';
import '../../scanning/controller/scanning_engine.dart';
import '../../scanning/widgets/scanning_settings_dialog.dart';
import '../../settings/widgets/touch_accessibility_dialog.dart';
import '../../settings/widgets/open_board_dialog.dart';
import '../../word_finder/widgets/word_finder_dialog.dart';

class CommunicatorScreen extends StatefulWidget {
  const CommunicatorScreen({super.key});

  @override
  State<CommunicatorScreen> createState() => _CommunicatorScreenState();
}

class _CommunicatorScreenState extends State<CommunicatorScreen> {
  List<WordPathStep>? _activePathSteps;
  int _currentStepIndex = 0;

  late final ScanningEngine _scanEngine;
  late final HeadPointerController _headPointerController;
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final initialSettings = context.read<ScanningBloc>().state.settings;
    final ttsService = context.read<TTSService>();
    _scanEngine = ScanningEngine(
      settings: initialSettings,
      ttsService: ttsService,
    );

    final initialHpSettings = context.read<HeadPointerBloc>().state.settings;
    _headPointerController = HeadPointerController(
      settings: initialHpSettings,
      onPointerClick: (normalizedPos) => _handleHeadPointerClick(normalizedPos),
    );
    if (initialHpSettings.enabled) {
      _headPointerController.initialize();
    }
  }

  @override
  void dispose() {
    _scanEngine.dispose();
    _headPointerController.dispose();
    super.dispose();
  }

  void _handleButtonTap(BuildContext context, AACButton button) {
    // Si estamos en modo guía (Pathfinder), avanzar al siguiente paso
    if (_activePathSteps != null && _activePathSteps!.isNotEmpty) {
      final expectedStep = _activePathSteps![_currentStepIndex];
      if (button.id == expectedStep.targetButton.id) {
        _currentStepIndex++;
        if (_currentStepIndex < _activePathSteps!.length) {
          final nextStep = _activePathSteps![_currentStepIndex];
          context.read<GridBloc>().add(SetHighlightButtonId(nextStep.targetButton.id));
        } else {
          _clearPathfinder(context);
        }
      }
    }

    switch (button.actionType) {
      case ButtonActionType.speakAndAddToMessage:
        context.read<MessageBarBloc>().add(AddButtonToMessage(button));
        break;
      case ButtonActionType.navigateToBoard:
        if (button.targetBoardId != null) {
          context.read<GridBloc>().add(LoadBoard(button.targetBoardId!));
        }
        break;
      case ButtonActionType.backToHome:
        context.read<GridBloc>().add(NavigateHome());
        break;
      case ButtonActionType.clearMessage:
        context.read<MessageBarBloc>().add(ClearAllTokens());
        break;
      case ButtonActionType.deleteLastToken:
        context.read<MessageBarBloc>().add(RemoveLastToken());
        break;
      case ButtonActionType.grammarPopup:
        _handleButtonLongPress(context, button);
        break;
    }
  }

  void _startPathfinderGuide(WordPathResult result) {
    setState(() {
      _activePathSteps = result.steps;
      _currentStepIndex = 0;
    });

    context.read<GridBloc>().add(NavigateHome());
    final firstStep = result.steps[0];
    context.read<GridBloc>().add(SetHighlightButtonId(firstStep.targetButton.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ruta: ${result.pathDescription}'),
        backgroundColor: const Color(0xFF1976D2),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _clearPathfinder(BuildContext context) {
    setState(() {
      _activePathSteps = null;
      _currentStepIndex = 0;
    });
    context.read<GridBloc>().add(const SetHighlightButtonId(null));
  }

  void _handleButtonLongPress(BuildContext context, AACButton button) {
    if (button.isFolder) return;

    if (button.partOfSpeech == PartOfSpeech.verb ||
        button.partOfSpeech == PartOfSpeech.noun ||
        button.partOfSpeech == PartOfSpeech.adjective) {
      showDialog(
        context: context,
        builder: (dialogContext) => MorphologyPopupDialog(
          button: button,
          onSelectInflection: (inflectedButton) {
            context.read<MessageBarBloc>().add(AddButtonToMessage(inflectedButton));
          },
        ),
      );
    }
  }


  void _handleHeadPointerClick(Offset normalizedPos) {
    final gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox == null || !gridBox.hasSize) return;

    final mediaQuery = MediaQuery.of(context);
    final globalPos = Offset(
      normalizedPos.dx * mediaQuery.size.width,
      normalizedPos.dy * mediaQuery.size.height,
    );

    final localPos = gridBox.globalToLocal(globalPos);
    if (localPos.dx >= 0 &&
        localPos.dx <= gridBox.size.width &&
        localPos.dy >= 0 &&
        localPos.dy <= gridBox.size.height) {
      final currentBoard = context.read<GridBloc>().state.currentBoard;
      final cellWidth = gridBox.size.width / currentBoard.columns;
      final cellHeight = gridBox.size.height / currentBoard.rows;

      final col = (localPos.dx / cellWidth).floor().clamp(0, currentBoard.columns - 1);
      final row = (localPos.dy / cellHeight).floor().clamp(0, currentBoard.rows - 1);

      final button = currentBoard.getButtonAt(row, col);
      if (button != null) {
        _handleButtonTap(context, button);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ScanningBloc, ScanningState>(
          listener: (context, scanState) {
            _scanEngine.updateSettings(scanState.settings);
          },
        ),
        BlocListener<HeadPointerBloc, HeadPointerState>(
          listener: (context, hpState) {
            _headPointerController.updateSettings(hpState.settings);
          },
        ),
        BlocListener<MessageBarBloc, MessageBarState>(
          listenWhen: (previous, current) =>
              !previous.isSpeaking && current.isSpeaking && current.tokens.isNotEmpty,
          listener: (context, state) {
            context.read<PhrasesBloc>().add(RecordSpokenPhrase(state.fullText));
          },
        ),
      ],
      child: Scaffold(
          backgroundColor: const Color(0xFFECEFF1),
          appBar: AppBar(
            titleSpacing: 16,
            title: BlocBuilder<GridBloc, GridState>(
              builder: (context, state) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Flexible(
                      child: Text(
                        'MatataTalk',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text(
                          state.currentBoard.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: Color(0xFF1565C0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              // Botón de Frases Rápidas e Historial
              IconButton(
                icon: const Icon(Icons.forum_outlined, size: 22),
                tooltip: 'Frases Rápidas e Historial',
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dContext) => QuickPhrasesDialog(
                      ttsService: context.read<MessageBarBloc>().ttsService,
                    ),
                  );
                },
              ),
              // Botón del Buscador Guiado
              IconButton(
                icon: const Icon(Icons.search, size: 22),
                tooltip: 'Buscar pictograma',
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dContext) => WordFinderDialog(
                      onSelectWordPath: (pathResult) => _startPathfinderGuide(pathResult),
                    ),
                  );
                },
              ),
              // Menú Unificado de Métodos de Acceso & Accesibilidad
              BlocBuilder<ScanningBloc, ScanningState>(
                builder: (context, scanState) {
                  return BlocBuilder<HeadPointerBloc, HeadPointerState>(
                    builder: (context, hpState) {
                      final isScanActive = scanState.settings.enabled;
                      final isHpActive = hpState.settings.enabled;
                      final isAnyActive = isScanActive || isHpActive;

                      return PopupMenuButton<String>(
                        tooltip: 'Métodos de Acceso y Accesibilidad',
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.accessibility_new,
                              size: 24,
                              color: isAnyActive ? const Color(0xFF00C853) : null,
                            ),
                            if (isAnyActive)
                              Positioned(
                                top: -1,
                                right: -1,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00C853),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onSelected: (value) {
                          if (value == 'scanning') {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => BlocProvider.value(
                                value: context.read<ScanningBloc>(),
                                child: const ScanningSettingsDialog(),
                              ),
                            );
                          } else if (value == 'head_pointer') {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => BlocProvider.value(
                                value: context.read<HeadPointerBloc>(),
                                child: HeadPointerSettingsDialog(controller: _headPointerController),
                              ),
                            );
                          } else if (value == 'touch') {
                            showDialog(
                              context: context,
                              builder: (dContext) => const TouchAccessibilityDialog(),
                            );
                          } else if (value == 'open_board') {
                            showDialog(
                              context: context,
                              builder: (dContext) => BlocBuilder<GridBloc, GridState>(
                                builder: (ctx, gState) => OpenBoardDialog(
                                  currentBoard: gState.currentBoard,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'scanning',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings_input_component,
                                  color: isScanActive ? const Color(0xFFFF8F00) : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text('Barrido por Conmutadores', style: TextStyle(fontSize: 13)),
                                ),
                                if (isScanActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'ACTIVO',
                                      style: TextStyle(color: Color(0xFFFF8F00), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'head_pointer',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.face_retouching_natural,
                                  color: isHpActive ? const Color(0xFF00C853) : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text('Puntero Cefálico (Head Tracking)', style: TextStyle(fontSize: 13)),
                                ),
                                if (isHpActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'ACTIVO',
                                      style: TextStyle(color: Color(0xFF00C853), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'touch',
                            child: Row(
                              children: [
                                Icon(Icons.touch_app_outlined, color: Color(0xFF1976D2), size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text('Filtros Táctiles (Hold/Debounce)', style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'open_board',
                            child: Row(
                              children: [
                                Icon(Icons.sync_alt, color: Color(0xFF1565C0), size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text('Importar / Exportar (OBF/OBZ)', style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // Botón de Inicio
              IconButton(
                icon: const Icon(Icons.home_outlined, size: 22),
                tooltip: 'Ir a Inicio',
                padding: const EdgeInsets.only(left: 4, right: 8),
                constraints: const BoxConstraints(),
                onPressed: () {
                  _clearPathfinder(context);
                  context.read<GridBloc>().add(NavigateHome());
                },
              ),
            ],
          ),
          body: BlocBuilder<HeadPointerBloc, HeadPointerState>(
            builder: (context, hpState) {
              return HeadPointerOverlay(
                controller: _headPointerController,
                settings: hpState.settings,
                child: SafeArea(
                  child: Column(
                    children: [
                      const MessageBarView(),
                      Expanded(
                        key: _gridKey,
                        child: BlocBuilder<GridBloc, GridState>(
                    builder: (context, gridState) {
                      return BlocBuilder<ScanningBloc, ScanningState>(
                        builder: (context, scanState) {
                          // Configurar el engine con el tablero actual
                          if (scanState.settings.enabled) {
                            _scanEngine.configure(
                              settings: scanState.settings,
                              board: gridState.currentBoard,
                              onSelect: (row, col) {
                                final button = gridState.currentBoard.getButtonAt(row, col);
                                if (button != null) {
                                  _handleButtonTap(context, button);
                                }
                              },
                            );
                          } else {
                            _scanEngine.updateSettings(scanState.settings);
                          }

                          return ScanningInputHandler(
                            engine: _scanEngine,
                            settings: scanState.settings,
                            child: ListenableBuilder(
                              listenable: _scanEngine,
                              builder: (context, _) {
                                return MotorGridView(
                                  board: gridState.currentBoard,
                                  highlightedButtonId: gridState.highlightedButtonId,
                                  scanCursor: scanState.settings.enabled
                                      ? _scanEngine.cursor
                                      : null,
                                  onButtonTap: (button) => _handleButtonTap(context, button),
                                  onButtonLongPress: (button) =>
                                      _handleButtonLongPress(context, button),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    ),
    );
  }
}
