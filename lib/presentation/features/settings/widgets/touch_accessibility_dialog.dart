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
  static const Color _kPrimaryBlue = Color(0xFF1565C0);

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: screenHeight * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cabecera Unificada (Azul) ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: _kPrimaryBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtros Táctiles y Accesibilidad',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Filtros de retención, rebote y activación',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Contenido Deslizable ──────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modo de Activación
                    _sectionLabel('Modo de Activación'),
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
                            icon: Icon(Icons.back_hand_outlined, size: 18),
                          ),
                        ],
                        selected: {_tempSettings.activationMode},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _tempSettings = _tempSettings.copyWith(
                              activationMode: newSelection.first,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tiempo de Retención (Hold Time)
                    _sectionLabel('Tiempo de Retención: ${_tempSettings.holdDurationMs} ms'),
                    Slider(
                      value: _tempSettings.holdDurationMs.toDouble(),
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      activeColor: _kPrimaryBlue,
                      label: '${_tempSettings.holdDurationMs} ms',
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(holdDurationMs: val.toInt());
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPresetChip('Inmediato (0s)', 0, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                        _buildPresetChip('0.5 seg', 500, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                        _buildPresetChip('1.0 seg', 1000, _tempSettings.holdDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(holdDurationMs: v));
                        }),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Filtro Anti-Rebote (Debounce)
                    _sectionLabel('Filtro Anti-Rebote: ${_tempSettings.debounceDurationMs} ms'),
                    Slider(
                      value: _tempSettings.debounceDurationMs.toDouble(),
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      activeColor: _kPrimaryBlue,
                      label: '${_tempSettings.debounceDurationMs} ms',
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(debounceDurationMs: val.toInt());
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPresetChip('Desactivado', 0, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                        _buildPresetChip('300 ms', 300, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                        _buildPresetChip('700 ms', 700, _tempSettings.debounceDurationMs, (v) {
                          setState(() => _tempSettings = _tempSettings.copyWith(debounceDurationMs: v));
                        }),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Opciones de Feedback
                    _sectionLabel('Retroalimentación'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeThumbColor: _kPrimaryBlue,
                      title: const Text('Anillo de progreso visual', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Muestra un círculo de carga durante el tiempo de retención', style: TextStyle(fontSize: 10)),
                      value: _tempSettings.showVisualHoldFeedback,
                      onChanged: (val) {
                        setState(() {
                          _tempSettings = _tempSettings.copyWith(showVisualHoldFeedback: val);
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeThumbColor: _kPrimaryBlue,
                      title: const Text('Respuesta háptica (vibración)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Vibración táctil al registrar exitosamente una acción', style: TextStyle(fontSize: 10)),
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
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.science_outlined, color: _kPrimaryBlue, size: 18),
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
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 52,
                              child: AccessibleTouchWrapper(
                                settings: _tempSettings,
                                buttonId: 'test_button_preview',
                                onTap: _onTestTap,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE082),
                                    borderRadius: BorderRadius.circular(12),
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
                                        Text('🦁', style: TextStyle(fontSize: 20)),
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

            // ── Divisor ───────────────────────────────────────────────────
            const Divider(height: 1),

            // ── Botones de Acción Inferiores ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Restablecer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _tempSettings = TouchSettings.standard();
                            _testTapCount = 0;
                            _lastTestMessage = 'Ajustes restablecidos al estándar';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _kPrimaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      );

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
