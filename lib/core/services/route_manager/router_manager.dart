import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di.dart';
import '../../../features/example/presentation/cubit/example_cubit.dart';
import '../../../features/example/presentation/ui/example/screen/example_main_screen.dart';
import '../../data/constants/app_router.dart';
import '../../data/constants/global_obj.dart';
import '../log/app_log.dart';
import 'logging_observer.dart';

class RouterManager {
  static final GoRouter routerManager = GoRouter(
    initialLocation: AppRouter.initial,
    observers: [
      RouteAwareObserver(),
      LoggingObserver(),
      DuplicateNavigationObserver(),
    ],
    debugLogDiagnostics: true,
    navigatorKey: navigatorKey,
    // Global guard: return a path to redirect (e.g. to a login route when
    // `SessionManager().isLogin` is false), or null to allow navigation.
    redirect: (context, state) {
      AppLog.printValueAndTitle(
        'Redirect method, Current Path',
        state.fullPath,
      );
      return null;
    },
    routes: [
      GoRoute(
        name: AppRouter.example,
        path: AppRouter.example,
        builder: (context, state) => BlocProvider(
          create: (_) => ExampleCubit(exampleUseCase: getIt())..getExamples(),
          child: const ExampleMainScreen(),
        ),
      ),
    ],
  );

  GoRouter get router => routerManager;
}

class RouteAwareObserver extends NavigatorObserver {
  final RouteObserver<ModalRoute<dynamic>> routeObserver =
      RouteObserver<ModalRoute<dynamic>>();

  void _logRouteChange(String action, Route? route, Route? previousRoute) {
    final currentName = route?.settings.name ?? 'Unknown';
    final previousName = previousRoute?.settings.name ?? 'None';

    debugPrint(
      '[ROUTE] $action → Current: $currentName | Previous: $previousName',
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route, previousRoute);
    if (route is ModalRoute) {
      routeObserver.didPush(route, previousRoute as ModalRoute?);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', previousRoute, route);
    if (route is ModalRoute) {
      routeObserver.didPop(route, previousRoute as ModalRoute?);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRouteChange('REPLACE', newRoute, oldRoute);
    if (newRoute is ModalRoute) {
      routeObserver.didReplace(
        newRoute: newRoute,
        oldRoute: oldRoute as ModalRoute?,
      );
    }
  }
}

/// Pops a route that was pushed immediately after another push.
///
/// Rapid double-taps on list items, buttons, or cards can fire two
/// `context.push()` calls before the first navigation transition finishes,
/// stacking two copies of a screen. This observer notices the second push
/// inside the cooldown window and dismisses it right away.
///
/// Register it once on `GoRouter(observers: [...])`:
///
///   GoRouter(
///     observers: [DuplicateNavigationObserver()],
///     routes: [...],
///   )
class DuplicateNavigationObserver extends NavigatorObserver {
  /// Window during which a second push is considered a double-tap.
  /// Should be slightly longer than a typical push transition
  /// (~300-400 ms on iOS / Android).
  final Duration cooldown;

  DuplicateNavigationObserver({
    this.cooldown = const Duration(milliseconds: 700),
  });

  DateTime? _lastPushTime;

  /// Names of routes that are allowed to stack quickly, in case some flows
  /// legitimately push two screens within the cooldown (e.g. a deep-link
  /// chain, or a splash → onboarding → home boot sequence). Add route names
  /// here as needed.
  final Set<String> _whitelist = const {
    // '/splash',
    // '/onboarding',
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final now = DateTime.now();
    final isRapid =
        _lastPushTime != null && now.difference(_lastPushTime!) < cooldown;

    // Always advance the timestamp — even for a rejected push — so a burst
    // of taps doesn't all pass through.
    _lastPushTime = now;

    if (!isRapid) return;

    final routeName = route.settings.name;
    if (routeName != null && _whitelist.contains(routeName)) return;

    // Defer the pop by one frame: we're inside the observer callback
    // (mid-transition), and popping immediately would corrupt Navigator
    // state. `addPostFrameCallback` gives the current frame a chance to
    // finish, then we pop the redundant route.
    final nav = navigator;
    if (nav == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (nav.canPop()) {
        nav.pop();
      }
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Treat pop as a navigation event too, so a rapid pop-then-push
    // also respects the cooldown.
    _lastPushTime = DateTime.now();
  }
}
