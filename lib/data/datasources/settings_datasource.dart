import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/touch_settings.dart';

abstract class SettingsDataSource {
  Future<TouchSettings> getTouchSettings();
  Future<void> saveTouchSettings(TouchSettings settings);
}

class SharedPreferencesSettingsDataSource implements SettingsDataSource {
  static const String _keyTouchSettings = 'matata_touch_settings';

  @override
  Future<TouchSettings> getTouchSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyTouchSettings);
      if (jsonString != null) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return TouchSettings.fromJson(map);
      }
    } catch (_) {
      // Fallback a configuración estándar si hay error de lectura
    }
    return TouchSettings.standard();
  }

  @override
  Future<void> saveTouchSettings(TouchSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_keyTouchSettings, jsonString);
    } catch (_) {
      // Manejar error silenciosamente
    }
  }
}
