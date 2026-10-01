import 'package:flutter/foundation.dart';

/// Web-safe replacement for `dart:io`'s `Platform` checks.
///
/// `dart:io` is NOT available on Flutter web, so importing it (even only for
/// `Platform.isAndroid`) breaks the web build. Use [AppPlatform] instead: it is
/// built on `kIsWeb` + `defaultTargetPlatform`, which compile on every target.
///
/// On web, [isAndroid]/[isIOS] are always `false` and [isWeb] is `true`.
abstract final class AppPlatform {
  const AppPlatform._();

  /// True when running as a web app (compiled to JS/WASM).
  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// True on any native mobile platform (Android or iOS), false on web/desktop.
  static bool get isMobile => isAndroid || isIOS;

  /// A lowercase platform label, safe on web (`'web'`).
  static String get operatingSystem {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}
