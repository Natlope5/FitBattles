import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();
  static SharedPreferences? _prefs;

  // Private constructor for Singleton pattern
  SharedPreferencesHelper._internal();

  // Factory constructor returns the singleton instance
  factory SharedPreferencesHelper() {
    return _instance;
  }

  // Initialize SharedPreferences (ensure it's initialized before use)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get boolean value
  bool getBool(String key, {bool defaultValue = false}) {
    if (_prefs == null) throw Exception("SharedPreferences not initialized");
    return _prefs!.getBool(key) ?? defaultValue;
  }

  // Set boolean value
  Future<void> setBool(String key, bool value) async {
    if (_prefs == null) throw Exception("SharedPreferences not initialized");
    await _prefs!.setBool(key, value);
  }

  // Get string value
  String getString(String key, {String defaultValue = ''}) {
    if (_prefs == null) throw Exception("SharedPreferences not initialized");
    return _prefs!.getString(key) ?? defaultValue;
  }

  // Set string value
  Future<void> setString(String key, String value) async {
    if (_prefs == null) throw Exception("SharedPreferences not initialized");
    await _prefs!.setString(key, value);
  }

}
