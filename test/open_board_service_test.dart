import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:matata_talk/domain/models/aac_board.dart';
import 'package:matata_talk/domain/models/aac_button.dart';
import 'package:matata_talk/domain/models/button_action.dart';
import 'package:matata_talk/domain/models/part_of_speech.dart';
import 'package:matata_talk/domain/services/open_board_service.dart';

void main() {
  group('OpenBoardService Tests', () {
    const testBoard = AACBoard(
      id: 'test_board_1',
      name: 'Tablero de Prueba',
      rows: 2,
      columns: 3,
      buttons: [
        AACButton(
          id: 'btn_1',
          row: 0,
          col: 0,
          label: 'Hola',
          iconEmoji: '👋',
          arasaacId: 6023,
          partOfSpeech: PartOfSpeech.social,
        ),
        AACButton(
          id: 'btn_2',
          row: 0,
          col: 1,
          label: 'Quiero',
          iconEmoji: '🤲',
          arasaacId: 27230,
          partOfSpeech: PartOfSpeech.verb,
        ),
        AACButton(
          id: 'btn_folder',
          row: 1,
          col: 2,
          label: 'Comida',
          iconEmoji: '🍎',
          arasaacId: 2373,
          partOfSpeech: PartOfSpeech.noun,
          actionType: ButtonActionType.navigateToBoard,
          targetBoardId: 'food_board',
        ),
      ],
    );

    test('exportBoardToObfJson creates valid Open Board Format json', () {
      final jsonStr = OpenBoardService.exportBoardToObfJson(testBoard);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['format'], 'open-board-0.1');
      expect(decoded['id'], 'test_board_1');
      expect(decoded['name'], 'Tablero de Prueba');
      expect(decoded['grid']['rows'], 2);
      expect(decoded['grid']['columns'], 3);

      final buttons = decoded['buttons'] as List;
      expect(buttons.length, 3);
      expect(buttons[0]['label'], 'Hola');
      expect(buttons[0]['ext_arasaac_id'], 6023);
      expect(buttons[2]['load_board']['id'], 'food_board');
    });

    test('importFromObfJson restores AACBoard accurately', () {
      final jsonStr = OpenBoardService.exportBoardToObfJson(testBoard);
      final importedBoard = OpenBoardService.importFromObfJson(jsonStr);

      expect(importedBoard.id, testBoard.id);
      expect(importedBoard.name, testBoard.name);
      expect(importedBoard.rows, testBoard.rows);
      expect(importedBoard.columns, testBoard.columns);
      expect(importedBoard.buttons.length, 3);

      final folderBtn = importedBoard.buttons.firstWhere((b) => b.id == 'btn_folder');
      expect(folderBtn.actionType, ButtonActionType.navigateToBoard);
      expect(folderBtn.targetBoardId, 'food_board');
      expect(folderBtn.partOfSpeech, PartOfSpeech.noun);
    });

    test('exportBoardsToObzBytes and importFromObzBytes full roundtrip', () {
      final boardsMap = {
        'test_board_1': testBoard,
        'food_board': const AACBoard(
          id: 'food_board',
          name: 'Comida',
          rows: 2,
          columns: 2,
          buttons: [
            AACButton(
              id: 'btn_manzana',
              row: 0,
              col: 0,
              label: 'Manzana',
              iconEmoji: '🍎',
              arasaacId: 2455,
              partOfSpeech: PartOfSpeech.noun,
            ),
          ],
        ),
      };

      final obzBytes = OpenBoardService.exportBoardsToObzBytes(
        boardsMap,
        rootBoardId: 'test_board_1',
      );

      expect(obzBytes.isNotEmpty, true);

      final package = OpenBoardService.importFromObzBytes(obzBytes);
      expect(package.rootBoardId, 'test_board_1');
      expect(package.boards.length, 2);
      expect(package.boards.containsKey('test_board_1'), true);
      expect(package.boards.containsKey('food_board'), true);
      expect(package.boards['food_board']!.buttons.first.label, 'Manzana');
    });
  });
}
