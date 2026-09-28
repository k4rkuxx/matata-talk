import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/phrase_history_item.dart';
import '../../domain/models/quick_phrase.dart';
import '../../domain/models/quick_phrase_category.dart';

abstract class PhraseDataSource {
  Future<List<QuickPhrase>> getQuickPhrases();
  Future<void> saveCustomQuickPhrase(QuickPhrase phrase);
  Future<void> deleteCustomQuickPhrase(String phraseId);
  Future<List<PhraseHistoryItem>> getPhraseHistory();
  Future<void> savePhraseHistoryItem(PhraseHistoryItem item);
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
  Future<void> toggleFavorite(String text);
  Future<Set<String>> getFavoriteTexts();
}

class SharedPreferencesPhraseDataSource implements PhraseDataSource {
  static const String _keyCustomQuickPhrases = 'matata_custom_quick_phrases';
  static const String _keyHistory = 'matata_phrase_history';
  static const String _keyFavorites = 'matata_favorite_phrases';

  static final List<QuickPhrase> _defaultQuickPhrases = [
    // 🚨 Necesidades Básicas
    QuickPhrase(
      id: 'default_toilet',
      text: 'Necesito ir al baño',
      iconEmoji: '🚽',
      category: QuickPhraseCategory.basicNeeds,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_hungry',
      text: 'Tengo hambre, quiero comer',
      iconEmoji: '🍎',
      category: QuickPhraseCategory.basicNeeds,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_thirsty',
      text: 'Tengo sed, quiero agua',
      iconEmoji: '💧',
      category: QuickPhraseCategory.basicNeeds,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_help',
      text: 'Ayuda por favor',
      iconEmoji: '🆘',
      category: QuickPhraseCategory.basicNeeds,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_pain',
      text: 'Me duele algo, no me siento bien',
      iconEmoji: '🤕',
      category: QuickPhraseCategory.basicNeeds,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_tired',
      text: 'Estoy cansado, tengo sueño',
      iconEmoji: '😴',
      category: QuickPhraseCategory.basicNeeds,
      createdAt: DateTime(2026, 1, 1),
    ),

    // 💬 Conversación y Cortesía
    QuickPhrase(
      id: 'default_hello',
      text: 'Hola, buenos días',
      iconEmoji: '👋',
      category: QuickPhraseCategory.social,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_thanks',
      text: 'Muchas gracias',
      iconEmoji: '🙏',
      category: QuickPhraseCategory.social,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_yes',
      text: 'Sí, por favor',
      iconEmoji: '👍',
      category: QuickPhraseCategory.social,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_no',
      text: 'No, gracias',
      iconEmoji: '👎',
      category: QuickPhraseCategory.social,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_wait',
      text: 'Por favor espera un momento',
      iconEmoji: '⏳',
      category: QuickPhraseCategory.social,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_bye',
      text: 'Adiós, hasta luego',
      iconEmoji: '👋',
      category: QuickPhraseCategory.social,
      createdAt: DateTime(2026, 1, 1),
    ),

    // 🧘 Regulación Sensorial (Autismo 💙)
    QuickPhrase(
      id: 'default_noise',
      text: 'Hay mucho ruido, necesito silencio',
      iconEmoji: '🤫',
      category: QuickPhraseCategory.sensory,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_break',
      text: 'Necesito un descanso en un lugar tranquilo',
      iconEmoji: '🛑',
      category: QuickPhraseCategory.sensory,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_touch',
      text: 'No me toques por favor',
      iconEmoji: '✋',
      category: QuickPhraseCategory.sensory,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_happy',
      text: 'Estoy muy feliz',
      iconEmoji: '😊',
      category: QuickPhraseCategory.sensory,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhrase(
      id: 'default_overwhelmed',
      text: 'Me siento abrumado y molesto',
      iconEmoji: '😣',
      category: QuickPhraseCategory.sensory,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Future<List<QuickPhrase>> getQuickPhrases() async {
    final favorites = await getFavoriteTexts();
    final List<QuickPhrase> customPhrases = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyCustomQuickPhrases);
      if (list != null) {
        for (final itemStr in list) {
          final Map<String, dynamic> map = jsonDecode(itemStr);
          customPhrases.add(QuickPhrase.fromJson(map));
        }
      }
    } catch (_) {}

    final all = [..._defaultQuickPhrases, ...customPhrases];
    return all.map((p) => p.copyWith(isFavorite: favorites.contains(p.text))).toList();
  }

  @override
  Future<void> saveCustomQuickPhrase(QuickPhrase phrase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyCustomQuickPhrases) ?? [];
      list.add(jsonEncode(phrase.toJson()));
      await prefs.setStringList(_keyCustomQuickPhrases, list);
    } catch (_) {}
  }

  @override
  Future<void> deleteCustomQuickPhrase(String phraseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyCustomQuickPhrases) ?? [];
      final updated = list.where((item) {
        final map = jsonDecode(item);
        return map['id'] != phraseId;
      }).toList();
      await prefs.setStringList(_keyCustomQuickPhrases, updated);
    } catch (_) {}
  }

  @override
  Future<List<PhraseHistoryItem>> getPhraseHistory() async {
    final favorites = await getFavoriteTexts();
    final List<PhraseHistoryItem> history = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory);
      if (list != null) {
        for (final itemStr in list) {
          final Map<String, dynamic> map = jsonDecode(itemStr);
          final item = PhraseHistoryItem.fromJson(map);
          history.add(item.copyWith(isFavorite: favorites.contains(item.text)));
        }
      }
    } catch (_) {}

    // Ordenar de más reciente a más antiguo
    history.sort((a, b) => b.spokenAt.compareTo(a.spokenAt));
    return history;
  }

  @override
  Future<void> savePhraseHistoryItem(PhraseHistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory) ?? [];
      
      // Limitar el historial a las últimas 100 frases
      list.insert(0, jsonEncode(item.toJson()));
      if (list.length > 100) {
        list.removeRange(100, list.length);
      }
      await prefs.setStringList(_keyHistory, list);
    } catch (_) {}
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory) ?? [];
      final updated = list.where((item) {
        final map = jsonDecode(item);
        return map['id'] != id;
      }).toList();
      await prefs.setStringList(_keyHistory, updated);
    } catch (_) {}
  }

  @override
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHistory);
    } catch (_) {}
  }

  @override
  Future<Set<String>> getFavoriteTexts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyFavorites);
      if (list != null) {
        return list.toSet();
      }
    } catch (_) {}
    return {};
  }

  @override
  Future<void> toggleFavorite(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = (prefs.getStringList(_keyFavorites) ?? []).toSet();
      if (favorites.contains(text)) {
        favorites.remove(text);
      } else {
        favorites.add(text);
      }
      await prefs.setStringList(_keyFavorites, favorites.toList());
    } catch (_) {}
  }
}
