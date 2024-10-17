import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();
  static SharedPreferences? _prefs;

  SharedPreferencesHelper._internal();

  factory SharedPreferencesHelper() {
    return _instance;
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get boolean value
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // Set boolean value
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // Get string value
  Future<String> getString(String key, {String defaultValue = ''}) async {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // Set string value
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

// Add more getters and setters for different types as needed
}
