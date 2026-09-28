import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/head_pointer_settings.dart';

abstract class HeadPointerDataSource {
  Future<HeadPointerSettings> getSettings();
  Future<void> saveSettings(HeadPointerSettings settings);
}

class SharedPreferencesHeadPointerDataSource implements HeadPointerDataSource {
  static const String _keyHeadPointerSettings = 'matata_head_pointer_settings';

  @override
  Future<HeadPointerSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyHeadPointerSettings);
      if (jsonString != null) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return HeadPointerSettings.fromJson(map);
      }
    } catch (_) {}
    return HeadPointerSettings.standard();
  }

  @override
  Future<void> saveSettings(HeadPointerSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_keyHeadPointerSettings, jsonString);
    } catch (_) {}
  }
}
