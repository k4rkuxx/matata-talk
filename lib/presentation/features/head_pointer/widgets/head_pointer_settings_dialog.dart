import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/head_pointer_settings.dart';
import '../bloc/head_pointer_bloc.dart';
import '../controller/head_pointer_controller.dart';

class HeadPointerSettingsDialog extends StatefulWidget {
  final HeadPointerController? controller;

  const HeadPointerSettingsDialog({
    super.key,
    this.controller,
  });

  @override
  State<HeadPointerSettingsDialog> createState() => _HeadPointerSettingsDialogState();
}

class _HeadPointerSettingsDialogState extends State<HeadPointerSettingsDialog> {
  late HeadPointerSettings _draft;
  static const Color _kTeal = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _draft = context.read<HeadPointerBloc>().state.settings;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenHeight * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF004D40),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.face_retouching_natural, color: Colors.white, size: 26),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntero Facial / Head Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Control del comunicador con movimientos de cabeza',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Contenido con Scroll
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Switch Maestro
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Activar Head Tracking',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Usa la cámara frontal para apuntar y seleccionar',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      value: _draft.enabled,
                      activeThumbColor: _kTeal,
                      onChanged: (v) => setState(() => _draft = _draft.copyWith(enabled: v)),
                    ),

                    const Divider(height: 24),

                    // Calibración Rápida
                    if (_draft.enabled && widget.controller != null) ...[
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            widget.controller?.calibrateCenter();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Centro calibrado con éxito!'),
                                duration: Duration(seconds: 2),
                                backgroundColor: _kTeal,
                              ),
                            );
                          },
                          icon: const Icon(Icons.center_focus_strong, color: _kTeal),
                          label: const Text('Centrar Cabeza Ahora'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _kTeal, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Slider: Tiempo de fijación (Dwell Time)
                    Text(
                      'Tiempo de Fijación (Dwell Time): ${(_draft.dwellDurationMs / 1000).toStringAsFixed(1)} s',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Text(
                      'Tiempo necesario sobre un pictograma para activarlo',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Slider(
                      value: _draft.dwellDurationMs.toDouble(),
                      min: 600,
                      max: 3000,
                      divisions: 12,
                      activeColor: _kTeal,
                      label: '${(_draft.dwellDurationMs / 1000).toStringAsFixed(1)} s',
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(dwellDurationMs: v.round()))
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Slider: Sensibilidad Horizontal
                    Text(
                      'Sensibilidad Horizontal: ${_draft.sensitivityX.toStringAsFixed(1)}x',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Slider(
                      value: _draft.sensitivityX,
                      min: 0.8,
                      max: 3.5,
                      divisions: 27,
                      activeColor: _kTeal,
                      label: '${_draft.sensitivityX.toStringAsFixed(1)}x',
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(sensitivityX: v))
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Slider: Sensibilidad Vertical
                    Text(
                      'Sensibilidad Vertical: ${_draft.sensitivityY.toStringAsFixed(1)}x',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Slider(
                      value: _draft.sensitivityY,
                      min: 0.8,
                      max: 3.5,
                      divisions: 27,
                      activeColor: _kTeal,
                      label: '${_draft.sensitivityY.toStringAsFixed(1)}x',
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(sensitivityY: v))
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Slider: Filtro anti-temblor (Zona Muerta)
                    Text(
                      'Filtro Anti-temblor: ${_draft.deadZone.toStringAsFixed(1)}°',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Text(
                      'Tolerancia angular para ignorar micro-movimientos involuntarios',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Slider(
                      value: _draft.deadZone,
                      min: 0.5,
                      max: 4.5,
                      divisions: 8,
                      activeColor: _kTeal,
                      label: '${_draft.deadZone.toStringAsFixed(1)}°',
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(deadZone: v))
                          : null,
                    ),

                    const Divider(height: 24),

                    // Opciones Visuales y Gestos
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Efecto Espejo (Mirror X)', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Mueve el cursor hacia donde giras la cabeza naturalmente', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: _draft.mirrorX,
                      activeThumbColor: _kTeal,
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(mirrorX: v))
                          : null,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Miniatura de Cámara (PIP)', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Muestra el visor en esquina para comprobar encuadre', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: _draft.showPipPreview,
                      activeThumbColor: _kTeal,
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(showPipPreview: v))
                          : null,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Activar con Sonrisa', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Permite seleccionar inmediatamente sonriendo sin esperar dwell', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: _draft.triggerOnSmile,
                      activeThumbColor: _kTeal,
                      onChanged: _draft.enabled
                          ? (v) => setState(() => _draft = _draft.copyWith(triggerOnSmile: v))
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Botones Inferiores
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<HeadPointerBloc>().add(UpdateHeadPointerSettings(_draft));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
