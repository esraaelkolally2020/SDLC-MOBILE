import '../../data/constants/shared_preferences_constants.dart';
import '../local_storage/secure_storage/secure_storage_service.dart';
import '../local_storage/shared_preference/shared_preference_service.dart';
import '../log/app_log.dart';

class SessionManager {
  final SecureStorageService _secureStorage;
  final SharedPreferenceService _sharedPreferences;

  SessionManager({
    SecureStorageService? secureStorage,
    SharedPreferenceService? sharedPreferences,
  }) : _secureStorage = secureStorage ?? SecureStorageService(),
       _sharedPreferences = sharedPreferences ?? SharedPreferenceService();

  Future<void> init() async {
    // Check if app was already launched before
    AppLog.printValueAndTitle('isFirstTimeToOpenApp', isFirstTimeToOpenApp);
    if (isFirstTimeToOpenApp) {
      // Fresh install detected, clear secure storage
      await clearSession();

      // Mark that app has launched before
      await setDoneFirstTimeToOpenApp();
    }
  }

  /// Clears tokens and the logged-in flag (call on logout / 401).
  Future<void> clearSession() async {
    try {
      await _secureStorage.clear();
    } catch (e) {
      AppLog.logValue('Failed to clear Secure Storage: $e');
    }

    await setIsLogin(false);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secureStorage.write(
      key: SharPrefConstants.userAccessTokenKey,
      value: accessToken,
    );
    if (refreshToken != null) {
      await _secureStorage.write(
        key: SharPrefConstants.userRefreshTokenKey,
        value: refreshToken,
      );
    }
  }

  Future<String?> get accessToken async {
    return await _secureStorage.read(key: SharPrefConstants.userAccessTokenKey);
  }

  Future<String?> get refreshToken async {
    return await _secureStorage.read(
      key: SharPrefConstants.userRefreshTokenKey,
    );
  }

  Future<void> setIsLogin(bool value) async {
    await _sharedPreferences.setBool(SharPrefConstants.isLoginKey, value);
  }

  bool get isLogin {
    return _sharedPreferences.getBool(SharPrefConstants.isLoginKey);
  }

  Future<void> setDoneFirstTimeToOpenApp() async {
    await _sharedPreferences.setBool(
      SharPrefConstants.isFirstTimeToOpenAppKey,
      false,
    );
  }

  bool get isFirstTimeToOpenApp {
    return _sharedPreferences.getBool(
      SharPrefConstants.isFirstTimeToOpenAppKey,
      defaultValue: true,
    );
  }
}
