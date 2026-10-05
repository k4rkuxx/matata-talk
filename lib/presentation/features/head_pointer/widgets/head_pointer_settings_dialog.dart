import 'package:camera/camera.dart';
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
    // Si la cámara aún no ha iniciado y el motor está activo o se va a calibrar
    if (widget.controller != null) {
      widget.controller!.initialize();
    }
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
                      onChanged: (v) {
                        setState(() => _draft = _draft.copyWith(enabled: v));
                        if (v && widget.controller != null && !widget.controller!.isRunning) {
                          widget.controller!.start();
                        }
                      },
                    ),

                    const Divider(height: 24),

                    // Visor de Calibración de Cabeza Grande y Prominente
                    if (_draft.enabled && widget.controller != null) ...[
                      const Text(
                        'Visor de Calibración Cefálica',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ubica tu rostro dentro del óvalo guía en tu postura de descanso y presiona "Centrar Cabeza".',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      _buildCalibrationViewfinder(widget.controller!),
                      const Divider(height: 32),
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

  Widget _buildCalibrationViewfinder(HeadPointerController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final camera = controller.cameraController;
        final isCameraReady = camera != null && camera.value.isInitialized;
        final isFaceDetected = controller.isFaceDetected;

        return Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFaceDetected ? const Color(0xFF00E676) : Colors.amber,
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isCameraReady)
                      Center(
                        child: CameraPreview(camera),
                      )
                    else
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: _kTeal),
                            SizedBox(height: 12),
                            Text(
                              'Iniciando visor de cámara...',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                    // Guía Ovalada de Rostro y Retícula Central
                    CustomPaint(
                      painter: _CalibrationGuidePainter(isDetected: isFaceDetected),
                    ),

                    // Badge de Estado Superior
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isFaceDetected ? const Color(0xFF00E676) : Colors.amber,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFaceDetected ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: isFaceDetected ? const Color(0xFF00E676) : Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isFaceDetected ? 'Rostro detectado correctamente' : 'Ubica tu rostro dentro del marco',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                controller.calibrateCenter();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎯 ¡Centro de cabeza calibrado con éxito!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF00897B),
                  ),
                );
              },
              icon: const Icon(Icons.center_focus_strong, size: 22),
              label: const Text(
                'Centrar Cabeza Ahora',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CalibrationGuidePainter extends CustomPainter {
  final bool isDetected;

  _CalibrationGuidePainter({required this.isDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.52,
      height: size.height * 0.76,
    );

    // Óvalo guía de rostro
    final ovalPaint = Paint()
      ..color = (isDetected ? const Color(0xFF00E676) : Colors.white).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawOval(ovalRect, ovalPaint);

    // Cruz / Retícula central
    final crossPaint = Paint()
      ..color = (isDetected ? const Color(0xFF00E676) : Colors.amber).withValues(alpha: 0.8)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(center.dx - 16, center.dy), Offset(center.dx + 16, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 16), Offset(center.dx, center.dy + 16), crossPaint);
  }

  @override
  bool shouldRepaint(covariant _CalibrationGuidePainter oldDelegate) {
    return oldDelegate.isDetected != isDetected;
  }
}
