import 'package:flutter/material.dart';

abstract interface class IConnectivityListener {
  /// Called whenever device goes offline
  void Function()? get onConnectivityLost;

  /// Called whenever device comes back online
  void Function()? get onConnectivityBack;

  /// Register a listener invoked when connectivity is restored.
  void addOnConnectivityBackListener(VoidCallback listener);

  /// Remove a previously registered back-online listener.
  void removeOnConnectivityBackListener(VoidCallback listener);

  /// Start listening to connectivity changes
  void init();

  /// Release resources
  void dispose();
}
