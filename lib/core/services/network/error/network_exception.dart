// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';

enum NetworkExceptionType {
  noInternet('networkNoInternet'),
  sendTimeout('networkSendTimeout'),
  receiveTimeout('networkReceiveTimeout'),
  connectionTimeout('networkConnectionTimeout'),
  connection('networkConnectionError'),
  ssl('networkSslFailed'),
  unauthorized('networkUnauthorized'),
  forbidden('networkForbidden'),
  notFound('networkNotFound'),
  server('networkServerError'),
  badRequest('networkBadRequest'),
  cancelled('networkCancelled'),
  parsing('networkParsingError'),
  badCertificate('networkBadCertificate'),
  unknown('networkUnknown');

  const NetworkExceptionType(this.localizationKey);

  /// The localization key for this error type.
  final String localizationKey;

  /// Localized user-facing message (resolved at runtime via easy_localization).
  String get displayMessage => localizationKey.tr();

  /// Resolves an HTTP status code to the appropriate [NetworkExceptionType].
  static NetworkExceptionType fromStatusCode(int? statusCode) {
    return switch (statusCode) {
      400 => badRequest,
      401 => unauthorized,
      403 => forbidden,
      404 => notFound,
      final code? when code >= 500 => server,
      _ => unknown,
    };
  }
}

class NetworkException implements Exception {
  const NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
    this.error,
    this.responseBody,
  });

  final String message;
  final NetworkExceptionType type;
  final int? statusCode;
  final Object? error;
  final Object? responseBody;

  bool get isUnauthorized =>
      statusCode == 401 || type == NetworkExceptionType.unauthorized;

  bool get isNoInternet => type == NetworkExceptionType.noInternet;

  bool get isParsing => type == NetworkExceptionType.parsing;

  @override
  String toString() {
    return 'NetworkException(message: $message, type: $type, statusCode: $statusCode, error: $error, responseBody: $responseBody)';
  }
}

class StatusCodeException implements Exception {
  final int statusCode;
  final String? responseMessage;

  const StatusCodeException({required this.statusCode, this.responseMessage});
}

class ParsingDataException implements Exception {
  final String message;

  const ParsingDataException({required this.message});
}

class NoInternetException implements Exception {
  const NoInternetException();
}
