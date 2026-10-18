import 'package:equatable/equatable.dart';
import 'aac_board.dart';
import 'head_pointer_settings.dart';
import 'phrase_history_item.dart';
import 'quick_phrase.dart';
import 'scanning_settings.dart';
import 'touch_settings.dart';
import 'user_profile.dart';

/// Metadatos del archivo de respaldo de MatataTalk
class BackupManifest extends Equatable {
  final String format; // 'matata-backup-1.0'
  final String app;    // 'MatataTalk'
  final String version; // '1.0'
  final DateTime createdAt;
  final int profilesCount;
  final int boardsCount;
  final int customPhrasesCount;
  final int historyCount;
  final String activeProfileName;
  final String notes;

  const BackupManifest({
    this.format = 'matata-backup-1.0',
    this.app = 'MatataTalk',
    this.version = '1.0',
    required this.createdAt,
    required this.profilesCount,
    required this.boardsCount,
    required this.customPhrasesCount,
    required this.historyCount,
    this.activeProfileName = 'Matata',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'format': format,
        'app': app,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'profilesCount': profilesCount,
        'boardsCount': boardsCount,
        'customPhrasesCount': customPhrasesCount,
        'historyCount': historyCount,
        'activeProfileName': activeProfileName,
        'notes': notes,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        format: json['format'] as String? ?? 'matata-backup-1.0',
        app: json['app'] as String? ?? 'MatataTalk',
        version: json['version'] as String? ?? '1.0',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        profilesCount: json['profilesCount'] as int? ?? 0,
        boardsCount: json['boardsCount'] as int? ?? 0,
        customPhrasesCount: json['customPhrasesCount'] as int? ?? 0,
        historyCount: json['historyCount'] as int? ?? 0,
        activeProfileName: json['activeProfileName'] as String? ?? 'Usuario',
        notes: json['notes'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        format,
        app,
        version,
        createdAt,
        profilesCount,
        boardsCount,
        customPhrasesCount,
        historyCount,
        activeProfileName,
        notes,
      ];
}

/// Contenedor en memoria de todos los datos extraídos de un archivo de respaldo
class BackupData {
  final BackupManifest manifest;
  final List<UserProfile> profiles;
  final String activeProfileId;
  final Map<String, AACBoard> boards;
  final List<QuickPhrase> customPhrases;
  final List<PhraseHistoryItem> history;
  final Set<String> favorites;
  final TouchSettings touchSettings;
  final ScanningSettings scanningSettings;
  final HeadPointerSettings headPointerSettings;

  const BackupData({
    required this.manifest,
    required this.profiles,
    required this.activeProfileId,
    required this.boards,
    required this.customPhrases,
    required this.history,
    required this.favorites,
    required this.touchSettings,
    required this.scanningSettings,
    required this.headPointerSettings,
  });
}

/// Resultado tras completar una operación de restauración
class BackupRestoreResult {
  final bool success;
  final int profilesRestored;
  final int boardsRestored;
  final int phrasesRestored;
  final String activeProfileName;
  final String? errorMessage;

  const BackupRestoreResult({
    required this.success,
    this.profilesRestored = 0,
    this.boardsRestored = 0,
    this.phrasesRestored = 0,
    this.activeProfileName = '',
    this.errorMessage,
  });
}
