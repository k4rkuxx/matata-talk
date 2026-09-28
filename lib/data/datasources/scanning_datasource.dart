import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/scanning_settings.dart';

abstract class ScanningDataSource {
  Future<ScanningSettings> getScanningSettings();
  Future<void> saveScanningSettings(ScanningSettings settings);
}

class SharedPreferencesScanningDataSource implements ScanningDataSource {
  static const String _keyScanningSettings = 'matata_scanning_settings';

  @override
  Future<ScanningSettings> getScanningSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyScanningSettings);
      if (jsonString != null) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return ScanningSettings.fromJson(map);
      }
    } catch (_) {}
    return ScanningSettings.standard();
  }

  @override
  Future<void> saveScanningSettings(ScanningSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_keyScanningSettings, jsonString);
    } catch (_) {}
  }
}
