import 'package:flutter/material.dart';
import '../../../../domain/grammar/spanish_grammar_engine.dart';
import '../../../../domain/grammar/verb_conjugations.dart';
import '../../../../domain/models/aac_button.dart';
import '../../../../domain/models/part_of_speech.dart';
import '../../../core/widgets/aac_symbol_widget.dart';
import '../../../theme/fitzgerald_colors.dart';

class MorphologyPopupDialog extends StatelessWidget {
  final AACButton button;
  final Function(AACButton inflectedButton) onSelectInflection;

  const MorphologyPopupDialog({
    super.key,
    required this.button,
    required this.onSelectInflection,
  });

  @override
  Widget build(BuildContext context) {
    final grammarEngine = SpanishGrammarEngine();

    if (button.partOfSpeech == PartOfSpeech.verb) {
      final conjugations = grammarEngine.conjugateVerb(button.label);
      return _buildVerbDialog(context, conjugations);
    } else if (button.partOfSpeech == PartOfSpeech.noun ||
        button.partOfSpeech == PartOfSpeech.adjective) {
      return _buildNounAdjectiveDialog(context, grammarEngine);
    }

    return const SizedBox.shrink();
  }

  Widget _buildVerbDialog(BuildContext context, VerbConjugations c) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera con pictograma y verbo base
              Row(
                children: [
                  AACSymbolWidget(
                    assetPath: button.symbolAssetPath,
                    arasaacId: button.arasaacId,
                    fallbackEmoji: button.iconEmoji,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Formas de "${c.infinitive.toUpperCase()}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Sección 1: Presente
              _buildSectionTitle('🌞 Presente'),
              _buildButtonRow(context, [
                _createInflectionButton('Yo ${c.getPresent(0)}', c.getPresent(0)),
                _createInflectionButton('Tú ${c.getPresent(1)}', c.getPresent(1)),
                _createInflectionButton('Él ${c.getPresent(2)}', c.getPresent(2)),
              ]),
              const SizedBox(height: 8),
              _buildButtonRow(context, [
                _createInflectionButton('Nosotros ${c.getPresent(3)}', c.getPresent(3)),
                _createInflectionButton('Ellos ${c.getPresent(4)}', c.getPresent(4)),
              ]),
              const SizedBox(height: 16),

              // Sección 2: Pasado
              _buildSectionTitle('⏳ Pasado (Pretérito)'),
              _buildButtonRow(context, [
                _createInflectionButton('Yo ${c.getPast(0)}', c.getPast(0)),
                _createInflectionButton('Tú ${c.getPast(1)}', c.getPast(1)),
                _createInflectionButton('Él ${c.getPast(2)}', c.getPast(2)),
              ]),
              const SizedBox(height: 16),

              // Sección 3: Futuro y Continuas
              _buildSectionTitle('🚀 Futuro y Otras Formas'),
              _buildButtonRow(context, [
                _createInflectionButton('Yo ${c.getFuture(0)}', c.getFuture(0)),
                _createInflectionButton('Él ${c.getFuture(2)}', c.getFuture(2)),
                _createInflectionButton('✨ ${c.gerund}', c.gerund),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNounAdjectiveDialog(
      BuildContext context, SpanishGrammarEngine engine) {
    final plural = engine.pluralizeNoun(button.label);
    final feminine = engine.feminineForm(button.label);
    final femininePlural = engine.pluralizeNoun(feminine);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AACSymbolWidget(
                  assetPath: button.symbolAssetPath,
                  arasaacId: button.arasaacId,
                  fallbackEmoji: button.iconEmoji,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Text(
                  'Formas de "${button.label}"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildButtonRow(context, [
              _createInflectionButton('Singular: ${button.label}', button.label),
              _createInflectionButton('Plural: $plural', plural),
            ]),
            if (feminine != button.label) ...[
              const SizedBox(height: 12),
              _buildButtonRow(context, [
                _createInflectionButton('Femenino: $feminine', feminine),
                _createInflectionButton('Fem. Plural: $femininePlural', femininePlural),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, List<AACButton> buttons) {
    return Row(
      children: buttons
          .map((b) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          FitzgeraldColors.getColor(button.partOfSpeech),
                      foregroundColor: const Color(0xFF1E1E1E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onSelectInflection(b);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        b.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  AACButton _createInflectionButton(String displayLabel, String wordToSpeak) {
    return AACButton(
      id: '${button.id}_$wordToSpeak',
      row: button.row,
      col: button.col,
      label: wordToSpeak,
      vocalizationText: wordToSpeak,
      iconEmoji: button.iconEmoji,
      symbolAssetPath: button.symbolAssetPath,
      arasaacId: button.arasaacId,
      partOfSpeech: button.partOfSpeech,
      actionType: button.actionType,
    );
  }
}
