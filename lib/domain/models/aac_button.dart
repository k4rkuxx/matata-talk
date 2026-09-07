import 'package:equatable/equatable.dart';
import 'button_action.dart';
import 'part_of_speech.dart';

class AACButton extends Equatable {
  final String id;
  final int row;
  final int col;
  final String label;
  final String? vocalizationText;
  final String? iconEmoji;       // Emoji representativo (prototipo)
  final String? symbolAssetPath; // Ruta al pictograma ARASAAC
  final PartOfSpeech partOfSpeech;
  final ButtonActionType actionType;
  final String? targetBoardId;   // ID del tablero si es carpeta

  const AACButton({
    required this.id,
    required this.row,
    required this.col,
    required this.label,
    this.vocalizationText,
    this.iconEmoji,
    this.symbolAssetPath,
    required this.partOfSpeech,
    this.actionType = ButtonActionType.speakAndAddToMessage,
    this.targetBoardId,
  });

  String get textToSpeak => vocalizationText ?? label;

  @override
  List<Object?> get props => [
        id,
        row,
        col,
        label,
        vocalizationText,
        iconEmoji,
        symbolAssetPath,
        partOfSpeech,
        actionType,
        targetBoardId,
      ];
}
