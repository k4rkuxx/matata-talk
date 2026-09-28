import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../core/widgets/aac_symbol_widget.dart';
import '../../../core/widgets/accessible_touch_wrapper.dart';
import '../../../theme/fitzgerald_colors.dart';
import '../../settings/bloc/touch_settings_bloc.dart';

class AACButtonWidget extends StatelessWidget {
  final AACButton button;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  /// True cuando el Pathfinder está guiando al usuario (azul)
  final bool isHighlighted;
  /// True cuando el cursor de barrido está exactamente sobre este botón (ámbar)
  final bool isScanHighlighted;
  /// True cuando el cursor de barrido resalta la fila entera (ámbar suave)
  final bool isRowScanHighlighted;

  const AACButtonWidget({
    super.key,
    required this.button,
    required this.onTap,
    this.onLongPress,
    this.isHighlighted = false,
    this.isScanHighlighted = false,
    this.isRowScanHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = FitzgeraldColors.getColor(button.partOfSpeech);
    final touchSettings = context.watch<TouchSettingsBloc>().state.settings;

    // Colores de resaltado
    const pathfinderBlue = Color(0xFF0D47A1);
    const scanAmber = Color(0xFFFF8F00);
    const scanAmberRow = Color(0xFFFFA000);

    final borderColor = isScanHighlighted
        ? scanAmber
        : isHighlighted
            ? pathfinderBlue
            : isRowScanHighlighted
                ? scanAmberRow
                : Colors.black.withValues(alpha: 0.15);

    final borderWidth = isScanHighlighted
        ? 4.0
        : isHighlighted
            ? 4.0
            : isRowScanHighlighted
                ? 3.0
                : 2.0;

    final shadowColor = isScanHighlighted
        ? scanAmber.withValues(alpha: 0.65)
        : isHighlighted
            ? const Color(0xFF1976D2).withValues(alpha: 0.6)
            : isRowScanHighlighted
                ? scanAmberRow.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08);

    final blurRadius = (isScanHighlighted || isHighlighted) ? 12.0 : isRowScanHighlighted ? 8.0 : 4.0;
    final spreadRadius = (isScanHighlighted || isHighlighted) ? 2.0 : 0.0;

    final labelColor = isScanHighlighted
        ? scanAmber
        : isHighlighted
            ? pathfinderBlue
            : const Color(0xFF1E1E1E);

    final iconSize = (isScanHighlighted || isHighlighted) ? 46.0 : 42.0;

    // Fondo con tinte ámbar suave cuando la fila está seleccionada
    final effectiveBg = isRowScanHighlighted && !isScanHighlighted
        ? Color.lerp(bgColor, scanAmberRow, 0.15)!
        : bgColor;

    return AccessibleTouchWrapper(
      settings: touchSettings,
      buttonId: button.id,
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: AACSymbolWidget(
                    assetPath: button.symbolAssetPath,
                    arasaacId: button.arasaacId,
                    fallbackEmoji: button.iconEmoji,
                    size: iconSize,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    button.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
