import 'package:flutter/services.dart';

/// Web/desktop fallback: there is no OS process to kill.
void terminateApp() => SystemNavigator.pop();
