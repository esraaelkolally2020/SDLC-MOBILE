import 'package:flutter/material.dart';

import '../../../data/constants/global_obj.dart';

void showErrorParsingBottomSheet({
  dynamic error,
  dynamic data,
  int? statusCode,
}) {
  final BuildContext? context = navigatorKey.currentState?.context;

  if (context == null) {
    debugPrint('Cannot show parsing bottom sheet: navigator context is null');
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Code ${statusCode ?? '-'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  '$error',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SelectableText.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        children: buildSpans(data),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Okay',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

List<InlineSpan> buildSpans(dynamic data, {int indent = 0}) {
  final List<InlineSpan> spans = [];
  final String indentSpace = '  ' * indent;

  if (data is Map) {
    data.forEach((key, value) {
      spans.add(
        TextSpan(
          text: '$indentSpace${capitalize(key.toString())}: ',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      spans.addAll(buildSpans(value, indent: indent + 1));
    });
  } else if (data is List) {
    if (data.isEmpty) {
      spans.add(
        const TextSpan(
          text: '[]\n',
          style: TextStyle(color: Colors.black),
        ),
      );
    } else {
      for (int i = 0; i < data.length; i++) {
        if (i != 0) {
          spans.add(
            const TextSpan(
              text: '─────────────\n',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        spans.add(
          TextSpan(
            text: '${indentSpace}Item ${i + 1}:\n',
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        spans.addAll(buildSpans(data[i], indent: indent + 1));
      }
    }
  } else if (_isCustomObject(data)) {
    try {
      final json = (data as dynamic).toJson();

      if (json is Map || json is List) {
        spans.addAll(buildSpans(json, indent: indent));
      } else {
        spans.add(_spanForPrimitive(json, indentSpace));
      }
    } catch (_) {
      spans.add(_spanForPrimitive(data, indentSpace));
    }
  } else {
    spans.add(_spanForPrimitive(data, indentSpace));
  }

  return spans;
}

InlineSpan _spanForPrimitive(dynamic data, String indentSpace) {
  Color color = Colors.black;

  if (data is num) {
    color = Colors.green;
  } else if (data is bool) {
    color = Colors.orange;
  } else if (data == null) {
    color = Colors.grey;
  }

  return TextSpan(
    text: '$indentSpace$data\n',
    style: TextStyle(color: color),
  );
}

bool _isCustomObject(dynamic data) {
  return data != null &&
      data is! String &&
      data is! num &&
      data is! bool &&
      data is! Map &&
      data is! List;
}

String capitalize(String s) {
  return s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
