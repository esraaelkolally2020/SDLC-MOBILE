import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../services/log/app_log.dart';

/// Native implementation: decode the file off the UI isolate, save it and
/// open it with the platform's default viewer.
Future<void> saveAndPreviewFile({
  required String fileName,
  required String fileBinary,
}) async {
  final String directory = await _resolveSaveDirectory();
  final String filePath = p.join(directory, p.basename(fileName));
  AppLog.printValueAndTitle('Download save path', filePath);

  final String savedPath = await Isolate.run(
    () => _writeBase64File(filePath, fileBinary),
  );

  await OpenFilex.open(savedPath);
}

/// Downloads directory when the platform exposes one (Android, desktop),
/// otherwise the app documents directory (iOS).
Future<String> _resolveSaveDirectory() async {
  try {
    final Directory? downloads = await getDownloadsDirectory();
    if (downloads != null) {
      await downloads.create(recursive: true);
      return downloads.path;
    }
  } catch (e) {
    AppLog.printValueAndTitle('getDownloadsDirectory unavailable', e);
  }
  final Directory documents = await getApplicationDocumentsDirectory();
  return documents.path;
}

Future<String> _writeBase64File(String filePath, String base64Data) async {
  final file = File(filePath);
  await file.writeAsBytes(base64Decode(base64Data), flush: true);
  return file.path;
}
