import 'package:equatable/equatable.dart';

enum TouchActivationMode {
  /// Se activa inmediatamente al presionar (o al completar el tiempo de retención).
  onTouchDown,

  /// Se activa al soltar el dedo de la pantalla sobre el botón.
  onTouchUp,
}

class TouchSettings extends Equatable {
  /// Modo de activación del toque
  final TouchActivationMode activationMode;

  /// Tiempo mínimo de retención (en milisegundos) antes de registrar el toque (0 = desactivado)
  final int holdDurationMs;

  /// Tiempo mínimo de espera (en milisegundos) entre pulsaciones repetidas para evitar toques involuntarios (0 = desactivado)
  final int debounceDurationMs;

  /// Mostrar animación visual circular de progreso durante el tiempo de retención
  final bool showVisualHoldFeedback;

  /// Emitir vibración háptica al activarse el botón
  final bool enableHaptics;

  const TouchSettings({
    this.activationMode = TouchActivationMode.onTouchDown,
    this.holdDurationMs = 0,
    this.debounceDurationMs = 0,
    this.showVisualHoldFeedback = true,
    this.enableHaptics = true,
  });

  /// Configuración por defecto (toque estándar)
  factory TouchSettings.standard() => const TouchSettings();

  /// Presets recomendados para terapia y autismo
  factory TouchSettings.mildTremor() => const TouchSettings(
        holdDurationMs: 300,
        debounceDurationMs: 400,
        showVisualHoldFeedback: true,
        enableHaptics: true,
      );

  factory TouchSettings.releaseToActivate() => const TouchSettings(
        activationMode: TouchActivationMode.onTouchUp,
        holdDurationMs: 0,
        debounceDurationMs: 300,
        showVisualHoldFeedback: false,
        enableHaptics: true,
      );

  TouchSettings copyWith({
    TouchActivationMode? activationMode,
    int? holdDurationMs,
    int? debounceDurationMs,
    bool? showVisualHoldFeedback,
    bool? enableHaptics,
  }) {
    return TouchSettings(
      activationMode: activationMode ?? this.activationMode,
      holdDurationMs: holdDurationMs ?? this.holdDurationMs,
      debounceDurationMs: debounceDurationMs ?? this.debounceDurationMs,
      showVisualHoldFeedback:
          showVisualHoldFeedback ?? this.showVisualHoldFeedback,
      enableHaptics: enableHaptics ?? this.enableHaptics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activationMode': activationMode.name,
      'holdDurationMs': holdDurationMs,
      'debounceDurationMs': debounceDurationMs,
      'showVisualHoldFeedback': showVisualHoldFeedback,
      'enableHaptics': enableHaptics,
    };
  }

  factory TouchSettings.fromJson(Map<String, dynamic> json) {
    return TouchSettings(
      activationMode: TouchActivationMode.values.firstWhere(
        (e) => e.name == json['activationMode'],
        orElse: () => TouchActivationMode.onTouchDown,
      ),
      holdDurationMs: json['holdDurationMs'] as int? ?? 0,
      debounceDurationMs: json['debounceDurationMs'] as int? ?? 0,
      showVisualHoldFeedback:
          json['showVisualHoldFeedback'] as bool? ?? true,
      enableHaptics: json['enableHaptics'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        activationMode,
        holdDurationMs,
        debounceDurationMs,
        showVisualHoldFeedback,
        enableHaptics,
      ];
}
