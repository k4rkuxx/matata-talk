import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/touch_settings.dart';

class AccessibleTouchWrapper extends StatefulWidget {
  final Widget child;
  final TouchSettings settings;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final String? buttonId;

  const AccessibleTouchWrapper({
    super.key,
    required this.child,
    required this.settings,
    required this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.buttonId,
  });

  @override
  State<AccessibleTouchWrapper> createState() => _AccessibleTouchWrapperState();
}

class _AccessibleTouchWrapperState extends State<AccessibleTouchWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdAnimationController;
  Timer? _longPressTimer;
  bool _isPointerInside = false;
  bool _holdCompleted = false;

  // Seguimiento del último toque por botón para anti-rebote (debounce)
  static final Map<String, DateTime> _lastTapTimestamps = {};

  @override
  void initState() {
    super.initState();
    _holdAnimationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.settings.holdDurationMs > 0
            ? widget.settings.holdDurationMs
            : 1,
      ),
    );

    _holdAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onHoldDurationCompleted();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AccessibleTouchWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.holdDurationMs != widget.settings.holdDurationMs) {
      _holdAnimationController.duration = Duration(
        milliseconds: widget.settings.holdDurationMs > 0
            ? widget.settings.holdDurationMs
            : 1,
      );
    }
  }

  @override
  void dispose() {
    _holdAnimationController.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  bool _isDebounced() {
    final debounceMs = widget.settings.debounceDurationMs;
    if (debounceMs <= 0) return false;

    final now = DateTime.now();
    final buttonKey = widget.buttonId ?? 'global';

    if (_lastTapTimestamps.containsKey(buttonKey)) {
      final diff = now.difference(_lastTapTimestamps[buttonKey]!).inMilliseconds;
      if (diff < debounceMs) {
        return true; // Ignorar toque por anti-rebote
      }
    }

    _lastTapTimestamps[buttonKey] = now;
    return false;
  }

  void _triggerHaptic() {
    if (widget.settings.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _onHoldDurationCompleted() {
    _holdCompleted = true;
    _triggerHaptic();

    if (widget.settings.activationMode == TouchActivationMode.onTouchDown) {
      _executeTap();
    }

    // Si tiene long-press configurado (morfología), iniciar temporizador adicional de long-press
    if (widget.onLongPress != null) {
      _longPressTimer = Timer(const Duration(milliseconds: 350), () {
        if (_isPointerInside && mounted) {
          if (widget.settings.enableHaptics) {
            HapticFeedback.mediumImpact();
          }
          widget.onLongPress!();
        }
      });
    }
  }

  void _executeTap() {
    if (_isDebounced()) return;
    widget.onTap();
  }

  void _handlePointerDown(PointerDownEvent event) {
    _isPointerInside = true;
    _holdCompleted = false;
    _longPressTimer?.cancel();

    if (widget.settings.holdDurationMs > 0) {
      _holdAnimationController.forward(from: 0.0);
    } else {
      // Modo instantáneo
      if (widget.settings.activationMode == TouchActivationMode.onTouchDown) {
        _triggerHaptic();
        _executeTap();
      }

      // Temporizador para long-press estándar
      if (widget.onLongPress != null) {
        _longPressTimer = Timer(const Duration(milliseconds: 500), () {
          if (_isPointerInside && mounted) {
            if (widget.settings.enableHaptics) {
              HapticFeedback.mediumImpact();
            }
            widget.onLongPress!();
          }
        });
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();

    if (widget.settings.holdDurationMs > 0) {
      _holdAnimationController.reset();

      if (_isPointerInside &&
          _holdCompleted &&
          widget.settings.activationMode == TouchActivationMode.onTouchUp) {
        _executeTap();
      }
    } else {
      // Si la activación es al soltar
      if (_isPointerInside &&
          widget.settings.activationMode == TouchActivationMode.onTouchUp) {
        _triggerHaptic();
        _executeTap();
      }
    }

    _isPointerInside = false;
    _holdCompleted = false;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _isPointerInside = false;
    _holdCompleted = false;
    _longPressTimer?.cancel();
    _holdAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(12);

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,

          // Animación visual de retención (Hold Time Progress Indicator)
          if (widget.settings.holdDurationMs > 0 &&
              widget.settings.showVisualHoldFeedback)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _holdAnimationController,
                  builder: (context, child) {
                    if (_holdAnimationController.value <= 0.0) {
                      return const SizedBox.shrink();
                    }

                    return ClipRRect(
                      borderRadius: effectiveBorderRadius,
                      child: Container(
                        color: const Color(0xFF1976D2).withValues(
                          alpha: 0.15 * _holdAnimationController.value,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              value: _holdAnimationController.value,
                              strokeWidth: 4,
                              color: const Color(0xFF1976D2),
                              backgroundColor: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
