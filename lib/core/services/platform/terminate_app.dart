/// Web-safe app termination.
///
/// The `dart:io` implementation calls `exit(0)` on Android and
/// `SystemNavigator.pop()` on iOS. On web there is no process to exit, so the
/// stub simply pops the last route.
library;

export 'terminate_app_stub.dart' if (dart.library.io) 'terminate_app_io.dart';
