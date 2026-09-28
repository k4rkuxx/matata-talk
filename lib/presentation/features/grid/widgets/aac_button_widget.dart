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
  final bool isHighlighted; // True cuando el Pathfinder está guiando al usuario

  const AACButtonWidget({
    super.key,
    required this.button,
    required this.onTap,
    this.onLongPress,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = FitzgeraldColors.getColor(button.partOfSpeech);
    final touchSettings = context.watch<TouchSettingsBloc>().state.settings;

    return AccessibleTouchWrapper(
      settings: touchSettings,
      buttonId: button.id,
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF0D47A1) // Azul brillante de guía
                : Colors.black.withValues(alpha: 0.15),
            width: isHighlighted ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? const Color(0xFF1976D2).withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isHighlighted ? 12 : 4,
              spreadRadius: isHighlighted ? 2 : 0,
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
                    size: isHighlighted ? 46 : 42,
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
                      color: isHighlighted
                          ? const Color(0xFF0D47A1)
                          : const Color(0xFF1E1E1E),
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
