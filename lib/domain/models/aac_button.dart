import 'package:equatable/equatable.dart';
import 'button_action.dart';
import 'part_of_speech.dart';

class AACButton extends Equatable {
  final String id;
  final int row;
  final int col;
  final String label;
  final String? vocalizationText;
  final String? iconEmoji;
  final String? symbolAssetPath;
  final int? arasaacId; // ID oficial del pictograma en ARASAAC
  final PartOfSpeech partOfSpeech;
  final ButtonActionType actionType;
  final String? targetBoardId;

  const AACButton({
    required this.id,
    required this.row,
    required this.col,
    required this.label,
    this.vocalizationText,
    this.iconEmoji,
    this.symbolAssetPath,
    this.arasaacId,
    required this.partOfSpeech,
    this.actionType = ButtonActionType.speakAndAddToMessage,
    this.targetBoardId,
  });

  String get textToSpeak => vocalizationText ?? label;

  /// Retorna true si el botón es una carpeta o navegación a otro tablero
  bool get isFolder =>
      actionType == ButtonActionType.navigateToBoard || targetBoardId != null;


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'col': col,
      'label': label,
      'vocalizationText': vocalizationText,
      'iconEmoji': iconEmoji,
      'symbolAssetPath': symbolAssetPath,
      'arasaacId': arasaacId,
      'partOfSpeech': partOfSpeech.name,
      'actionType': actionType.name,
      'targetBoardId': targetBoardId,
    };
  }

  factory AACButton.fromJson(Map<String, dynamic> json) {
    return AACButton(
      id: json['id'] as String? ?? 'btn_${DateTime.now().millisecondsSinceEpoch}',
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      vocalizationText: json['vocalizationText'] as String?,
      iconEmoji: json['iconEmoji'] as String?,
      symbolAssetPath: json['symbolAssetPath'] as String?,
      arasaacId: json['arasaacId'] as int?,
      partOfSpeech: PartOfSpeech.values.firstWhere(
        (p) => p.name == json['partOfSpeech'],
        orElse: () => PartOfSpeech.misc,
      ),
      actionType: ButtonActionType.values.firstWhere(
        (a) => a.name == json['actionType'],
        orElse: () => ButtonActionType.speakAndAddToMessage,
      ),
      targetBoardId: json['targetBoardId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        row,
        col,
        label,
        vocalizationText,
        iconEmoji,
        symbolAssetPath,
        arasaacId,
        partOfSpeech,
        actionType,
        targetBoardId,
      ];
}
