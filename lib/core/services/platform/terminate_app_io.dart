import 'dart:io';

import 'package:flutter/services.dart';

/// Native implementation, preserving the original mobile behaviour.
void terminateApp() {
  if (Platform.isIOS) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}
