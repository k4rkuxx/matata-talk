import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/aac_board.dart';
import '../models/aac_button.dart';
import '../models/button_action.dart';
import '../models/part_of_speech.dart';

/// Resultado de la importación de un paquete .obz (Open Board Zip)
class OpenBoardPackage {
  final String rootBoardId;
  final Map<String, AACBoard> boards;

  const OpenBoardPackage({
    required this.rootBoardId,
    required this.boards,
  });
}

/// Servicio para importación y exportación según el estándar Open Board Format (.obf / .obz)
class OpenBoardService {
  static const String formatVersion = 'open-board-0.1';

  /// Serializa un [AACBoard] individual al formato JSON .obf estándar
  static String exportBoardToObfJson(AACBoard board) {
    final Map<String, dynamic> obfMap = {
      'format': formatVersion,
      'id': board.id,
      'name': board.name,
      'locale': 'es',
      'grid': {
        'rows': board.rows,
        'columns': board.columns,
        'order': _generateGridOrder(board),
      },
      'buttons': board.buttons.map((btn) => _buttonToObfJson(btn)).toList(),
      'images': board.buttons
          .where((btn) => btn.arasaacId != null || btn.symbolAssetPath != null)
          .map((btn) => _imageToObfJson(btn))
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(obfMap);
  }

  /// Empaqueta una colección de tableros en un archivo binario comprimido .obz estándar
  static Uint8List exportBoardsToObzBytes(
    Map<String, AACBoard> boards, {
    String rootBoardId = 'home_board',
  }) {
    final archive = Archive();

    // 1. Crear manifest.json
    final manifest = {
      'format': formatVersion,
      'root': 'boards/$rootBoardId.obf',
      'paths': {
        'boards': 'boards',
        'images': 'images',
      },
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

    // 2. Agregar cada tablero en /boards/*.obf
    for (final entry in boards.entries) {
      final obfJson = exportBoardToObfJson(entry.value);
      final bytes = utf8.encode(obfJson);
      archive.addFile(ArchiveFile('boards/${entry.key}.obf', bytes.length, bytes));
    }

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }

  /// Deserializa una cadena JSON .obf a un [AACBoard]
  static AACBoard importFromObfJson(String jsonContent) {
    final Map<String, dynamic> data = jsonDecode(jsonContent) as Map<String, dynamic>;
    final boardId = data['id'] as String? ?? 'imported_board_${DateTime.now().millisecondsSinceEpoch}';
    final boardName = data['name'] as String? ?? 'Tablero Importado';

    final gridData = data['grid'] as Map<String, dynamic>? ?? {};
    final rows = (gridData['rows'] as num?)?.toInt() ?? 4;
    final columns = (gridData['columns'] as num?)?.toInt() ?? 6;
    final dynamic rawOrder = gridData['order'];

    final rawButtons = data['buttons'] as List<dynamic>? ?? [];
    final Map<String, Map<String, dynamic>> buttonsById = {};
    for (final b in rawButtons) {
      if (b is Map<String, dynamic> && b['id'] != null) {
        buttonsById[b['id'].toString()] = b;
      }
    }

    final List<AACButton> parsedButtons = [];

    // Si el OBF define una cuadrícula ordenada bidimensional
    if (rawOrder is List && rawOrder.isNotEmpty) {
      for (int r = 0; r < rawOrder.length; r++) {
        final rowItem = rawOrder[r];
        if (rowItem is List) {
          for (int c = 0; c < rowItem.length; c++) {
            final buttonId = rowItem[c]?.toString();
            if (buttonId != null && buttonsById.containsKey(buttonId)) {
              parsedButtons.add(_parseObfButton(buttonsById[buttonId]!, row: r, col: c));
            }
          }
        } else if (rowItem != null) {
          // Orden plano 1D
          final row = r ~/ columns;
          final col = r % columns;
          final buttonId = rowItem.toString();
          if (buttonsById.containsKey(buttonId)) {
            parsedButtons.add(_parseObfButton(buttonsById[buttonId]!, row: row, col: col));
          }
        }
      }
    } else {
      // Fallback: indexar por lista de botones secuencial
      for (int i = 0; i < rawButtons.length; i++) {
        final b = rawButtons[i];
        if (b is Map<String, dynamic>) {
          final row = i ~/ columns;
          final col = i % columns;
          parsedButtons.add(_parseObfButton(b, row: row, col: col));
        }
      }
    }

    return AACBoard(
      id: boardId,
      name: boardName,
      rows: rows,
      columns: columns,
      buttons: parsedButtons,
    );
  }

  /// Deserializa un archivo comprimido .obz a un [OpenBoardPackage]
  static OpenBoardPackage importFromObzBytes(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final Map<String, AACBoard> boards = {};
    String rootBoardId = 'home_board';

    // 1. Buscar manifest.json
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile != null) {
      try {
        final manifestStr = utf8.decode(manifestFile.content as List<int>);
        final manifestData = jsonDecode(manifestStr) as Map<String, dynamic>;
        final rootPath = manifestData['root'] as String? ?? '';
        rootBoardId = rootPath.replaceAll('boards/', '').replaceAll('.obf', '');
      } catch (_) {}
    }

    // 2. Extraer todos los archivos .obf dentro del archivo ZIP
    for (final file in archive.files) {
      if (file.name.endsWith('.obf') && file.isFile) {
        try {
          final obfStr = utf8.decode(file.content as List<int>);
          final board = importFromObfJson(obfStr);
          boards[board.id] = board;
        } catch (_) {}
      }
    }

    if (boards.isEmpty) {
      throw const FormatException('El archivo .obz no contiene tableros .obf válidos.');
    }

    if (!boards.containsKey(rootBoardId)) {
      rootBoardId = boards.keys.first;
    }

    return OpenBoardPackage(
      rootBoardId: rootBoardId,
      boards: boards,
    );
  }

  // --- Mapeos Auxiliares ---

  static List<List<String?>> _generateGridOrder(AACBoard board) {
    final List<List<String?>> order = [];
    for (int r = 0; r < board.rows; r++) {
      final List<String?> rowList = [];
      for (int c = 0; c < board.columns; c++) {
        final btn = board.getButtonAt(r, c);
        rowList.add(btn?.id);
      }
      order.add(rowList);
    }
    return order;
  }

  static Map<String, dynamic> _buttonToObfJson(AACButton btn) {
    final Map<String, dynamic> json = {
      'id': btn.id,
      'label': btn.label,
      'vocalization': btn.vocalizationText,
      'ext_part_of_speech': btn.partOfSpeech.name,
      'ext_arasaac_id': btn.arasaacId,
    };

    if (btn.iconEmoji != null) {
      json['ext_icon_emoji'] = btn.iconEmoji;
    }

    if (btn.actionType == ButtonActionType.navigateToBoard && btn.targetBoardId != null) {
      json['load_board'] = {
        'id': btn.targetBoardId,
        'path': 'boards/${btn.targetBoardId}.obf',
      };
    } else if (btn.actionType == ButtonActionType.backToHome) {
      json['load_board'] = {
        'id': 'home_board',
      };
    }

    return json;
  }

  static Map<String, dynamic> _imageToObfJson(AACButton btn) {
    return {
      'id': 'img_${btn.id}',
      'ext_arasaac_id': btn.arasaacId,
      'symbol_asset_path': btn.symbolAssetPath,
      'url': btn.arasaacId != null
          ? 'https://static.arasaac.org/pictograms/${btn.arasaacId}/${btn.arasaacId}_500.png'
          : null,
    };
  }

  static AACButton _parseObfButton(Map<String, dynamic> json, {required int row, required int col}) {
    final id = json['id']?.toString() ?? 'btn_${row}_$col';
    final label = json['label']?.toString() ?? '';
    final vocalization = json['vocalization']?.toString();
    final emoji = json['ext_icon_emoji']?.toString();
    final arasaacId = (json['ext_arasaac_id'] as num?)?.toInt();

    // Detección de navegación
    ButtonActionType actionType = ButtonActionType.speakAndAddToMessage;
    String? targetBoardId;

    if (json['load_board'] is Map) {
      final loadBoardMap = json['load_board'] as Map<String, dynamic>;
      targetBoardId = loadBoardMap['id']?.toString();
      if (targetBoardId == 'home_board' || targetBoardId == 'home') {
        actionType = ButtonActionType.backToHome;
      } else {
        actionType = ButtonActionType.navigateToBoard;
      }
    }

    // Parte de la oración
    PartOfSpeech partOfSpeech = PartOfSpeech.misc;
    final posStr = json['ext_part_of_speech']?.toString();
    if (posStr != null) {
      partOfSpeech = PartOfSpeech.values.firstWhere(
        (p) => p.name.toLowerCase() == posStr.toLowerCase(),
        orElse: () => PartOfSpeech.misc,
      );
    }

    return AACButton(
      id: id,
      row: row,
      col: col,
      label: label,
      vocalizationText: vocalization,
      iconEmoji: emoji,
      arasaacId: arasaacId,
      partOfSpeech: partOfSpeech,
      actionType: actionType,
      targetBoardId: targetBoardId,
    );
  }
}
