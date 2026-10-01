import 'download_saver_stub.dart'
    if (dart.library.io) 'download_saver_io.dart'
    if (dart.library.js_interop) 'download_saver_web.dart'
    as impl;

/// Persists a base64-encoded file and reveals it to the user.
///
/// - Native: saves to Downloads (or app documents) and opens it.
/// - Web: triggers a browser download of the decoded bytes.
Future<void> saveAndPreviewFile({
  required String fileName,
  required String fileBinary,
}) => impl.saveAndPreviewFile(fileName: fileName, fileBinary: fileBinary);
