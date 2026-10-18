import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../data/datasources/phrase_datasource.dart';
import '../../data/datasources/scanning_datasource.dart';
import '../../data/datasources/settings_datasource.dart';
import '../../data/datasources/head_pointer_datasource.dart';
import '../models/aac_board.dart';
import '../models/backup_data.dart';
import '../models/head_pointer_settings.dart';
import '../models/phrase_history_item.dart';
import '../models/quick_phrase.dart';
import '../models/scanning_settings.dart';
import '../models/touch_settings.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../repositories/vocabulary_repository.dart';

/// Servicio integral para la creación, inspección y restauración de respaldos de MatataTalk
class BackupRestoreService {
  final VocabularyRepository vocabularyRepository;
  final ProfileRepository profileRepository;
  final PhraseDataSource phraseDataSource;
  final SettingsDataSource settingsDataSource;
  final ScanningDataSource scanningDataSource;
  final HeadPointerDataSource headPointerDataSource;

  BackupRestoreService({
    required this.vocabularyRepository,
    required this.profileRepository,
    required this.phraseDataSource,
    required this.settingsDataSource,
    required this.scanningDataSource,
    required this.headPointerDataSource,
  });

  /// Empaqueta todos los datos de MatataTalk en un archivo comprimido .matata (formato ZIP)
  Future<Uint8List> createBackupBytes({String notes = ''}) async {
    final now = DateTime.now();

    // 1. Obtener Perfiles
    final profiles = await profileRepository.getAllProfiles();
    final activeProfileId = await profileRepository.getActiveProfileId();
    final activeProfile = profiles.firstWhere(
      (p) => p.id == activeProfileId,
      orElse: () => profiles.isNotEmpty ? profiles.first : UserProfile.defaultProfile(),
    );

    // 2. Obtener Tableros
    final boards = await vocabularyRepository.getAllBoards();

    // 3. Obtener Frases e Historial
    final customPhrases = await phraseDataSource.getCustomPhrasesOnly();
    final history = await phraseDataSource.getPhraseHistory();
    final favorites = await phraseDataSource.getFavoriteTexts();

    // 4. Obtener Ajustes Globales
    final touchSettings = await settingsDataSource.getTouchSettings();
    final scanningSettings = await scanningDataSource.getScanningSettings();
    final headPointerSettings = await headPointerDataSource.getSettings();

    // 5. Crear Manifiesto
    final manifest = BackupManifest(
      createdAt: now,
      profilesCount: profiles.length,
      boardsCount: boards.length,
      customPhrasesCount: customPhrases.length,
      historyCount: history.length,
      activeProfileName: activeProfile.name,
      notes: notes,
    );

    // 6. Construir Archivo ZIP con Archive
    final archive = Archive();

    // a. manifest.json
    final manifestJson = const JsonEncoder.withIndent('  ').convert(manifest.toJson());
    final manifestBytes = utf8.encode(manifestJson);
    archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

    // b. profiles.json
    final profilesData = {
      'activeProfileId': activeProfileId,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    };
    final profilesJson = jsonEncode(profilesData);
    final profilesBytes = utf8.encode(profilesJson);
    archive.addFile(ArchiveFile('profiles.json', profilesBytes.length, profilesBytes));

    // c. boards.json
    final boardsData = boards.map((id, b) => MapEntry(id, b.toJson()));
    final boardsJson = jsonEncode(boardsData);
    final boardsBytes = utf8.encode(boardsJson);
    archive.addFile(ArchiveFile('boards.json', boardsBytes.length, boardsBytes));

    // d. phrases.json
    final phrasesData = {
      'customPhrases': customPhrases.map((p) => p.toJson()).toList(),
      'history': history.map((h) => h.toJson()).toList(),
      'favorites': favorites.toList(),
    };
    final phrasesJson = jsonEncode(phrasesData);
    final phrasesBytes = utf8.encode(phrasesJson);
    archive.addFile(ArchiveFile('phrases.json', phrasesBytes.length, phrasesBytes));

    // e. settings.json
    final settingsData = {
      'touchSettings': touchSettings.toJson(),
      'scanningSettings': scanningSettings.toJson(),
      'headPointerSettings': headPointerSettings.toJson(),
    };
    final settingsJson = jsonEncode(settingsData);
    final settingsBytes = utf8.encode(settingsJson);
    archive.addFile(ArchiveFile('settings.json', settingsBytes.length, settingsBytes));

    // 7. Comprimir
    final zipBytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipBytes);
  }

  /// Lee rápidamente el manifiesto de un archivo de respaldo para vista previa clínica
  static BackupManifest inspectManifestFromBytes(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        throw const FormatException('El archivo no contiene un manifiesto "manifest.json" de MatataTalk.');
      }
      final str = utf8.decode(manifestFile.content as List<int>);
      final map = jsonDecode(str) as Map<String, dynamic>;
      return BackupManifest.fromJson(map);
    } catch (e) {
      throw FormatException('Formato de respaldo no válido o archivo dañado: $e');
    }
  }

  /// Extrae y deserializa completamente los datos del respaldo en memoria
  static BackupData parseBackupDataFromBytes(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    // 1. Manifiesto
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw const FormatException('El archivo no contiene un manifiesto "manifest.json" de MatataTalk.');
    }
    final manifestStr = utf8.decode(manifestFile.content as List<int>);
    final manifest = BackupManifest.fromJson(jsonDecode(manifestStr) as Map<String, dynamic>);

    // 2. Perfiles
    final List<UserProfile> profiles = [];
    String activeProfileId = 'profile_default';
    final profilesFile = archive.findFile('profiles.json');
    if (profilesFile != null) {
      try {
        final pStr = utf8.decode(profilesFile.content as List<int>);
        final pData = jsonDecode(pStr) as Map<String, dynamic>;
        activeProfileId = pData['activeProfileId'] as String? ?? 'profile_default';
        final list = pData['profiles'] as List<dynamic>? ?? [];
        for (final item in list) {
          profiles.add(UserProfile.fromJson(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    // 3. Tableros
    final Map<String, AACBoard> boards = {};
    final boardsFile = archive.findFile('boards.json');
    if (boardsFile != null) {
      try {
        final bStr = utf8.decode(boardsFile.content as List<int>);
        final bData = jsonDecode(bStr) as Map<String, dynamic>;
        for (final entry in bData.entries) {
          boards[entry.key] = AACBoard.fromJson(entry.value as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    // 4. Frases
    final List<QuickPhrase> customPhrases = [];
    final List<PhraseHistoryItem> history = [];
    final Set<String> favorites = {};
    final phrasesFile = archive.findFile('phrases.json');
    if (phrasesFile != null) {
      try {
        final phStr = utf8.decode(phrasesFile.content as List<int>);
        final phData = jsonDecode(phStr) as Map<String, dynamic>;
        for (final item in (phData['customPhrases'] as List<dynamic>? ?? [])) {
          customPhrases.add(QuickPhrase.fromJson(item as Map<String, dynamic>));
        }
        for (final item in (phData['history'] as List<dynamic>? ?? [])) {
          history.add(PhraseHistoryItem.fromJson(item as Map<String, dynamic>));
        }
        for (final fav in (phData['favorites'] as List<dynamic>? ?? [])) {
          favorites.add(fav.toString());
        }
      } catch (_) {}
    }

    // 5. Ajustes
    TouchSettings touchSettings = TouchSettings.standard();
    ScanningSettings scanningSettings = ScanningSettings.standard();
    HeadPointerSettings headPointerSettings = HeadPointerSettings.standard();
    final settingsFile = archive.findFile('settings.json');
    if (settingsFile != null) {
      try {
        final sStr = utf8.decode(settingsFile.content as List<int>);
        final sData = jsonDecode(sStr) as Map<String, dynamic>;
        if (sData['touchSettings'] != null) {
          touchSettings = TouchSettings.fromJson(sData['touchSettings'] as Map<String, dynamic>);
        }
        if (sData['scanningSettings'] != null) {
          scanningSettings = ScanningSettings.fromJson(sData['scanningSettings'] as Map<String, dynamic>);
        }
        if (sData['headPointerSettings'] != null) {
          headPointerSettings = HeadPointerSettings.fromJson(sData['headPointerSettings'] as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    return BackupData(
      manifest: manifest,
      profiles: profiles,
      activeProfileId: activeProfileId,
      boards: boards,
      customPhrases: customPhrases,
      history: history,
      favorites: favorites,
      touchSettings: touchSettings,
      scanningSettings: scanningSettings,
      headPointerSettings: headPointerSettings,
    );
  }

  /// Restaura los datos en la base de datos y almacenes locales
  Future<BackupRestoreResult> restoreBackup(
    BackupData data, {
    bool overwrite = true,
  }) async {
    try {
      // 1. Restaurar Tableros
      if (data.boards.isNotEmpty) {
        await vocabularyRepository.saveAllBoards(data.boards);
      }

      // 2. Restaurar Perfiles
      for (final profile in data.profiles) {
        await profileRepository.saveProfile(profile);
      }
      if (data.activeProfileId.isNotEmpty) {
        await profileRepository.setActiveProfileId(data.activeProfileId);
      }

      // 3. Restaurar Frases e Historial
      await phraseDataSource.restoreAll(
        customPhrases: data.customPhrases,
        history: data.history,
        favorites: data.favorites,
        overwrite: overwrite,
      );

      // 4. Restaurar Ajustes Globales
      await settingsDataSource.saveTouchSettings(data.touchSettings);
      await scanningDataSource.saveScanningSettings(data.scanningSettings);
      await headPointerDataSource.saveSettings(data.headPointerSettings);

      return BackupRestoreResult(
        success: true,
        profilesRestored: data.profiles.length,
        boardsRestored: data.boards.length,
        phrasesRestored: data.customPhrases.length,
        activeProfileName: data.manifest.activeProfileName,
      );
    } catch (e) {
      return BackupRestoreResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}
