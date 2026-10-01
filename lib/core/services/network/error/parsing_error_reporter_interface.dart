import 'dart:async';

class ParsingErrorReport {
  const ParsingErrorReport({
    required this.errorMessage,
    required this.endpoint,
    required this.method,
    this.statusCode,
    this.responseBody,
    this.requestBody,
    this.queryParameters,
    this.headers,
  });

  final String errorMessage;
  final String endpoint;
  final String method;
  final int? statusCode;
  final Object? responseBody;
  final Object? requestBody;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;

  dynamic get safeDisplayData {
    final body = responseBody;

    if (body is Map) {
      return body['data'] ?? body;
    }

    return body;
  }
}

abstract class ParsingErrorReporterInterface {
  FutureOr<void> report(ParsingErrorReport report);
}
