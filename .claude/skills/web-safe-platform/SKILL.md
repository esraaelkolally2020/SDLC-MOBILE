---
name: web-safe-platform
description: BUILD stage. Wraps a platform-specific API (dart:io, file system, native plugin, dart:html) in a conditional-import facade with _stub/_io/_web files so the app still builds for web. Use when code needs dart:io, Platform, File, or a plugin without web support, or when `flutter build web` fails on such imports.
argument-hint: <capability name> [location]
---

# Web-safe platform facade

## When
- Any `dart:io` use (File, Directory, Platform, HttpClient, SocketException)
- Any plugin that has no web implementation
- Browser-only APIs (`package:web`, `dart:js_interop`)

For simple platform checks, don't create a facade. Use `AppPlatform.isAndroid`, `.isIOS` or `.isWeb` from `lib/core/services/platform/app_platform.dart`.

## Files (put them next to the code that uses them, or under `lib/core/services/platform/`)
```dart
// <name>.dart: the only file other code imports
export '<name>_stub.dart'
    if (dart.library.io) '<name>_io.dart'
    if (dart.library.js_interop) '<name>_web.dart';
```
```dart
// <name>_stub.dart: same signatures; used by the analyzer and unknown platforms
Future<void> saveBytes(String fileName, List<int> bytes) =>
    throw UnsupportedError('saveBytes is not supported on this platform');
```
```dart
// <name>_io.dart: Android, iOS, desktop
import 'dart:io';
Future<void> saveBytes(String fileName, List<int> bytes) async { /* File(...).writeAsBytes */ }
```
```dart
// <name>_web.dart: browser
import 'package:web/web.dart' as web;
Future<void> saveBytes(String fileName, List<int> bytes) async { /* Blob + anchor download */ }
```

All three implementations must have **identical** public signatures. For types (exceptions, classes), the stub declares a same-named class that can never match, like `io_exceptions_stub.dart` does for `SocketException`.

Existing examples to copy:
- `lib/core/services/network/error/io_exceptions{,_io,_stub}.dart` (types)
- `lib/core/services/network/interceptors/native_interceptors{,_io,_stub}.dart` (plugin only on native)
- `lib/core/pickup_module/download_file_module/cubit/download_saver{,_io,_web,_stub}.dart` (functions)

## Verify
1. `grep -rn "dart:io" lib | grep -v '_io.dart'` must print nothing.
2. `flutter analyze`
3. `flutter build web --release`
