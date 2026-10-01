import 'package:flutter/material.dart';

import '../data/constants/global_obj.dart';
import '../data/constants/shared_preferences_constants.dart';
import '../services/local_storage/shared_preference/shared_preference_service.dart';

/// Whether the given [context] uses a dark theme.
bool isDarkContext(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Whether the app currently renders with a dark theme.
///
/// Falls back to the persisted theme preference before the navigator exists.
bool get isDark {
  final context = Get.context;
  if (context == null) {
    return SharedPreferenceService().getBool(SharPrefConstants.isDarkThemeKey);
  }
  return isDarkContext(context);
}

/// `data:image/...;base64,...` URI check used by `PImage`.
bool isBase64Image(String data) {
  final base64Regex = RegExp(
    r'^data:image\/(png|jpeg|jpg|gif|webp);base64,([A-Za-z0-9+/=]+)$',
  );
  return base64Regex.hasMatch(data);
}

/// Slide + fade page route for imperative `Navigator` pushes.
Route<T> createNavigation<T>({required Widget widget}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slideAnimation, child: child),
      );
    },
  );
}
