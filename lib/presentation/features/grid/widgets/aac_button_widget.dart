import 'package:flutter/material.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../theme/fitzgerald_colors.dart';

class AACButtonWidget extends StatelessWidget {
  final AACButton button;
  final VoidCallback onTap;

  const AACButtonWidget({
    super.key,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = FitzgeraldColors.getColor(button.partOfSpeech);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                // Pictograma o Emoji
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      button.iconEmoji ?? '💬',
                      style: const TextStyle(fontSize: 32),
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
