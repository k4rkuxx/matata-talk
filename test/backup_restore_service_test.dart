import 'package:flutter_test/flutter_test.dart';
import 'package:matata_talk/data/datasources/phrase_datasource.dart';
import 'package:matata_talk/data/datasources/scanning_datasource.dart';
import 'package:matata_talk/data/datasources/settings_datasource.dart';
import 'package:matata_talk/data/datasources/head_pointer_datasource.dart';
import 'package:matata_talk/domain/models/aac_board.dart';
import 'package:matata_talk/domain/models/aac_button.dart';
import 'package:matata_talk/domain/models/head_pointer_settings.dart';
import 'package:matata_talk/domain/models/part_of_speech.dart';
import 'package:matata_talk/domain/models/phrase_history_item.dart';
import 'package:matata_talk/domain/models/quick_phrase.dart';
import 'package:matata_talk/domain/models/quick_phrase_category.dart';
import 'package:matata_talk/domain/models/scanning_settings.dart';
import 'package:matata_talk/domain/models/touch_settings.dart';
import 'package:matata_talk/domain/models/user_profile.dart';
import 'package:matata_talk/domain/repositories/profile_repository.dart';
import 'package:matata_talk/domain/repositories/vocabulary_repository.dart';
import 'package:matata_talk/domain/services/backup_restore_service.dart';

// --- IN-MEMORY FAKES FOR TESTING ---
class FakeVocabularyRepository implements VocabularyRepository {
  Map<String, AACBoard> boards = {};

  @override
  Future<Map<String, AACBoard>> getAllBoards() async => Map.from(boards);

  @override
  Future<AACBoard?> getBoard(String boardId) async => boards[boardId];

  @override
  Future<void> saveBoard(AACBoard board) async {
    boards[board.id] = board;
  }

  @override
  Future<void> saveButton(String boardId, AACButton button) async {}

  @override
  Future<void> saveAllBoards(Map<String, AACBoard> newBoards) async {
    boards = Map.from(newBoards);
  }
}

class FakeProfileRepository implements ProfileRepository {
  List<UserProfile> profiles = [];
  String activeId = 'profile_default';

  @override
  Future<List<UserProfile>> getAllProfiles() async => List.from(profiles);

  @override
  Future<UserProfile?> getProfile(String id) async {
    try {
      return profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    profiles.removeWhere((p) => p.id == profile.id);
    profiles.add(profile);
  }

  @override
  Future<bool> deleteProfile(String id) async {
    profiles.removeWhere((p) => p.id == id);
    return true;
  }

  @override
  Future<String> getActiveProfileId() async => activeId;

  @override
  Future<void> setActiveProfileId(String id) async {
    activeId = id;
  }
}

class FakePhraseDataSource implements PhraseDataSource {
  List<QuickPhrase> customPhrases = [];
  List<PhraseHistoryItem> history = [];
  Set<String> favorites = {};

  @override
  Future<List<QuickPhrase>> getQuickPhrases() async => List.from(customPhrases);

  @override
  Future<List<QuickPhrase>> getCustomPhrasesOnly() async => List.from(customPhrases);

  @override
  Future<void> saveCustomQuickPhrase(QuickPhrase phrase) async {
    customPhrases.add(phrase);
  }

  @override
  Future<void> deleteCustomQuickPhrase(String phraseId) async {
    customPhrases.removeWhere((p) => p.id == phraseId);
  }

  @override
  Future<List<PhraseHistoryItem>> getPhraseHistory() async => List.from(history);

  @override
  Future<void> savePhraseHistoryItem(PhraseHistoryItem item) async {
    history.add(item);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    history.removeWhere((h) => h.id == id);
  }

  @override
  Future<void> clearHistory() async {
    history.clear();
  }

  @override
  Future<void> toggleFavorite(String text) async {
    if (favorites.contains(text)) {
      favorites.remove(text);
    } else {
      favorites.add(text);
    }
  }

  @override
  Future<Set<String>> getFavoriteTexts() async => Set.from(favorites);

  @override
  Future<void> restoreAll({
    required List<QuickPhrase> customPhrases,
    required List<PhraseHistoryItem> history,
    required Set<String> favorites,
    bool overwrite = true,
  }) async {
    this.customPhrases = List.from(customPhrases);
    this.history = List.from(history);
    this.favorites = Set.from(favorites);
  }
}

class FakeSettingsDataSource implements SettingsDataSource {
  TouchSettings settings = TouchSettings.standard();

  @override
  Future<TouchSettings> getTouchSettings() async => settings;

  @override
  Future<void> saveTouchSettings(TouchSettings newSettings) async {
    settings = newSettings;
  }
}

class FakeScanningDataSource implements ScanningDataSource {
  ScanningSettings settings = ScanningSettings.standard();

  @override
  Future<ScanningSettings> getScanningSettings() async => settings;

  @override
  Future<void> saveScanningSettings(ScanningSettings newSettings) async {
    settings = newSettings;
  }
}

class FakeHeadPointerDataSource implements HeadPointerDataSource {
  HeadPointerSettings settings = HeadPointerSettings.standard();

  @override
  Future<HeadPointerSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(HeadPointerSettings newSettings) async {
    settings = newSettings;
  }
}

void main() {
  group('BackupRestoreService Tests', () {
    late FakeVocabularyRepository vocabRepo;
    late FakeProfileRepository profileRepo;
    late FakePhraseDataSource phraseDs;
    late FakeSettingsDataSource settingsDs;
    late FakeScanningDataSource scanningDs;
    late FakeHeadPointerDataSource hpDs;
    late BackupRestoreService service;

    setUp(() {
      vocabRepo = FakeVocabularyRepository();
      profileRepo = FakeProfileRepository();
      phraseDs = FakePhraseDataSource();
      settingsDs = FakeSettingsDataSource();
      scanningDs = FakeScanningDataSource();
      hpDs = FakeHeadPointerDataSource();

      service = BackupRestoreService(
        vocabularyRepository: vocabRepo,
        profileRepository: profileRepo,
        phraseDataSource: phraseDs,
        settingsDataSource: settingsDs,
        scanningDataSource: scanningDs,
        headPointerDataSource: hpDs,
      );

      // Seed initial mock data
      final defaultProf = UserProfile.defaultProfile();
      profileRepo.profiles = [defaultProf];
      profileRepo.activeId = defaultProf.id;

      vocabRepo.boards = {
        'home_board': const AACBoard(
          id: 'home_board',
          name: 'Inicio',
          rows: 2,
          columns: 2,
          buttons: [
            AACButton(
              id: 'btn_1',
              row: 0,
              col: 0,
              label: 'Yo',
              partOfSpeech: PartOfSpeech.pronoun,
            ),
          ],
        ),
      };

      phraseDs.customPhrases = [
        QuickPhrase(
          id: 'qp_1',
          text: 'Quiero mi juguete favorito',
          iconEmoji: '🧸',
          category: QuickPhraseCategory.basicNeeds,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
      phraseDs.history = [
        PhraseHistoryItem(
          id: 'h_1',
          text: 'Hola mamá',
          spokenAt: DateTime(2026, 1, 2),
        ),
      ];
      phraseDs.favorites = {'Quiero mi juguete favorito'};

      settingsDs.settings = const TouchSettings(holdDurationMs: 350);
      scanningDs.settings = const ScanningSettings(enabled: true, scanSpeedSeconds: 2.0);
      hpDs.settings = const HeadPointerSettings(enabled: true);
    });

    test('createBackupBytes packs all state and inspectManifest reads metadata', () async {
      final bytes = await service.createBackupBytes(notes: 'Copia clínica de prueba');
      expect(bytes, isNotEmpty);

      final manifest = BackupRestoreService.inspectManifestFromBytes(bytes);
      expect(manifest.app, 'MatataTalk');
      expect(manifest.version, '1.0');
      expect(manifest.profilesCount, 1);
      expect(manifest.boardsCount, 1);
      expect(manifest.customPhrasesCount, 1);
      expect(manifest.historyCount, 1);
      expect(manifest.notes, 'Copia clínica de prueba');
      expect(manifest.activeProfileName, contains('Mateo Rafael'));
    });

    test('parseBackupDataFromBytes faithfully deserializes all entities', () async {
      final bytes = await service.createBackupBytes();
      final backupData = BackupRestoreService.parseBackupDataFromBytes(bytes);

      expect(backupData.profiles.length, 1);
      expect(backupData.profiles.first.name, contains('Mateo Rafael'));
      expect(backupData.boards.containsKey('home_board'), true);
      expect(backupData.boards['home_board']!.buttons.first.label, 'Yo');
      expect(backupData.customPhrases.first.text, 'Quiero mi juguete favorito');
      expect(backupData.history.first.text, 'Hola mamá');
      expect(backupData.favorites.contains('Quiero mi juguete favorito'), true);
      expect(backupData.touchSettings.holdDurationMs, 350);
      expect(backupData.scanningSettings.enabled, true);
      expect(backupData.scanningSettings.scanSpeedSeconds, 2.0);
      expect(backupData.headPointerSettings.enabled, true);
    });

    test('restoreBackup restores into target databases and repositories', () async {
      final bytes = await service.createBackupBytes();
      final backupData = BackupRestoreService.parseBackupDataFromBytes(bytes);

      // Limpiamos los repositorios destino para simular un dispositivo nuevo
      vocabRepo.boards.clear();
      profileRepo.profiles.clear();
      phraseDs.customPhrases.clear();
      phraseDs.history.clear();
      phraseDs.favorites.clear();
      settingsDs.settings = TouchSettings.standard();
      scanningDs.settings = ScanningSettings.standard();
      hpDs.settings = HeadPointerSettings.standard();

      final result = await service.restoreBackup(backupData);

      expect(result.success, true);
      expect(result.profilesRestored, 1);
      expect(result.boardsRestored, 1);
      expect(result.phrasesRestored, 1);

      // Verificamos que los datos se guardaron efectivamente
      expect(vocabRepo.boards.containsKey('home_board'), true);
      expect(profileRepo.profiles.length, 1);
      expect(profileRepo.activeId, 'profile_default');
      expect(phraseDs.customPhrases.length, 1);
      expect(phraseDs.history.length, 1);
      expect(settingsDs.settings.holdDurationMs, 350);
      expect(scanningDs.settings.enabled, true);
      expect(hpDs.settings.enabled, true);
    });
  });
}
