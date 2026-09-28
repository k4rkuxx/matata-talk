enum QuickPhraseCategory {
  basicNeeds,
  social,
  sensory,
  custom;

  String get displayName {
    switch (this) {
      case QuickPhraseCategory.basicNeeds:
        return 'Necesidades';
      case QuickPhraseCategory.social:
        return 'Conversación';
      case QuickPhraseCategory.sensory:
        return 'Sensorial 💙';
      case QuickPhraseCategory.custom:
        return 'Personalizadas';
    }
  }

  String get emoji {
    switch (this) {
      case QuickPhraseCategory.basicNeeds:
        return '🚨';
      case QuickPhraseCategory.social:
        return '💬';
      case QuickPhraseCategory.sensory:
        return '🧘';
      case QuickPhraseCategory.custom:
        return '⭐';
    }
  }
}
