import 'network_exception.dart';

abstract class NetworkErrorHandlerInterface {
  const NetworkErrorHandlerInterface({required this.baseUrl});

  final String baseUrl;

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
  });
}
