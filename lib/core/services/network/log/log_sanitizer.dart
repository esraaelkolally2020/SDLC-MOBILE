import 'dart:convert';

import 'package:dio/dio.dart';

/// Mixin providing reusable sanitization helpers for any error logger.
///
/// Mix into any [LogErrorHandlerInterface] implementation to get consistent
/// redaction of sensitive fields (tokens, passwords, cookies, etc.).
///
/// ```dart
/// class MyLogger extends LogErrorHandlerInterface with LogSanitizer { ... }
/// ```
mixin LogSanitizer {
  /// Keys whose values must be replaced with `'***'` before logging.
  ///
  /// Compared case-insensitively against every Map key encountered
  /// during recursive sanitization.
  static const Set<String> sensitiveKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'password',
    'pass',
    'token',
    'access_token',
    'accesstoken',
    'refresh_token',
    'refreshtoken',
    'secret',
    'apikey',
    'pin',
  };

  /// Recursively redacts sensitive fields in [value].
  ///
  /// - **Map**: replaces values of sensitive keys with `'***'`.
  /// - **List**: sanitizes each element.
  /// - **FormData**: extracts fields (redacted) and file metadata.
  /// - Everything else passes through unchanged.
  dynamic sanitize(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      return value.map((dynamic key, dynamic val) {
        final String keyStr = key.toString();
        return MapEntry(
          keyStr,
          sensitiveKeys.contains(keyStr.toLowerCase()) ? '***' : sanitize(val),
        );
      });
    }

    if (value is List) {
      return value.map(sanitize).toList();
    }

    if (value is FormData) {
      return {
        'fields': value.fields.map((field) {
          final String key = field.key.toLowerCase();
          return {field.key: sensitiveKeys.contains(key) ? '***' : field.value};
        }).toList(),
        'files': value.files.map((file) {
          return {
            file.key: {
              'filename': file.value.filename,
              'contentType': file.value.contentType.toString(),
              'length': file.value.length,
            },
          };
        }).toList(),
      };
    }

    return value;
  }

  /// Sanitizes a [Map<String, dynamic>] and preserves the type.
  Map<String, dynamic>? sanitizeMap(Map<String, dynamic>? value) {
    if (value == null) return null;
    final dynamic result = sanitize(value);
    return result is Map<String, dynamic> ? result : value;
  }

  /// Sanitizes [body], JSON-encodes it, and truncates to [maxLength].
  ///
  /// Useful for loggers with document-size limits (e.g. Firestore).
  /// Falls back to `.toString()` if JSON encoding fails.
  String? safeSerialize(Object? body, {int maxLength = 12000}) {
    if (body == null) return null;

    try {
      final sanitized = sanitize(body);
      final text = jsonEncode(sanitized);
      return text.length > maxLength ? text.substring(0, maxLength) : text;
    } catch (_) {
      final s = body.toString();
      return s.length > maxLength ? s.substring(0, maxLength) : s;
    }
  }
}
