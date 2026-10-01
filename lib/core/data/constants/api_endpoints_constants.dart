/// All API endpoint paths, relative to the flavor's base URL
/// (see `FlavorsManagement.instance.getCurrentFlavor.baseUrl`).
class ApiEndpointsConstants {
  /// Fallback base URL used when the current flavor has none configured.
  static const String baseUrl = String.fromEnvironment('BASE_URL_PROD');

  // Example
  static const String examples = '/posts';

  /// Comma-separated SHA-256 certificate fingerprints (dart-define
  /// `SHA_FINGERPRINTS`). Multiple values are supported so a certificate
  /// rollover never breaks the app: keep the old fingerprint and append the
  /// new one, then drop the expired one in a later release.
  ///
  /// When empty, certificate pinning is disabled.
  static const String _fingerPrintsRaw = String.fromEnvironment(
    'SHA_FINGERPRINTS',
  );

  static List<String> get fingerPrints => _fingerPrintsRaw
      .split(',')
      .map((String e) => e.trim())
      .where((String e) => e.isNotEmpty)
      .toList();
}
