import 'package:equatable/equatable.dart';
import 'quick_phrase_category.dart';

class QuickPhrase extends Equatable {
  final String id;
  final String text;
  final String iconEmoji;
  final QuickPhraseCategory category;
  final bool isFavorite;
  final DateTime createdAt;

  const QuickPhrase({
    required this.id,
    required this.text,
    required this.iconEmoji,
    required this.category,
    this.isFavorite = false,
    required this.createdAt,
  });

  QuickPhrase copyWith({
    String? id,
    String? text,
    String? iconEmoji,
    QuickPhraseCategory? category,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return QuickPhrase(
      id: id ?? this.id,
      text: text ?? this.text,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'iconEmoji': iconEmoji,
      'category': category.name,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuickPhrase.fromJson(Map<String, dynamic> json) {
    return QuickPhrase(
      id: json['id'] as String,
      text: json['text'] as String,
      iconEmoji: json['iconEmoji'] as String? ?? '💬',
      category: QuickPhraseCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuickPhraseCategory.custom,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, text, iconEmoji, category, isFavorite, createdAt];
}
