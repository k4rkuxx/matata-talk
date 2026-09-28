import 'package:flutter_test/flutter_test.dart';
import 'package:matata_talk/data/datasources/default_vocabulary.dart';
import 'package:matata_talk/data/services/tts_service.dart';
import 'package:matata_talk/domain/models/scanning_settings.dart';
import 'package:matata_talk/presentation/features/scanning/controller/scanning_engine.dart';
import 'package:mocktail/mocktail.dart';
import 'package:audioplayers/audioplayers.dart';

class MockTTSService extends Mock implements TTSService {}
class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanningSettings Tests', () {
    test('Default scanning settings are sound-enabled and standard', () {
      final std = ScanningSettings.standard();
      expect(std.enabled, isFalse);
      expect(std.enableAcousticBeep, isTrue);
      expect(std.enableAuditoryCue, isFalse);
      expect(std.scanSpeedSeconds, equals(1.5));
    });

    test('JSON serialization round-trip retains auditory flags', () {
      const custom = ScanningSettings(
        enabled: true,
        mode: ScanningMode.stepScan,
        pattern: ScanningPattern.linear,
        scanSpeedSeconds: 2.0,
        maxLoops: 4,
        enableAuditoryCue: true,
        enableAcousticBeep: true,
        screenAsSwitch: true,
      );

      final json = custom.toJson();
      final restored = ScanningSettings.fromJson(json);
      expect(restored, equals(custom));
      expect(restored.enableAuditoryCue, isTrue);
      expect(restored.enableAcousticBeep, isTrue);
    });
  });

  group('ScanningEngine Auditory & Acoustic Cue Tests', () {
    late MockTTSService mockTts;
    late MockAudioPlayer mockAudio;
    final board = DefaultVocabulary.getHomeBoard();

    setUp(() {
      mockTts = MockTTSService();
      mockAudio = MockAudioPlayer();

      when(() => mockAudio.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => mockAudio.stop()).thenAnswer((_) async {});
      when(() => mockAudio.play(
            any(),
            mode: any(named: 'mode'),
            volume: any(named: 'volume'),
          )).thenAnswer((_) async {});
      when(() => mockTts.speakCue(any())).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(AssetSource('sounds/scan_beep.wav'));
      registerFallbackValue(PlayerMode.lowLatency);
    });

    test('stepScan advances cursor and triggers beep and cue', () {
      const settings = ScanningSettings(
        enabled: true,
        mode: ScanningMode.stepScan,
        pattern: ScanningPattern.rowColumn,
        enableAcousticBeep: true,
        enableAuditoryCue: true,
      );

      final engine = ScanningEngine(
        settings: settings,
        ttsService: mockTts,
        audioPlayer: mockAudio,
      );

            engine.configure(
        settings: settings,
        board: board,
        onSelect: (r, c) {
          // selected
        },
      );

      // En rowColumn, inicialmente está en fila 0
      expect(engine.cursor.rowIndex, equals(0));
      expect(engine.cursor.isRowPhase, isTrue);

      // Avanzar cursor (switch 1 en stepScan)
      engine.onSwitchActivate();
      expect(engine.cursor.rowIndex, equals(1));

      // Verificar que se invocó el beep y el cue auditivo para 'Fila 2'
      verify(() => mockAudio.play(any(), mode: any(named: 'mode'), volume: any(named: 'volume'))).called(greaterThanOrEqualTo(1));
      verify(() => mockTts.speakCue('Fila 2')).called(1);

      // Confirmar fila (switch 2 en stepScan) -> entra a columna 0
      engine.onSwitch2Activate();
      expect(engine.cursor.isRowPhase, isFalse);
      expect(engine.cursor.colIndex, equals(0));

      final firstButton = board.getButtonAt(1, 0);
      if (firstButton != null) {
        verify(() => mockTts.speakCue(firstButton.label)).called(1);
      }

      engine.dispose();
    });
  });
}
