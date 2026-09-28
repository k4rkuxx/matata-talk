import '../../domain/models/aac_board.dart';
import '../../domain/models/aac_button.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../database/app_database.dart';

class LocalVocabularyRepository implements VocabularyRepository {
  @override
  Future<Map<String, AACBoard>> getAllBoards() async {
    return await AppDatabase.getAllBoards();
  }

  @override
  Future<AACBoard?> getBoard(String boardId) async {
    return await AppDatabase.getBoard(boardId);
  }

  @override
  Future<void> saveButton(String boardId, AACButton button) async {
    await AppDatabase.saveButton(boardId, button);
  }
}
