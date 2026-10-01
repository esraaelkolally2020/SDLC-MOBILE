import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class LoggingObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', previousRoute ?? route, route);
  }

  void _logRouteChange(String action, Route route, Route? previousRoute) {
    String current = _getRouteInfo(route);
    String previous = _getRouteInfo(previousRoute);

    debugPrint('[ROUTE] $action → Current: $current | Previous: $previous');
  }

  String _getRouteInfo(Route? route) {
    if (route == null) return 'None';
    final name = route.settings.name;
    final location = (route.settings.arguments is GoRouterState)
        ? (route.settings.arguments as GoRouterState).uri.toString()
        : null;

    return name ?? location ?? route.runtimeType.toString();
  }
}
