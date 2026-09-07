import '../../domain/models/aac_board.dart';
import '../../domain/models/aac_button.dart';
import '../../domain/models/button_action.dart';
import '../../domain/models/part_of_speech.dart';

class DefaultVocabulary {
  static const String homeBoardId = 'home_board';
  static const String foodBoardId = 'food_board';
  static const String actionsBoardId = 'actions_board';
  static const String feelingsBoardId = 'feelings_board';

  static AACBoard getHomeBoard() {
    return const AACBoard(
      id: homeBoardId,
      name: 'Inicio',
      rows: 4,
      columns: 6,
      buttons: [
        // Fila 0: Pronombres, Negación y Ayuda
        AACButton(
          id: 'btn_yo',
          row: 0,
          col: 0,
          label: 'Yo',
          iconEmoji: '👤',
          partOfSpeech: PartOfSpeech.pronoun,
        ),
        AACButton(
          id: 'btn_tu',
          row: 0,
          col: 1,
          label: 'Tú',
          iconEmoji: '👉',
          partOfSpeech: PartOfSpeech.pronoun,
        ),
        AACButton(
          id: 'btn_no',
          row: 0,
          col: 2,
          label: 'No',
          iconEmoji: '🚫',
          partOfSpeech: PartOfSpeech.important,
        ),
        AACButton(
          id: 'btn_si',
          row: 0,
          col: 3,
          label: 'Sí',
          iconEmoji: '✅',
          partOfSpeech: PartOfSpeech.social,
        ),
        AACButton(
          id: 'btn_mas',
          row: 0,
          col: 4,
          label: 'Más',
          iconEmoji: '➕',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        AACButton(
          id: 'btn_ayuda',
          row: 0,
          col: 5,
          label: 'Ayuda',
          iconEmoji: '🆘',
          partOfSpeech: PartOfSpeech.important,
        ),

        // Fila 1: Verbos Principales (Core Verbs)
        AACButton(
          id: 'btn_quiero',
          row: 1,
          col: 0,
          label: 'Quiero',
          iconEmoji: '🤲',
          partOfSpeech: PartOfSpeech.verb,
        ),
        AACButton(
          id: 'btn_ir',
          row: 1,
          col: 1,
          label: 'Ir',
          iconEmoji: '🚶',
          partOfSpeech: PartOfSpeech.verb,
        ),
        AACButton(
          id: 'btn_comer',
          row: 1,
          col: 2,
          label: 'Comer',
          iconEmoji: '🍽️',
          partOfSpeech: PartOfSpeech.verb,
        ),
        AACButton(
          id: 'btn_beber',
          row: 1,
          col: 3,
          label: 'Beber',
          iconEmoji: '🥤',
          partOfSpeech: PartOfSpeech.verb,
        ),
        AACButton(
          id: 'btn_jugar',
          row: 1,
          col: 4,
          label: 'Jugar',
          iconEmoji: '🧸',
          partOfSpeech: PartOfSpeech.verb,
        ),
        AACButton(
          id: 'btn_parar',
          row: 1,
          col: 5,
          label: 'Parar',
          iconEmoji: '🛑',
          partOfSpeech: PartOfSpeech.important,
        ),

        // Fila 2: Adjetivos y Estados
        AACButton(
          id: 'btn_bueno',
          row: 2,
          col: 0,
          label: 'Bueno',
          iconEmoji: '👍',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        AACButton(
          id: 'btn_malo',
          row: 2,
          col: 1,
          label: 'Malo',
          iconEmoji: '👎',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        AACButton(
          id: 'btn_feliz',
          row: 2,
          col: 2,
          label: 'Feliz',
          iconEmoji: '😊',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        AACButton(
          id: 'btn_triste',
          row: 2,
          col: 3,
          label: 'Triste',
          iconEmoji: '😢',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        AACButton(
          id: 'btn_grande',
          row: 2,
          col: 4,
          label: 'Grande',
          iconEmoji: '🐘',
          partOfSpeech: PartOfSpeech.adjective,
        ),
        AACButton(
          id: 'btn_pequeno',
          row: 2,
          col: 5,
          label: 'Pequeño',
          iconEmoji: '🐜',
          partOfSpeech: PartOfSpeech.adjective,
        ),

        // Fila 3: Carpetas y Categorías (Fringe Navigation)
        AACButton(
          id: 'btn_folder_comida',
          row: 3,
          col: 0,
          label: 'Comida 📁',
          iconEmoji: '🍎',
          partOfSpeech: PartOfSpeech.noun,
          actionType: ButtonActionType.navigateToBoard,
          targetBoardId: foodBoardId,
        ),
        AACButton(
          id: 'btn_folder_acciones',
          row: 3,
          col: 1,
          label: 'Acciones 📁',
          iconEmoji: '🏃',
          partOfSpeech: PartOfSpeech.verb,
          actionType: ButtonActionType.navigateToBoard,
          targetBoardId: actionsBoardId,
        ),
        AACButton(
          id: 'btn_folder_emociones',
          row: 3,
          col: 2,
          label: 'Emociones 📁',
          iconEmoji: '❤️',
          partOfSpeech: PartOfSpeech.social,
          actionType: ButtonActionType.navigateToBoard,
          targetBoardId: feelingsBoardId,
        ),
        AACButton(
          id: 'btn_bano',
          row: 3,
          col: 3,
          label: 'Baño',
          iconEmoji: '🚽',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_hola',
          row: 3,
          col: 4,
          label: 'Hola',
          iconEmoji: '👋',
          partOfSpeech: PartOfSpeech.social,
        ),
        AACButton(
          id: 'btn_gracias',
          row: 3,
          col: 5,
          label: 'Gracias',
          iconEmoji: '🙏',
          partOfSpeech: PartOfSpeech.social,
        ),
      ],
    );
  }

  static AACBoard getFoodBoard() {
    return const AACBoard(
      id: foodBoardId,
      name: 'Comida',
      rows: 4,
      columns: 6,
      buttons: [
        // Botón para volver siempre en la misma posición (0,0)
        AACButton(
          id: 'btn_back_home',
          row: 0,
          col: 0,
          label: '⬅ Inicio',
          iconEmoji: '🏠',
          partOfSpeech: PartOfSpeech.misc,
          actionType: ButtonActionType.backToHome,
        ),
        AACButton(
          id: 'btn_agua',
          row: 0,
          col: 1,
          label: 'Agua',
          iconEmoji: '💧',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_leche',
          row: 0,
          col: 2,
          label: 'Leche',
          iconEmoji: '🥛',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_jugo',
          row: 0,
          col: 3,
          label: 'Jugo',
          iconEmoji: '🧃',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_manzana',
          row: 1,
          col: 0,
          label: 'Manzana',
          iconEmoji: '🍎',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_platano',
          row: 1,
          col: 1,
          label: 'Plátano',
          iconEmoji: '🍌',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_pan',
          row: 1,
          col: 2,
          label: 'Pan',
          iconEmoji: '🍞',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_galleta',
          row: 1,
          col: 3,
          label: 'Galleta',
          iconEmoji: '🍪',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_pizza',
          row: 2,
          col: 0,
          label: 'Pizza',
          iconEmoji: '🍕',
          partOfSpeech: PartOfSpeech.noun,
        ),
        AACButton(
          id: 'btn_pasta',
          row: 2,
          col: 1,
          label: 'Pasta',
          iconEmoji: '🍝',
          partOfSpeech: PartOfSpeech.noun,
        ),
      ],
    );
  }
}
