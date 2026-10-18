import 'package:equatable/equatable.dart';
import 'head_pointer_settings.dart';
import 'scanning_settings.dart';
import 'touch_settings.dart';

/// Modelo de Perfil de Usuario para terapeutas, escuelas y familias
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String avatarEmoji;
  final String rootBoardId;
  final String notes;
  final TouchSettings touchSettings;
  final ScanningSettings scanningSettings;
  final HeadPointerSettings headPointerSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarEmoji = '🦁',
    this.rootBoardId = 'home_board',
    this.notes = '',
    this.touchSettings = const TouchSettings(),
    this.scanningSettings = const ScanningSettings(),
    this.headPointerSettings = const HeadPointerSettings(),
    required this.createdAt,
    required this.updatedAt,
  });

  /// Perfil principal de Mateo Rafael
  factory UserProfile.defaultProfile() {
    final now = DateTime.now();
    return UserProfile(
      id: 'profile_default',
      name: 'Mateo Rafael ("Matata")',
      avatarEmoji: '🦁',
      rootBoardId: 'home_board',
      notes: 'Perfil clínico principal para Mateo Rafael 💙',
      touchSettings: TouchSettings.standard(),
      scanningSettings: ScanningSettings.standard(),
      headPointerSettings: HeadPointerSettings.standard(),
      createdAt: now,
      updatedAt: now,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarEmoji,
    String? rootBoardId,
    String? notes,
    TouchSettings? touchSettings,
    ScanningSettings? scanningSettings,
    HeadPointerSettings? headPointerSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      rootBoardId: rootBoardId ?? this.rootBoardId,
      notes: notes ?? this.notes,
      touchSettings: touchSettings ?? this.touchSettings,
      scanningSettings: scanningSettings ?? this.scanningSettings,
      headPointerSettings: headPointerSettings ?? this.headPointerSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarEmoji': avatarEmoji,
      'rootBoardId': rootBoardId,
      'notes': notes,
      'touchSettings': touchSettings.toJson(),
      'scanningSettings': scanningSettings.toJson(),
      'headPointerSettings': headPointerSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'profile_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Nuevo Perfil',
      avatarEmoji: json['avatarEmoji'] as String? ?? '👤',
      rootBoardId: json['rootBoardId'] as String? ?? 'home_board',
      notes: json['notes'] as String? ?? '',
      touchSettings: json['touchSettings'] != null
          ? TouchSettings.fromJson(json['touchSettings'] as Map<String, dynamic>)
          : TouchSettings.standard(),
      scanningSettings: json['scanningSettings'] != null
          ? ScanningSettings.fromJson(json['scanningSettings'] as Map<String, dynamic>)
          : ScanningSettings.standard(),
      headPointerSettings: json['headPointerSettings'] != null
          ? HeadPointerSettings.fromJson(json['headPointerSettings'] as Map<String, dynamic>)
          : HeadPointerSettings.standard(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatarEmoji,
        rootBoardId,
        notes,
        touchSettings,
        scanningSettings,
        headPointerSettings,
        createdAt,
        updatedAt,
      ];
}
