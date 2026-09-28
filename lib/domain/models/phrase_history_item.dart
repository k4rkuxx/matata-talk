import 'package:equatable/equatable.dart';

class PhraseHistoryItem extends Equatable {
  final String id;
  final String text;
  final DateTime spokenAt;
  final bool isFavorite;

  const PhraseHistoryItem({
    required this.id,
    required this.text,
    required this.spokenAt,
    this.isFavorite = false,
  });

  PhraseHistoryItem copyWith({
    String? id,
    String? text,
    DateTime? spokenAt,
    bool? isFavorite,
  }) {
    return PhraseHistoryItem(
      id: id ?? this.id,
      text: text ?? this.text,
      spokenAt: spokenAt ?? this.spokenAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'spokenAt': spokenAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory PhraseHistoryItem.fromJson(Map<String, dynamic> json) {
    return PhraseHistoryItem(
      id: json['id'] as String,
      text: json['text'] as String,
      spokenAt: DateTime.tryParse(json['spokenAt'] as String? ?? '') ??
          DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, text, spokenAt, isFavorite];
}
