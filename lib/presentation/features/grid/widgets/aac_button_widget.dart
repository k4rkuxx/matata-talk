import 'package:flutter/material.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../core/widgets/aac_symbol_widget.dart';
import '../../../theme/fitzgerald_colors.dart';

class AACButtonWidget extends StatelessWidget {
  final AACButton button;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AACButtonWidget({
    super.key,
    required this.button,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = FitzgeraldColors.getColor(button.partOfSpeech);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pictograma ARASAAC / Vector / Emoji
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AACSymbolWidget(
                      assetPath: button.symbolAssetPath,
                      arasaacId: button.arasaacId,
                      fallbackEmoji: button.iconEmoji,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Etiqueta de texto de alto contraste
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      button.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
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
      ),
    );
  }
}
