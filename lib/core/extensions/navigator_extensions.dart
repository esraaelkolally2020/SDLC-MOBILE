import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/core/global/global_func.dart';
import 'package:go_router/go_router.dart' as route;

extension NavigatorExtensions on BuildContext {
  Future<dynamic> pushWidget(Widget page, String routeName) async {
    // await prefsService.write('lastRoute', routeName);
    // return Navigator.of(this).push(MaterialPageRoute(builder:(context) => createRoute(widget: page),)
    return Navigator.of(this).push(createNavigation(widget: page));
  }

  Future<dynamic> pushNamed(String routeName, {Object? arguments}) async {
    // await prefsService.write('lastRoute', routeName);
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(
    String routeName, {
    Object? arguments,
  }) async {
    // await prefsService.write('lastRoute', routeName);
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
  }) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop() => Navigator.of(this).pop();

  void popWithArguments({Object? arguments}) =>
      Navigator.of(this).pop(arguments);

  // _______________________________________________________________

  // using go_router
  Future<dynamic> pushRouter({required String route, Object? extra}) async {
    // await prefsService.write('lastRoute', route);
    return push(route, extra: extra);
  }

  Future<void> goRouter({required String route, Object? extra}) async {
    // await prefsService.write('lastRoute', route);
    go(route, extra: extra);
  }

  void popRouter() {
    pop();
  }

  void popTimes(int times, {bool? result}) {
    for (var i = 0; i < times; i++) {
      if (route.GoRouter.of(this).canPop()) {
        // ✅ Pass result only on the last pop
        if (i == times - 1) {
          route.GoRouter.of(this).pop(result);
        } else {
          route.GoRouter.of(this).pop();
        }
      }
    }
  }
}
