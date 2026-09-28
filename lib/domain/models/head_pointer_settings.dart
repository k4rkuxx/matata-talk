import 'package:equatable/equatable.dart';

class HeadPointerSettings extends Equatable {
  final bool enabled;
  final int dwellDurationMs; // 500ms a 3000ms
  final double sensitivityX; // 0.5 a 3.5
  final double sensitivityY; // 0.5 a 3.5
  final double deadZone; // grados de tolerancia anti-temblor (0.5 a 5.0)
  final double smoothingFactor; // 0.1 (muy suave/lento) a 0.5 (rápido/reactivo)
  final bool showPipPreview; // Miniatura de la cámara frontal en pantalla
  final bool showCursorRing; // Anillo de progreso de dwell time
  final bool mirrorX; // Invertir eje horizontal para efecto espejo natural
  final bool triggerOnSmile; // Clic por gesto de sonrisa
  final bool triggerOnBlink; // Clic por parpadeo intencional

  const HeadPointerSettings({
    this.enabled = false,
    this.dwellDurationMs = 1200,
    this.sensitivityX = 1.6,
    this.sensitivityY = 1.6,
    this.deadZone = 2.0,
    this.smoothingFactor = 0.25,
    this.showPipPreview = true,
    this.showCursorRing = true,
    this.mirrorX = true,
    this.triggerOnSmile = false,
    this.triggerOnBlink = false,
  });

  factory HeadPointerSettings.standard() => const HeadPointerSettings();

  HeadPointerSettings copyWith({
    bool? enabled,
    int? dwellDurationMs,
    double? sensitivityX,
    double? sensitivityY,
    double? deadZone,
    double? smoothingFactor,
    bool? showPipPreview,
    bool? showCursorRing,
    bool? mirrorX,
    bool? triggerOnSmile,
    bool? triggerOnBlink,
  }) {
    return HeadPointerSettings(
      enabled: enabled ?? this.enabled,
      dwellDurationMs: dwellDurationMs ?? this.dwellDurationMs,
      sensitivityX: sensitivityX ?? this.sensitivityX,
      sensitivityY: sensitivityY ?? this.sensitivityY,
      deadZone: deadZone ?? this.deadZone,
      smoothingFactor: smoothingFactor ?? this.smoothingFactor,
      showPipPreview: showPipPreview ?? this.showPipPreview,
      showCursorRing: showCursorRing ?? this.showCursorRing,
      mirrorX: mirrorX ?? this.mirrorX,
      triggerOnSmile: triggerOnSmile ?? this.triggerOnSmile,
      triggerOnBlink: triggerOnBlink ?? this.triggerOnBlink,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'dwellDurationMs': dwellDurationMs,
      'sensitivityX': sensitivityX,
      'sensitivityY': sensitivityY,
      'deadZone': deadZone,
      'smoothingFactor': smoothingFactor,
      'showPipPreview': showPipPreview,
      'showCursorRing': showCursorRing,
      'mirrorX': mirrorX,
      'triggerOnSmile': triggerOnSmile,
      'triggerOnBlink': triggerOnBlink,
    };
  }

  factory HeadPointerSettings.fromJson(Map<String, dynamic> json) {
    return HeadPointerSettings(
      enabled: json['enabled'] as bool? ?? false,
      dwellDurationMs: json['dwellDurationMs'] as int? ?? 1200,
      sensitivityX: (json['sensitivityX'] as num?)?.toDouble() ?? 1.6,
      sensitivityY: (json['sensitivityY'] as num?)?.toDouble() ?? 1.6,
      deadZone: (json['deadZone'] as num?)?.toDouble() ?? 2.0,
      smoothingFactor: (json['smoothingFactor'] as num?)?.toDouble() ?? 0.25,
      showPipPreview: json['showPipPreview'] as bool? ?? true,
      showCursorRing: json['showCursorRing'] as bool? ?? true,
      mirrorX: json['mirrorX'] as bool? ?? true,
      triggerOnSmile: json['triggerOnSmile'] as bool? ?? false,
      triggerOnBlink: json['triggerOnBlink'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        dwellDurationMs,
        sensitivityX,
        sensitivityY,
        deadZone,
        smoothingFactor,
        showPipPreview,
        showCursorRing,
        mirrorX,
        triggerOnSmile,
        triggerOnBlink,
      ];
}
