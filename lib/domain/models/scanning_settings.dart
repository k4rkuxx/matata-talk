import 'package:equatable/equatable.dart';

enum ScanningMode {
  /// 1 Conmutador / Toque: El cursor avanza solo cada X segundos; la pulsación selecciona.
  autoScan,

  /// 2 Conmutadores: Switch 1 avanza el cursor paso a paso; Switch 2 confirma la selección.
  stepScan,

  /// Inverso: Mantener presionado para avanzar; soltar para seleccionar.
  inverseScan,
}

enum ScanningPattern {
  /// Fila-Columna: Resalta primero la fila entera y luego cada botón (Estándar clínico más rápido).
  rowColumn,

  /// Lineal: Recorre cada pictograma uno por uno secuencialmente.
  linear,
}

class ScanningSettings extends Equatable {
  /// Activar / Desactivar el motor de barrido
  final bool enabled;

  /// Modo de operación (Automático, 2 Switches, Inverso)
  final ScanningMode mode;

  /// Patrón de recorrido (Fila-Columna o Lineal)
  final ScanningPattern pattern;

  /// Tiempo de espera por paso en segundos (para modo automático)
  final double scanSpeedSeconds;

  /// Número de vueltas completas antes de pausar el barrido si no hay respuesta (1 a 5)
  final int maxLoops;

  /// Barrido auditivo: susurra/pronuncia el pictograma cuando el cursor se posa sobre él
  final bool enableAuditoryCue;

  /// Emitir sonido suave de clic/beep en cada salto del cursor
  final bool enableAcousticBeep;

  /// Activar la pantalla entera como un conmutador táctil gigante
  final bool screenAsSwitch;

  const ScanningSettings({
    this.enabled = false,
    this.mode = ScanningMode.autoScan,
    this.pattern = ScanningPattern.rowColumn,
    this.scanSpeedSeconds = 1.5,
    this.maxLoops = 3,
    this.enableAuditoryCue = false,
    this.enableAcousticBeep = true,
    this.screenAsSwitch = true,
  });

  factory ScanningSettings.standard() => const ScanningSettings();

  ScanningSettings copyWith({
    bool? enabled,
    ScanningMode? mode,
    ScanningPattern? pattern,
    double? scanSpeedSeconds,
    int? maxLoops,
    bool? enableAuditoryCue,
    bool? enableAcousticBeep,
    bool? screenAsSwitch,
  }) {
    return ScanningSettings(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      pattern: pattern ?? this.pattern,
      scanSpeedSeconds: scanSpeedSeconds ?? this.scanSpeedSeconds,
      maxLoops: maxLoops ?? this.maxLoops,
      enableAuditoryCue: enableAuditoryCue ?? this.enableAuditoryCue,
      enableAcousticBeep: enableAcousticBeep ?? this.enableAcousticBeep,
      screenAsSwitch: screenAsSwitch ?? this.screenAsSwitch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'mode': mode.name,
      'pattern': pattern.name,
      'scanSpeedSeconds': scanSpeedSeconds,
      'maxLoops': maxLoops,
      'enableAuditoryCue': enableAuditoryCue,
      'enableAcousticBeep': enableAcousticBeep,
      'screenAsSwitch': screenAsSwitch,
    };
  }

  factory ScanningSettings.fromJson(Map<String, dynamic> json) {
    return ScanningSettings(
      enabled: json['enabled'] as bool? ?? false,
      mode: ScanningMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => ScanningMode.autoScan,
      ),
      pattern: ScanningPattern.values.firstWhere(
        (p) => p.name == json['pattern'],
        orElse: () => ScanningPattern.rowColumn,
      ),
      scanSpeedSeconds: (json['scanSpeedSeconds'] as num?)?.toDouble() ?? 1.5,
      maxLoops: json['maxLoops'] as int? ?? 3,
      enableAuditoryCue: json['enableAuditoryCue'] as bool? ?? false,
      enableAcousticBeep: json['enableAcousticBeep'] as bool? ?? true,
      screenAsSwitch: json['screenAsSwitch'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        mode,
        pattern,
        scanSpeedSeconds,
        maxLoops,
        enableAuditoryCue,
        enableAcousticBeep,
        screenAsSwitch,
      ];
}
