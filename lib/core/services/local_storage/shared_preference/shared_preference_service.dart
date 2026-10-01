import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  SharedPreferenceService._internal();

  static final SharedPreferenceService _instance =
      SharedPreferenceService._internal();

  factory SharedPreferenceService() => _instance;

  late SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _preferences!.getString(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _preferences!.getInt(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences!.getDouble(key) ?? defaultValue;
  }

  Future<void> writeUserModel(String key, dynamic value) async {
    final userJson = jsonEncode(value.toJson());
    await _preferences!.setString(key, userJson);
  }

  Future<dynamic> readUserModel(String key) async {
    final userJson = _preferences!.getString(key);
    if (userJson == null) return null;
    return dynamic;
  }

  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  Future<bool> clear() async {
    return await _preferences!.clear();
  }

  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}
