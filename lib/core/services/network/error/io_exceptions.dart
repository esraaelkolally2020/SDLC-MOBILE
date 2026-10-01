/// Re-exports `SocketException`/`HandshakeException` from `dart:io` on native,
/// and provides never-matching stand-ins on web (where those exceptions can
/// never be thrown), so error-handling switch patterns compile everywhere.
library;

export 'io_exceptions_stub.dart' if (dart.library.io) 'io_exceptions_io.dart';
