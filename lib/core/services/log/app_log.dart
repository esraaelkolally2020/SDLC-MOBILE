import 'dart:developer';

import 'package:flutter/foundation.dart';

class AppLog {
  static void logValue(dynamic value) {
    if (kDebugMode) {
      log('----------------  AppLog  ------------------');
      log('Value : $value');
    }
  }

  static void logValueAndTitle(String title, dynamic value) {
    if (kDebugMode) {
      log('----------------  AppLog  ------------------');
      log('$title --> $value');
    }
  }

  static void printValue(dynamic value) {
    if (kDebugMode) {
      debugPrint('----------------  AppLog - Print Value  --------------');
      debugPrint('Value : $value');
    }
  }

  static void printValueAndTitle(String title, dynamic value) {
    if (kDebugMode) {
      debugPrint(
        '----------------  AppLog - Print value & title  --------------',
      );
      debugPrint('$title --> $value');
    }
  }
}
