---
paths:
  - "lib/**"
---
# Platform and web safety

The app builds for web, so `dart:io` must never reach the web build.

- `import 'dart:io'` is allowed **only** in files named `*_io.dart`. `dart:html` and `package:web` are allowed only in `*_web.dart`.
- Never use `Platform.isAndroid` and similar. Use `AppPlatform.isAndroid`, `.isIOS`, `.isWeb` (`lib/core/services/platform/app_platform.dart`), which is built on `kIsWeb` + `defaultTargetPlatform`.
- When a feature needs a platform API, use the conditional facade pattern (the `/web-safe-platform` skill generates it):
  ```
  foo.dart       export 'foo_stub.dart' if (dart.library.io) 'foo_io.dart' if (dart.library.js_interop) 'foo_web.dart';
  foo_stub.dart  same API, throws UnsupportedError
  foo_io.dart    dart:io implementation
  foo_web.dart   browser implementation
  ```
  Existing examples: `core/services/network/error/io_exceptions*.dart`, `core/services/network/interceptors/native_interceptors*.dart`, `core/pickup_module/download_file_module/cubit/download_saver*.dart`.
- Plugins without web support (certificate pinning, secure storage options, file paths) must be guarded with `AppPlatform.isWeb` or placed behind a facade.
- After changing platform code, check with `flutter build web --release`.
