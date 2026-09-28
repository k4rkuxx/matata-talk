import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.45); // Velocidad adaptada para CAA
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await init();
    if (text.trim().isNotEmpty) {
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.speak(text);
    }
  }

  /// Pronuncia una pista auditiva rápida durante el barrido por conmutador
  Future<void> speakCue(String text) async {
    await init();
    if (text.trim().isNotEmpty) {
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(0.58);
      await _flutterTts.setVolume(0.85);
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
