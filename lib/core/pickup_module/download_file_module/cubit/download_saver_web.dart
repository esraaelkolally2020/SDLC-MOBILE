import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web: decode the base64 payload and hand the browser a normal file download.
Future<void> saveAndPreviewFile({
  required String fileName,
  required String fileBinary,
}) async {
  final bytes = base64Decode(fileBinary);
  final blob = web.Blob(<JSAny>[bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
