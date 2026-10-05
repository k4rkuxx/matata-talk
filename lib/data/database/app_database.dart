import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../domain/models/aac_board.dart';
import '../../domain/models/aac_button.dart';
import '../../domain/models/button_action.dart';
import '../../domain/models/part_of_speech.dart';
import '../datasources/default_vocabulary.dart';

class AppDatabase {
  static const String _dbName = 'matata_talk.db';
  static const int _dbVersion = 2;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Habilitar claves foráneas
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Resincronizar el vocabulario con las nuevas definiciones por defecto
      await db.delete('buttons');
      await db.delete('boards');
      try {
        await db.delete('vocabulary_fts');
      } catch (_) {}
      await _seedDefaultVocabulary(db);
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla de Tableros (Boards)
    await db.execute('''
      CREATE TABLE boards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rows INTEGER NOT NULL,
        columns INTEGER NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 1,
        parent_board_id TEXT
      );
    ''');

    // 2. Tabla de Botones / Pictogramas (Buttons)
    await db.execute('''
      CREATE TABLE buttons (
        id TEXT PRIMARY KEY,
        board_id TEXT NOT NULL,
        row INTEGER NOT NULL,
        col INTEGER NOT NULL,
        label TEXT NOT NULL,
        vocalization_text TEXT,
        icon_emoji TEXT,
        symbol_asset_path TEXT,
        arasaac_id INTEGER,
        part_of_speech TEXT NOT NULL,
        action_type TEXT NOT NULL,
        target_board_id TEXT,
        FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE
      );
    ''');

    // 3. Índice para búsquedas rápidas por tablero y posición
    await db.execute('''
      CREATE INDEX idx_buttons_board ON buttons(board_id);
    ''');
    await db.execute('''
      CREATE INDEX idx_buttons_label ON buttons(label);
    ''');

    // 4. Tabla virtual de búsqueda rápida de vocabulario (FTS)
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE vocabulary_fts USING fts4(
          button_id TEXT,
          label TEXT,
          board_id TEXT,
          board_name TEXT
        );
      ''');
    } catch (_) {
      // Fallback si SQLite en la plataforma no soporta FTS
    }

    // 5. Poblar con el vocabulario clínico por defecto
    await _seedDefaultVocabulary(db);
  }

  static Future<void> _seedDefaultVocabulary(Database db) async {
    final boards = DefaultVocabulary.allBoards;

    for (final board in boards.values) {
      await db.insert(
        'boards',
        {
          'id': board.id,
          'name': board.name,
          'rows': board.rows,
          'columns': board.columns,
          'is_system': 1,
          'parent_board_id': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final button in board.buttons) {
        await db.insert(
          'buttons',
          {
            'id': button.id,
            'board_id': board.id,
            'row': button.row,
            'col': button.col,
            'label': button.label,
            'vocalization_text': button.vocalizationText,
            'icon_emoji': button.iconEmoji,
            'symbol_asset_path': button.symbolAssetPath,
            'arasaac_id': button.arasaacId,
            'part_of_speech': button.partOfSpeech.name,
            'action_type': button.actionType.name,
            'target_board_id': button.targetBoardId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        try {
          await db.insert(
            'vocabulary_fts',
            {
              'button_id': button.id,
              'label': button.label.toLowerCase(),
              'board_id': board.id,
              'board_name': board.name,
            },
          );
        } catch (_) {}
      }
    }
  }

  // --- CONSULTAS Y MÉTODOS PÚBLICOS ---

  /// Obtiene todos los tableros con sus botones correspondientes
  static Future<Map<String, AACBoard>> getAllBoards() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> boardRows = await db.query('boards');
      final Map<String, AACBoard> result = {};

      for (final bRow in boardRows) {
        final boardId = bRow['id'] as String;
        final List<Map<String, dynamic>> buttonRows = await db.query(
          'buttons',
          where: 'board_id = ?',
          whereArgs: [boardId],
          orderBy: 'row ASC, col ASC',
        );

        final List<AACButton> buttons = buttonRows.map((r) => _mapToButton(r)).toList();

        result[boardId] = AACBoard(
          id: boardId,
          name: bRow['name'] as String,
          rows: bRow['rows'] as int,
          columns: bRow['columns'] as int,
          buttons: buttons,
        );
      }

      if (result.isNotEmpty) return result;
    } catch (_) {}

    // Fallback seguro a DefaultVocabulary en memoria
    return DefaultVocabulary.allBoards;
  }

  /// Obtiene un tablero específico por su ID
  static Future<AACBoard?> getBoard(String boardId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> boardRows = await db.query(
        'boards',
        where: 'id = ?',
        whereArgs: [boardId],
        limit: 1,
      );

      if (boardRows.isEmpty) return DefaultVocabulary.getBoardById(boardId);

      final bRow = boardRows.first;
      final List<Map<String, dynamic>> buttonRows = await db.query(
        'buttons',
        where: 'board_id = ?',
        whereArgs: [boardId],
        orderBy: 'row ASC, col ASC',
      );

      final List<AACButton> buttons = buttonRows.map((r) => _mapToButton(r)).toList();

      return AACBoard(
        id: boardId,
        name: bRow['name'] as String,
        rows: bRow['rows'] as int,
        columns: bRow['columns'] as int,
        buttons: buttons,
      );
    } catch (_) {
      return DefaultVocabulary.getBoardById(boardId);
    }
  }

  /// Guarda o actualiza un tablero completo con todos sus botones
  static Future<void> saveBoard(AACBoard board) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.insert(
          'boards',
          {
            'id': board.id,
            'name': board.name,
            'rows': board.rows,
            'columns': board.columns,
            'is_system': 0,
            'parent_board_id': null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Limpiar botones antiguos de este tablero
        await txn.delete('buttons', where: 'board_id = ?', whereArgs: [board.id]);
        try {
          await txn.delete('vocabulary_fts', where: 'board_id = ?', whereArgs: [board.id]);
        } catch (_) {}

        for (final button in board.buttons) {
          await txn.insert(
            'buttons',
            {
              'id': button.id,
              'board_id': board.id,
              'row': button.row,
              'col': button.col,
              'label': button.label,
              'vocalization_text': button.vocalizationText,
              'icon_emoji': button.iconEmoji,
              'symbol_asset_path': button.symbolAssetPath,
              'arasaac_id': button.arasaacId,
              'part_of_speech': button.partOfSpeech.name,
              'action_type': button.actionType.name,
              'target_board_id': button.targetBoardId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          try {
            await txn.insert(
              'vocabulary_fts',
              {
                'button_id': button.id,
                'label': button.label.toLowerCase(),
                'board_id': board.id,
                'board_name': board.name,
              },
            );
          } catch (_) {}
        }
      });
    } catch (_) {}
  }

  /// Guarda una colección completa de tableros
  static Future<void> saveAllBoards(Map<String, AACBoard> boards) async {
    for (final board in boards.values) {
      await saveBoard(board);
    }
  }

  /// Inserta o actualiza un botón en un tablero
  static Future<void> saveButton(String boardId, AACButton button) async {
    try {
      final db = await database;
      await db.insert(
        'buttons',
        {
          'id': button.id,
          'board_id': boardId,
          'row': button.row,
          'col': button.col,
          'label': button.label,
          'vocalization_text': button.vocalizationText,
          'icon_emoji': button.iconEmoji,
          'symbol_asset_path': button.symbolAssetPath,
          'arasaac_id': button.arasaacId,
          'part_of_speech': button.partOfSpeech.name,
          'action_type': button.actionType.name,
          'target_board_id': button.targetBoardId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  static AACButton _mapToButton(Map<String, dynamic> r) {
    return AACButton(
      id: r['id'] as String,
      row: r['row'] as int,
      col: r['col'] as int,
      label: r['label'] as String,
      vocalizationText: r['vocalization_text'] as String?,
      iconEmoji: r['icon_emoji'] as String?,
      symbolAssetPath: r['symbol_asset_path'] as String?,
      arasaacId: r['arasaac_id'] as int?,
      partOfSpeech: PartOfSpeech.values.firstWhere(
        (p) => p.name == r['part_of_speech'],
        orElse: () => PartOfSpeech.misc,
      ),
      actionType: ButtonActionType.values.firstWhere(
        (a) => a.name == r['action_type'],
        orElse: () => ButtonActionType.speakAndAddToMessage,
      ),
      targetBoardId: r['target_board_id'] as String?,
    );
  }
}
