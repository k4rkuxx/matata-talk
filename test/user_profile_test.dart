import 'package:flutter_test/flutter_test.dart';
import 'package:matata_talk/domain/models/head_pointer_settings.dart';
import 'package:matata_talk/domain/models/scanning_settings.dart';
import 'package:matata_talk/domain/models/touch_settings.dart';
import 'package:matata_talk/domain/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('UserProfile.defaultProfile creates Mateo Rafael as active', () {
      final defaultProf = UserProfile.defaultProfile();

      expect(defaultProf.id, 'profile_default');
      expect(defaultProf.name, contains('Mateo Rafael'));
      expect(defaultProf.avatarEmoji, '🦁');
      expect(defaultProf.rootBoardId, 'home_board');
      expect(defaultProf.touchSettings, TouchSettings.standard());
      expect(defaultProf.scanningSettings, ScanningSettings.standard());
      expect(defaultProf.headPointerSettings, HeadPointerSettings.standard());
    });

    test('toJson and fromJson serializes cleanly with full fidelity', () {
      final now = DateTime.now();
      final customProf = UserProfile(
        id: 'test_123',
        name: 'Lucas Terapeuta',
        avatarEmoji: '⭐',
        rootBoardId: 'food_board',
        notes: 'Sesión martes',
        touchSettings: const TouchSettings(holdDurationMs: 400),
        scanningSettings: const ScanningSettings(enabled: true, scanSpeedSeconds: 1.5),
        headPointerSettings: const HeadPointerSettings(enabled: true),
        createdAt: now,
        updatedAt: now,
      );

      final json = customProf.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.id, 'test_123');
      expect(restored.name, 'Lucas Terapeuta');
      expect(restored.avatarEmoji, '⭐');
      expect(restored.rootBoardId, 'food_board');
      expect(restored.notes, 'Sesión martes');
      expect(restored.touchSettings.holdDurationMs, 400);
      expect(restored.scanningSettings.enabled, true);
      expect(restored.scanningSettings.scanSpeedSeconds, 1.5);
      expect(restored.headPointerSettings.enabled, true);
    });

    test('copyWith updates properties correctly', () {
      final defaultProf = UserProfile.defaultProfile();
      final updated = defaultProf.copyWith(
        name: 'Mateo (Escuela)',
        avatarEmoji: '🎒',
      );

      expect(updated.id, defaultProf.id);
      expect(updated.name, 'Mateo (Escuela)');
      expect(updated.avatarEmoji, '🎒');
      expect(updated.rootBoardId, defaultProf.rootBoardId);
    });
  });
}
