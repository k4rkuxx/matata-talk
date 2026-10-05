import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/head_pointer_settings.dart';
import '../controller/head_pointer_controller.dart';

class HeadPointerOverlay extends StatefulWidget {
  final HeadPointerController controller;
  final HeadPointerSettings settings;
  final Widget child;
  final void Function(Offset globalPosition)? onPointerPositionChanged;

  const HeadPointerOverlay({
    super.key,
    required this.controller,
    required this.settings,
    required this.child,
    this.onPointerPositionChanged,
  });

  @override
  State<HeadPointerOverlay> createState() => _HeadPointerOverlayState();
}

class _HeadPointerOverlayState extends State<HeadPointerOverlay> {
  bool _pipMinimized = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.settings.enabled) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final posX = widget.controller.normalizedPosition.dx * screenWidth;
            final posY = widget.controller.normalizedPosition.dy * screenHeight;

            // Notificar posición global para hit-testing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onPointerPositionChanged?.call(Offset(posX, posY));
            });

            return Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child,

                // 1. Mensaje de advertencia si no detecta rostro
                if (widget.controller.isRunning && !widget.controller.isFaceDetected)
                  Positioned(
                    top: 16,
                    left: 24,
                    right: 24,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xCC212121),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face_retouching_natural, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Alinea tu rostro frente a la cámara',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 2. Miniatura PIP de la Cámara Frontal
                if (widget.settings.showPipPreview && widget.controller.cameraController != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildPipPreview(),
                  ),

                // 3. Puntero Flotante con Anillo de Dwell
                if (widget.controller.isRunning && widget.controller.isFaceDetected)
                  Positioned(
                    left: posX - 28,
                    top: posY - 28,
                    child: IgnorePointer(
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: CustomPaint(
                          painter: _DwellPointerPainter(
                            progress: widget.controller.dwellProgress,
                            showRing: widget.settings.showCursorRing,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPipPreview() {
    final camera = widget.controller.cameraController;
    if (camera == null || !camera.value.isInitialized) {
      return const SizedBox.shrink();
    }

    if (_pipMinimized) {
      return GestureDetector(
        onTap: () => setState(() => _pipMinimized = false),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xDD000000),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E676), width: 2),
          ),
          child: const Icon(Icons.videocam, color: Colors.white, size: 18),
        ),
      );
    }

    return Container(
      width: 128,
      height: 168,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.controller.isFaceDetected ? const Color(0xFF00E676) : Colors.amber,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(camera),

            // Indicador de Rostro en Esquina Superior Izquierda
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: widget.controller.isFaceDetected ? const Color(0xFF00E676) : Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.controller.isFaceDetected ? 'OK' : 'Buscando',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Botón de Minimizar
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _pipMinimized = true),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),

            // Botón de Centrado Rápido Grande y Ergonómico
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  widget.controller.calibrateCenter();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎯 Centro calibrado'),
                      duration: Duration(milliseconds: 1200),
                      backgroundColor: Color(0xFF00897B),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.center_focus_strong, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Centrar Cabeza',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
    );
  }
}

class _DwellPointerPainter extends CustomPainter {
  final double progress;
  final bool showRing;

  _DwellPointerPainter({
    required this.progress,
    required this.showRing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 22.0;

    // 1. Círculo exterior tenue (guía)
    final bgPaint = Paint()
      ..color = const Color(0x40000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Anillo de progreso Dwell
    if (showRing && progress > 0.0) {
      final isComplete = progress >= 1.0;
      final arcPaint = Paint()
        ..color = isComplete ? const Color(0xFFFFD600) : const Color(0xFF00E676)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Empieza arriba (12 en punto)
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // 3. Punto central / Retícula
    final centerPaint = Paint()
      ..color = progress >= 1.0 ? const Color(0xFFFFD600) : const Color(0xFF00E676)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, centerPaint);

    // Borde blanco de alto contraste para el punto central
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, 5.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _DwellPointerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.showRing != showRing;
  }
}
