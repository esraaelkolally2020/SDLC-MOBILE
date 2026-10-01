import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starter_app/core/services/log/app_log.dart';

class SecureStorageService {
  SecureStorageService._internal();

  factory SecureStorageService() => SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility
          .first_unlock_this_device, // iOS-specific options
    ),
  );

  // Setter
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  // Getter
  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> writeUserModel(String key, dynamic value) async {
    final userJson = jsonEncode(value.toJson());
    try {
      await _secureStorage.write(key: key, value: userJson);
    } catch (e) {
      AppLog.logValue('Error writing to secure storage: $e');
    }
  }

  Future<dynamic> readUserModel(String key) async {
    try {
      // final userJson =
      await _secureStorage.read(key: key);
      // return UserModel.fromJson(jsonDecode(userJson));
      return dynamic;
    } catch (e) {
      AppLog.logValue('Error reading from secure storage: $e');
      return null;
    }
  }

  // Delete specific key
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Clear all data
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> containsKey(String key) {
    return _secureStorage.containsKey(key: key);
  }
}
