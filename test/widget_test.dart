import 'package:flutter_test/flutter_test.dart';
import 'package:matata_talk/domain/grammar/spanish_grammar_engine.dart';
import 'package:matata_talk/domain/models/quick_phrase.dart';
import 'package:matata_talk/domain/models/quick_phrase_category.dart';
import 'package:matata_talk/domain/models/phrase_history_item.dart';
import 'package:matata_talk/domain/models/touch_settings.dart';
import 'package:matata_talk/domain/services/pathfinder_service.dart';
import 'package:matata_talk/data/datasources/default_vocabulary.dart';

void main() {
  group('SpanishGrammarEngine Tests', () {
    final engine = SpanishGrammarEngine();

    test('Conjugates irregular verb "querer" correctly', () {
      final conj = engine.conjugateVerb('querer');
      expect(conj.infinitive, equals('querer'));
      expect(conj.getPresent(0), equals('quiero'));
      expect(conj.getPresent(1), equals('quieres'));
      expect(conj.getPresent(2), equals('quiere'));
    });

    test('Conjugates regular verb "comer" correctly', () {
      final conj = engine.conjugateVerb('comer');
      expect(conj.getPresent(0), equals('como'));
      expect(conj.getPast(0), equals('comí'));
    });
  });

  group('PathfinderService Tests', () {
    final boards = DefaultVocabulary.allBoards;
    final pathfinder = PathfinderService(boards: boards);

    test('Finds path for a word located in another board', () {
      final results = pathfinder.searchWords('pelota');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.targetButton.label.toLowerCase(), contains('pelota'));
    });
  });

  group('TouchSettings Domain Tests', () {
    test('Standard settings have 0 hold time and onTouchDown', () {
      final std = TouchSettings.standard();
      expect(std.holdDurationMs, equals(0));
      expect(std.activationMode, equals(TouchActivationMode.onTouchDown));
    });

    test('Serialization and deserialization works cleanly', () {
      const custom = TouchSettings(
        activationMode: TouchActivationMode.onTouchUp,
        holdDurationMs: 450,
        debounceDurationMs: 600,
        showVisualHoldFeedback: true,
        enableHaptics: false,
      );

      final json = custom.toJson();
      final reconstructed = TouchSettings.fromJson(json);
      expect(reconstructed, equals(custom));
    });
  });

  group('Phrases Domain Tests', () {
    test('QuickPhrase JSON serialization works', () {
      final phrase = QuickPhrase(
        id: 'qp_test',
        text: 'Quiero agua',
        iconEmoji: '💧',
        category: QuickPhraseCategory.basicNeeds,
        isFavorite: true,
        createdAt: DateTime(2026, 9, 28),
      );

      final json = phrase.toJson();
      final reconstructed = QuickPhrase.fromJson(json);
      expect(reconstructed, equals(phrase));
    });

    test('PhraseHistoryItem JSON serialization works', () {
      final history = PhraseHistoryItem(
        id: 'hist_1',
        text: 'Hola mamá',
        spokenAt: DateTime(2026, 9, 28, 10, 30),
        isFavorite: false,
      );

      final json = history.toJson();
      final reconstructed = PhraseHistoryItem.fromJson(json);
      expect(reconstructed, equals(history));
    });
  });
}
