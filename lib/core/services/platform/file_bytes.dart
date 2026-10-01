import 'dart:typed_data';

import 'file_bytes_stub.dart' if (dart.library.io) 'file_bytes_io.dart' as impl;

/// Reads a file's bytes given a filesystem path. Only valid on native
/// platforms; on web use `PlatformFile.bytes` / `XFile.readAsBytes()` instead.
Future<Uint8List> readFileBytes(String path) => impl.readFileBytes(path);
