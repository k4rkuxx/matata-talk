import '../models/aac_board.dart';
import '../models/aac_button.dart';
import '../models/button_action.dart';

class WordPathStep {
  final String boardId;
  final String boardName;
  final AACButton targetButton;

  const WordPathStep({
    required this.boardId,
    required this.boardName,
    required this.targetButton,
  });
}

class WordPathResult {
  final AACButton targetButton;
  final List<WordPathStep> steps;

  const WordPathResult({
    required this.targetButton,
    required this.steps,
  });

  String get pathDescription =>
      steps.map((s) => s.targetButton.label).join(' ➔ ');
}

class PathfinderService {
  final Map<String, AACBoard> boards;

  PathfinderService({required this.boards});

  List<WordPathResult> searchWords(String query) {
    if (query.trim().isEmpty) return [];

    final cleanQuery = query.toLowerCase().trim();
    final List<WordPathResult> results = [];

    // 1. Buscar en todos los tableros
    for (final board in boards.values) {
      for (final button in board.buttons) {
        // Ignoramos botones de navegación para los resultados directos
        if (button.actionType == ButtonActionType.backToHome) continue;

        if (button.label.toLowerCase().contains(cleanQuery)) {
          final steps = _findPathToBoard(board.id, button);
          if (steps != null) {
            results.add(WordPathResult(
              targetButton: button,
              steps: steps,
            ));
          }
        }
      }
    }

    return results;
  }

  List<WordPathStep>? _findPathToBoard(String targetBoardId, AACButton targetButton) {
    // Si la palabra está en el tablero de Inicio
    if (targetBoardId == 'home_board') {
      return [
        WordPathStep(
          boardId: 'home_board',
          boardName: 'Inicio',
          targetButton: targetButton,
        )
      ];
    }

    // Si está en una subcarpeta, buscar qué botón en Inicio lleva a ese tablero
    final homeBoard = boards['home_board'];
    if (homeBoard != null) {
      for (final button in homeBoard.buttons) {
        if (button.actionType == ButtonActionType.navigateToBoard &&
            button.targetBoardId == targetBoardId) {
          return [
            WordPathStep(
              boardId: 'home_board',
              boardName: 'Inicio',
              targetButton: button,
            ),
            WordPathStep(
              boardId: targetBoardId,
              boardName: boards[targetBoardId]?.name ?? '',
              targetButton: targetButton,
            ),
          ];
        }
      }
    }

    return null;
  }
}
