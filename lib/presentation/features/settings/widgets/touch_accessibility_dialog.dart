import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/touch_settings.dart';
import '../../../core/widgets/accessible_touch_wrapper.dart';
import '../bloc/touch_settings_bloc.dart';

class TouchAccessibilityDialog extends StatefulWidget {
  const TouchAccessibilityDialog({super.key});

  @override
  State<TouchAccessibilityDialog> createState() =>
      _TouchAccessibilityDialogState();
}

class _TouchAccessibilityDialogState extends State<TouchAccessibilityDialog> {
  late TouchSettings _tempSettings;
  int _testTapCount = 0;
  String _lastTestMessage = 'Mantén presionado o pulsa el botón de prueba';

  @override
  void initState() {
    super.initState();
    final currentState = context.read<TouchSettingsBloc>().state;
    _tempSettings = currentState.settings;
  }

  void _onTestTap() {
    setState(() {
      _testTapCount++;
      _lastTestMessage = '¡Toque $_testTapCount registrado exitosamente! 🎉';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cabecera
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: Color(0xFF1976D2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros Táctiles y Accesibilidad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Adaptaciones motoras para Mateo 💙',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 16),

            // Contenido deslizable de ajustes
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modo de Activación
                    const Text(
                      'Modo de Activación',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TouchActivationMode>(
                        segments: const [
                          ButtonSegment(
                            value: TouchActivationMode.onTouchDown,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Al Pulsar'),
                            ),
                            icon: Icon(Icons.touch_app_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: TouchActivationMode.onTouchUp,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Al Soltar'),
                            ),
                            icon: Icon(Icons.pan_tool_outlined, size: 18),
                          ),
                        ],
                        selected: {_tempSettings.activationMode},
                        onSelectionChanged: (set) {
                          setState(() {
                            _tempSettings = _tempSettings.copyWith(
                              activationMode: set.first,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tiempo de Retención (Hold Time)
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tiempo de Retención (Hold Time)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _tempSettings.holdDurationMs == 0
                                ? 'Desactivado'
                                : '${(_tempSettings.holdDurationMs / 1000).toStringAsFixed(2)} s',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Requiere mantener presionado para evitar toques accidentales.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Slider(
                      value: _tempSettings.holdDurationMs.toDouble(),
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      activeColor: const Color(0xFF1976D2),
                      label: '${(_tempSettings.holdDurationMs / 1000).toStringAsFixed(1)}s',
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(
                            holdDurationMs: val.round(),
                          );
                        });
                      },
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildPresetChip('0s (Directo)', 0, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                        _buildPresetChip('0.2s', 200, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                        _buildPresetChip('0.5s', 500, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                        _buildPresetChip('1.0s', 1000, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Anti-Rebote (Debounce)
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Filtro Anti-Rebote (Debounce)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _tempSettings.debounceDurationMs == 0
                                ? 'Desactivado'
                                : '${(_tempSettings.debounceDurationMs / 1000).toStringAsFixed(2)} s',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ignora dobles pulsaciones involuntarias en el mismo botón.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Slider(
                      value: _tempSettings.debounceDurationMs.toDouble(),
                      min: 0,
                      max: 1500,
                      divisions: 15,
                      activeColor: const Color(0xFFF57C00),
                      label: '${(_tempSettings.debounceDurationMs / 1000).toStringAsFixed(1)}s',
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(
                            debounceDurationMs: val.round(),
                          );
                        });
                      },
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildPresetChip('Apagado', 0, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                        _buildPresetChip('0.3s', 300, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                        _buildPresetChip('0.6s', 600, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                        _buildPresetChip('1.0s', 1000, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Switches adicionales
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Animación visual de retención', style: TextStyle(fontSize: 14)),
                      subtitle: const Text(
                        'Muestra el círculo de carga azul durante la espera',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _tempSettings.showVisualHoldFeedback,
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(showVisualHoldFeedback: val);
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Respuesta háptica (vibración)', style: TextStyle(fontSize: 14)),
                      subtitle: const Text(
                        'Vibración táctil al registrar exitosamente una acción',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _tempSettings.enableHaptics,
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(enableHaptics: val);
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Zona de prueba en vivo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.science_outlined, color: Color(0xFF1976D2), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Área de Prueba en Vivo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _lastTestMessage,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 56,
                              child: AccessibleTouchWrapper(
                                settings: _tempSettings,
                                buttonId: 'test_button_preview',
                                onTap: _onTestTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE082),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.black26, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('🦁', style: TextStyle(fontSize: 22)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Probar Toque',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF1E1E1E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botones de acción inferiores
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Restablecer'),
                    ),
                    onPressed: () {
                      setState(() {
                        _tempSettings = TouchSettings.standard();
                        _testTapCount = 0;
                        _lastTestMessage = 'Ajustes restablecidos al estándar';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Guardar Ajustes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onPressed: () {
                      context
                          .read<TouchSettingsBloc>()
                          .add(UpdateTouchSettings(_tempSettings));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ajustes de accesibilidad táctil actualizados'),
                          backgroundColor: Color(0xFF2E7D32),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    String label,
    int value,
    int currentValue,
    Function(int) onSelected,
  ) {
    final isSelected = value == currentValue;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      selectedColor: const Color(0xFFBBDEFB),
      onSelected: (_) => onSelected(value),
    );
  }
}
