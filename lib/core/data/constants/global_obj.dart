import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Context-free access to the root navigator, e.g. from interceptors/services.
class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigatorState => navigatorKey.currentState;
}
