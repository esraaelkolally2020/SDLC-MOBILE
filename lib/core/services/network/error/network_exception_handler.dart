import 'dart:async';

import 'io_exceptions.dart';

import '../../log/app_log.dart';

import 'package:dio/dio.dart';

import '../../localization/app_localization.dart';
import '../log/log_error_handler_interface.dart';
import 'network_error_handler_interface.dart';
import 'network_exception.dart';
import 'parsing_error_reporter_interface.dart';

/// Centralized exception handler for the network layer.
///
/// A single [handle] method converts any error into a typed [NetworkException]
/// and logs non-interceptor errors to Sentry.
class NetworkExceptionHandler implements NetworkErrorHandlerInterface {
  final List<LogErrorHandlerInterface>? _logErrorHandlers;
  final ParsingErrorReporterInterface? _parsingErrorReporter;
  final void Function(NetworkException exception)? _onParsingErrorCallBack;

  NetworkExceptionHandler({
    required this.baseUrl,
    this._logErrorHandlers,

    this._parsingErrorReporter,
    void Function(NetworkException exception)? onParsingError,
  }) : _onParsingErrorCallBack = onParsingError;

  @override
  final String baseUrl; // You must override/provide the field if implementing

  /// Single entry point — converts **any** error into a [NetworkException].
  ///
  /// Internally switches on the error type to produce the right message,
  /// logs to Sentry when needed, and returns a typed exception.
  @override
  NetworkException handle(
    Object error, {
    StackTrace? stackTrace,
    required String endpoint,
    required String method,
    int? statusCode,
    Map<String, dynamic>? headers,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    Object? responseBody,
  }) {
    final StackTrace trace = stackTrace ?? StackTrace.current;

    final NetworkException exception = switch (error) {
      DioException() => _mapDioException(error),
      NoInternetException() || SocketException() => _simple(
        NetworkExceptionType.noInternet.displayMessage,
        NetworkExceptionType.noInternet,
        statusCode: statusCode,
        error: error,
        responseBody: responseBody,
      ),
      TimeoutException() => _simple(
        NetworkExceptionType.connectionTimeout.displayMessage,
        NetworkExceptionType.connectionTimeout,
        statusCode: statusCode,
        error: error,
        responseBody: responseBody,
      ),
      HandshakeException() => _simple(
        NetworkExceptionType.ssl.displayMessage,
        NetworkExceptionType.ssl,
        statusCode: statusCode,
        error: error,
        responseBody: responseBody,
      ),
      FormatException() => _simple(
        NetworkExceptionType.parsing.displayMessage,
        NetworkExceptionType.parsing,
        statusCode: statusCode,
        error: error,
        responseBody: responseBody,
      ),
      ParsingDataException() => _simple(
        '${NetworkExceptionType.parsing.displayMessage}: ${error.message}',
        NetworkExceptionType.parsing,
        statusCode: statusCode,
        error: error,
        responseBody: responseBody,
      ),
      StatusCodeException() => _mapStatusCodeException(
        error,
        responseBody: responseBody,
      ),
      _ => _simple(
        error.toString(),
        NetworkExceptionType.unknown,
        statusCode: statusCode,
        error: error,
        responseBody: responseBody,
      ),
    };
    AppLog.logValueAndTitle('NetworkException', exception.toString());

    try {
      _logErrorHandlers?.forEach(((log) {
        log.logError(
          error: exception,
          stackTrace: trace,
          message: exception.message,
          errorType: exception.type.name,
          endpoint: endpoint,
          baseUrl: baseUrl,
          method: method,
          statusCode: exception.statusCode ?? statusCode,
          headers: headers,
          requestBody: requestBody,
          queryParameters: queryParameters,
          responseBody: responseBody,
        );
      }));
    } catch (e) {
      AppLog.logValue('Failed to log error --> $e');
    }

    if (exception.isParsing) {
      try {
        _parsingErrorReporter?.report(
          ParsingErrorReport(
            errorMessage: exception.message,
            endpoint: endpoint,
            method: method,
            statusCode: exception.statusCode ?? statusCode,
            responseBody: responseBody,
            requestBody: requestBody,
            queryParameters: queryParameters,
            headers: headers,
          ),
        );
      } catch (e) {
        AppLog.logValue('Failed to show parsing error bottom sheet --> $e');
      }
    }

    if (exception.isParsing) {
      _onParsingErrorCallBack?.call(exception);
    }

    return exception;
  }

  /// Shorthand to build a [NetworkException] with the common fields.
  static NetworkException _simple(
    String message,
    NetworkExceptionType type, {
    int? statusCode,
    required Object error,
    Object? responseBody,
  }) {
    return NetworkException(
      message: message,
      type: type,
      statusCode: statusCode,
      error: error,
      responseBody: responseBody,
    );
  }

  /// Maps a [StatusCodeException] using the enum's own lookup.
  static NetworkException _mapStatusCodeException(
    StatusCodeException error, {
    Object? responseBody,
  }) {
    final type = NetworkExceptionType.fromStatusCode(error.statusCode);
    return _simple(
      error.responseMessage ??
          _extractMessage(responseBody) ??
          type.displayMessage,
      type,
      statusCode: error.statusCode,
      error: error,
      responseBody: responseBody,
    );
  }

  NetworkException _mapDioException(DioException e) {
    final int? statusCode = e.response?.statusCode;

    final NetworkExceptionType resolvedType = switch (e.type) {
      DioExceptionType.connectionTimeout =>
        NetworkExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout => NetworkExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout => NetworkExceptionType.receiveTimeout,
      DioExceptionType.connectionError => NetworkExceptionType.connection,
      DioExceptionType.cancel => NetworkExceptionType.cancelled,
      DioExceptionType.badCertificate => NetworkExceptionType.badCertificate,
      DioExceptionType.badResponse => NetworkExceptionType.fromStatusCode(
        statusCode,
      ),
      DioExceptionType.unknown => NetworkExceptionType.unknown,
      DioExceptionType.transformTimeout => NetworkExceptionType.unknown,
    };

    final String message = switch (e.type) {
      DioExceptionType.badResponse =>
        _extractMessage(e.response?.data) ?? resolvedType.displayMessage,
      DioExceptionType.unknown => e.message ?? resolvedType.displayMessage,
      _ => resolvedType.displayMessage,
    };

    return _simple(
      message,
      resolvedType,
      statusCode: statusCode,
      error: e,
      responseBody: e.response?.data,
    );
  }

  static String? _extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final directMessage = AppLocalization.isArabic
          ? data['arabicMessage']
          : data['englishMessage'];

      if (directMessage != null) {
        return directMessage;
      }

      final errors = data['errors'];

      if (errors is Map) {
        final messages = <String>[];

        for (final value in errors.values) {
          if (value is List) {
            messages.addAll(
              value
                  .where((item) => item != null)
                  .map((item) => item.toString()),
            );
          } else if (value != null) {
            messages.add(value.toString());
          }
        }

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }

    final String? text = data?.toString();

    if (text == null || text.trim().isEmpty) {
      return null;
    }

    return text;
  }
}
