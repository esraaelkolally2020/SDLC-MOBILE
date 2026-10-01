import 'package:starter_app/core/services/session_manager/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../data/constants/api_endpoints_constants.dart';
import '../../flavorizer/flavors_managment.dart';
import '../error/network_error_handler_interface.dart';
import '../error/network_exception.dart';
import '../error/network_exception_handler.dart';
import '../interceptors/header_interceptor.dart';
import '../interceptors/native_interceptors.dart';
import '../interceptors/network_logger_interceptor.dart';
import '../interceptors/token_interceptor.dart';
import '../interface/network_client_interface.dart';
import '../response/either_response_model.dart';

/// Dio-based implementation of [NetworkClientInterface].
///
/// Uses the same interceptors, base options, and header management
/// as the legacy DioClient for full compatibility.
///
/// Returns [EitherResponse<T>] — never throws. All errors are wrapped
/// in [ResponseFailure] with an [ApiError].
///
/// Usage:
/// ```dart
/// final client = DioNetworkClient();
///
/// final result = await client.request<UserModel>(
///   method: HttpMethod.get,
///   endpoint: '/api/user/1',
///   parser: (data) => UserModel.fromMap(data as Map<String, dynamic>),
/// );
///
/// result.fold(
///   (error) => print(error.message),
///   (user) => print(user.name),
/// );
/// ```
///

String get _baseUrl => DioNetworkClient.baseUrl;

String _resolveBaseUrl() {
  final String? flavorUrl = FlavorsManagement.instance.getCurrentFlavor.baseUrl;
  return (flavorUrl == null || flavorUrl.isEmpty)
      ? ApiEndpointsConstants.baseUrl
      : flavorUrl;
}

class DioNetworkClient implements NetworkClientInterface {
  /// Current flavor's base URL, falling back to [ApiEndpointsConstants.baseUrl].
  static String get baseUrl => _resolveBaseUrl();

  DioNetworkClient({NetworkErrorHandlerInterface? errorHandler, Dio? dio})
    : _errorHandler =
          errorHandler ?? NetworkExceptionHandler(baseUrl: _baseUrl) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 360),
            // validateStatus: (_) => true --> This tells Dio:
            // Do not throw a DioException.badResponse for any HTTP response status
            // Always return a Response object if the server responded discarding status code
            // But in cases like connectionTimeout, sendTimeout, receiveTimeout, badCertificate, connectionError, unknow
            // It will throws exceptions with these exceptions
            validateStatus: (_) => true,
            headers: <String, dynamic>{
              Headers.acceptHeader: '*/*',
              Headers.contentTypeHeader: 'application/json; charset=UTF-8',
            },
          ),
        );

    _addInterceptors();
  }

  late final Dio _dio;
  late final NetworkErrorHandlerInterface _errorHandler;

  /// Exposes raw Dio for special cases like downloads/uploads.
  /// Prefer using [request] for normal API calls.
  Dio get dio => _dio;

  // ════════════════════════════════════════════════════════════════════════════
  // CONFIG
  // ════════════════════════════════════════════════════════════════════════════

  void _addInterceptors() {
    _dio.interceptors.add(HeaderInterceptor(SessionManager()));
    _dio.interceptors.add(TokenInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(NetworkLoggerInterceptor());
    }

    // Pinning is skipped when no fingerprints are configured
    // (dart-define `SHA_FINGERPRINTS`) and on web, where it is impossible.
    final List<String> fingerPrints = ApiEndpointsConstants.fingerPrints;
    if (fingerPrints.isNotEmpty) {
      final Interceptor? pinning = certificatePinningInterceptor(fingerPrints);
      if (pinning != null) _dio.interceptors.add(pinning);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // NETWORK CLIENT INTERFACE
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Future<EitherResponse<T>> request<T>({
    required HttpMethod method,
    required String endpoint,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    final String methodName = method.value;
    Response<dynamic>? response;

    try {
      response = await _dio.request(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          method: methodName,
          headers: headers,
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
        ),
      );

      return await handleResponse<T>(
        response: response,
        parser: parser,
        endpoint: endpoint,
        methodName: methodName,
        headers: headers,
        queryParameters: queryParameters,
        requestBody: body,
      );
    } catch (e, s) {
      return ResponseFailure<T>(
        error: _errorHandler.handle(
          e,
          stackTrace: s,
          endpoint: endpoint,
          method: methodName,
          headers: headers,
          requestBody: body,
          queryParameters: queryParameters,
          responseBody: response?.data,
          statusCode: response?.statusCode,
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  Response MANAGEMENT
  // ════════════════════════════════════════════════════════════════════════════

  /// Handle response based on status code
  Future<EitherResponse<T>> handleResponse<T>({
    required Response<dynamic> response,
    required T Function(dynamic data) parser,
    required String endpoint,
    required String methodName,
    Map<String, dynamic>? headers,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
  }) async {
    final bool isSuccess =
        (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;

    late T? data;

    try {
      data = parser(response.data);
    } catch (e) {
      return ResponseFailure<T>(
        error: _errorHandler.handle(
          ParsingDataException(message: e.toString()),
          statusCode: response.statusCode,
          responseBody: response.data,
          endpoint: endpoint,
          method: methodName,
          stackTrace: StackTrace.current,
          headers: headers,
          requestBody: requestBody,
          queryParameters: queryParameters,
        ),
      );
    }

    if (isSuccess) {
      return ResponseSuccess<T>(data: data);
    }

    return ResponseFailure<T>(
      error: _errorHandler.handle(
        response.statusCode != null
            ? StatusCodeException(statusCode: response.statusCode!)
            : 'unknown',

        statusCode: response.statusCode,
        responseBody: response.data,
        endpoint: endpoint,
        method: methodName,
        stackTrace: StackTrace.current,
        headers: headers,
        requestBody: requestBody,
        queryParameters: queryParameters,
      ),
    );
  }
}
