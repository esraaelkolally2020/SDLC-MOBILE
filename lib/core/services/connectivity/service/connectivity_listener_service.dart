import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../default_actions/connectivity_default_actions.dart';
import '../interface/connectivity_listener_interface.dart';
import '../model/connectivity_state.dart';

class ConnectivityListenerService implements IConnectivityListener {
  /// Custom action when device goes offline
  final void Function()? _customOnConnectivityLost;

  /// Custom action when device comes back online
  final void Function()? _customOnConnectivityBack;

  /// Used for default snackbar actions to get the current context
  final BuildContext? Function()? contextGetter;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounceTimer;
  ConnectivityState _currentState = ConnectivityState.initial;
  final Set<VoidCallback> _connectivityBackListeners = {};

  ConnectivityListenerService({
    void Function()? onConnectivityLost,
    void Function()? onConnectivityBack,
    this.contextGetter,
  }) : _customOnConnectivityLost = onConnectivityLost,
       _customOnConnectivityBack = onConnectivityBack;

  @override
  void Function()? get onConnectivityLost =>
      _customOnConnectivityLost ?? _defaultOnConnectivityLost;

  @override
  void Function()? get onConnectivityBack =>
      _customOnConnectivityBack ?? _defaultOnConnectivityBack;

  @override
  void addOnConnectivityBackListener(VoidCallback listener) {
    _connectivityBackListeners.add(listener);
  }

  @override
  void removeOnConnectivityBackListener(VoidCallback listener) {
    _connectivityBackListeners.remove(listener);
  }

  @override
  void init() {
    // Initial check
    Connectivity().checkConnectivity().then(_handleConnectivityChange);

    // Listen to changes
    _subscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _connectivityBackListeners.clear();
    // ConnectivityDefaultActions.dismiss();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final isOffline = results.every(
        (result) => result == ConnectivityResult.none,
      );

      if (isOffline && _currentState != ConnectivityState.offline) {
        // We just went offline
        _currentState = ConnectivityState.offline;
        onConnectivityLost?.call();
      } else if (!isOffline && _currentState == ConnectivityState.offline) {
        // We just came back online
        _currentState = ConnectivityState.online;
        onConnectivityBack?.call();
        for (final listener in List<VoidCallback>.from(
          _connectivityBackListeners,
        )) {
          listener();
        }
      } else if (!isOffline && _currentState == ConnectivityState.initial) {
        // Initial online state, don't show "back online" snackbar, just set state
        _currentState = ConnectivityState.online;
      }
    });
  }

  void _defaultOnConnectivityLost() {
    if (contextGetter != null) {
      ConnectivityDefaultActions.showOfflineSnackbar(contextGetter!());
    }
  }

  void _defaultOnConnectivityBack() {
    if (contextGetter != null) {
      ConnectivityDefaultActions.showOnlineSnackbar(contextGetter!());
    }
  }
}
