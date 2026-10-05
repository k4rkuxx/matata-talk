import '../models/aac_board.dart';
import '../models/aac_button.dart';

abstract class VocabularyRepository {
  Future<Map<String, AACBoard>> getAllBoards();
  Future<AACBoard?> getBoard(String boardId);
  Future<void> saveButton(String boardId, AACButton button);
  Future<void> saveBoard(AACBoard board);
  Future<void> saveAllBoards(Map<String, AACBoard> boards);
}
