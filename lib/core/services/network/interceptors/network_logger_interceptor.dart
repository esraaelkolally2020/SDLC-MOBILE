import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A comprehensive Dio interceptor that logs requests, responses, and errors
/// in a clean, copy-paste-friendly format to the terminal.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(NetworkLoggerInterceptor());
/// ```
///
/// Features:
/// - Structured, box-drawn logs for easy scanning
/// - Pretty-printed JSON bodies (request & response)
/// - Copy-friendly: each JSON body is printed as a standalone block
/// - Duration tracking per request
/// - Query parameters, headers, and content-type logging
/// - Only active in debug mode (kDebugMode)
class NetworkLoggerInterceptor extends Interceptor {
  NetworkLoggerInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logHeaders = true,
    this.maxBodyLogLength = 50000,
  });

  /// Whether to log outgoing requests.
  final bool logRequest;

  /// Whether to log incoming responses.
  final bool logResponse;

  /// Whether to log errors.
  final bool logError;

  /// Whether to log request/response headers.
  final bool logHeaders;

  /// Maximum characters for body logging. Bodies exceeding this will be truncated.
  final int maxBodyLogLength;

  // ──────────────────────────────────────────────────────────────────────────
  // REQUEST
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode && logRequest) {
      options.extra['_networkLoggerStartTime'] =
          DateTime.now().millisecondsSinceEpoch;
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // RESPONSE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode && logResponse) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ERROR
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && logError) {
      _logError(err);
    }
    super.onError(err, handler);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PRIVATE — LOG BUILDERS
  // ══════════════════════════════════════════════════════════════════════════

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer();

    buffer.writeln('');
    buffer.writeln(
      '┌─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ➡️  REQUEST');
    buffer.writeln(
      '├─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ${options.method}  ${options.uri}');
    buffer.writeln('│ Time: ${DateTime.now().toIso8601String()}');

    // Query parameters
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│');
      buffer.writeln('│ 📎 Query Parameters:');
      for (final entry in options.queryParameters.entries) {
        buffer.writeln('    ${entry.key}: ${entry.value}');
      }
    }

    // Headers
    if (logHeaders) {
      buffer.writeln('│');
      buffer.writeln('│ 📋 Headers:');
      options.headers.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    // Request Body
    if (options.data != null) {
      buffer.writeln('│');
      buffer.writeln('│ 📦 Request Body:');
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY BELOW ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
      buffer.writeln(_prettyJson(options.data));
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY ABOVE ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────',
    );

    _print(buffer.toString());
  }

  void _logResponse(Response response) {
    final buffer = StringBuffer();
    final duration = _calculateDuration(response.requestOptions);
    final statusEmoji = _statusEmoji(response.statusCode ?? 0);

    buffer.writeln('');
    buffer.writeln(
      '┌─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ $statusEmoji  RESPONSE  [${response.statusCode}]');
    buffer.writeln(
      '├─────────────────────────────────────────────────────────────',
    );
    buffer.writeln(
      '│ ${response.requestOptions.method}  ${response.requestOptions.uri}',
    );
    buffer.writeln('│ Duration: $duration');
    buffer.writeln('│ Time: ${DateTime.now().toIso8601String()}');

    // Response Headers
    if (logHeaders) {
      buffer.writeln('│');
      buffer.writeln('│ 📋 Response Headers:');
      response.headers.forEach((name, values) {
        buffer.writeln('│   $name: ${values.join(', ')}');
      });
    }

    // Response Body
    if (response.data != null) {
      buffer.writeln('│');
      buffer.writeln('│ 📦 Response Body:');
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY BELOW ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
      buffer.writeln(_prettyJson(response.data));
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY ABOVE ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────',
    );

    _print(buffer.toString());
  }

  void _logError(DioException err) {
    final buffer = StringBuffer();
    final duration = _calculateDuration(err.requestOptions);

    buffer.writeln('');
    buffer.writeln(
      '┌─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ❌  ERROR  [${err.response?.statusCode ?? 'N/A'}]');
    buffer.writeln(
      '├─────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ${err.requestOptions.method}  ${err.requestOptions.uri}');
    buffer.writeln('│ Duration: $duration');
    buffer.writeln('│ Type: ${err.type.name}');
    buffer.writeln('│ Message: ${err.message ?? 'No message'}');

    // Request Body (useful for debugging what was sent)
    if (err.requestOptions.data != null) {
      buffer.writeln('│');
      buffer.writeln('│ 📦 Request Body:');
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY BELOW ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
      buffer.writeln(_prettyJson(err.requestOptions.data));
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY ABOVE ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
    }

    // Error Response Body
    if (err.response?.data != null) {
      buffer.writeln('│');
      buffer.writeln('│ 📦 Error Response Body:');
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY BELOW ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
      buffer.writeln(_prettyJson(err.response!.data));
      buffer.writeln(
        '├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ COPY ABOVE ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌',
      );
    }

    buffer.writeln(
      '└─────────────────────────────────────────────────────────────',
    );

    _print(buffer.toString());
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PRIVATE — HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Pretty-prints JSON data. Falls back to `.toString()` for non-JSON types
  /// like [FormData].
  String _prettyJson(dynamic data) {
    try {
      if (data is FormData) {
        return _formatFormData(data);
      }

      if (data is String) {
        // Try to decode if it's a JSON string
        final decoded = jsonDecode(data);
        final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        return _truncateIfNeeded(pretty);
      }

      if (data is Map || data is List) {
        final pretty = const JsonEncoder.withIndent('  ').convert(data);
        return _truncateIfNeeded(pretty);
      }

      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  /// Formats [FormData] fields and files into a readable string.
  String _formatFormData(FormData formData) {
    final buffer = StringBuffer();
    buffer.writeln('FormData {');

    if (formData.fields.isNotEmpty) {
      buffer.writeln('  fields:');
      for (final field in formData.fields) {
        buffer.writeln('    ${field.key}: ${field.value}');
      }
    }

    if (formData.files.isNotEmpty) {
      buffer.writeln('  files:');
      for (final file in formData.files) {
        buffer.writeln(
          '    ${file.key}: ${file.value.filename} '
          '(${file.value.contentType}, ${file.value.length} bytes)',
        );
      }
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Truncates a body string if it exceeds [maxBodyLogLength].
  String _truncateIfNeeded(String body) {
    if (body.length > maxBodyLogLength) {
      return '${body.substring(0, maxBodyLogLength)}\n... [TRUNCATED — ${body.length} total chars]';
    }
    return body;
  }

  /// Returns a human-readable duration string from the stored start time.
  String _calculateDuration(RequestOptions options) {
    final startTime = options.extra['_networkLoggerStartTime'] as int?;
    if (startTime == null) return 'N/A';

    final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
    if (elapsed >= 1000) {
      return '${(elapsed / 1000).toStringAsFixed(2)}s';
    }
    return '${elapsed}ms';
  }

  /// Returns a status-appropriate emoji.
  String _statusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '↪️';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '🔥';
    return '❓';
  }

  /// Logs using [log] from `dart:developer` — appears in yellow in the console.
  void _print(String text) {
    log(text, name: 'HTTP');
  }
}
