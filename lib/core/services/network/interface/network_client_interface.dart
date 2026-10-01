import '../response/either_response_model.dart';

/// Contract for all network operations.
///
/// Implementations can use Dio, http, or any other HTTP client under the hood.
/// The caller only cares about the [HttpMethod], the [endpoint], and the
/// [parser] that converts raw response data into a typed result.
///
/// Returns [EitherResponse<T>] — never throws. All errors are wrapped in
/// [ResponseFailure] with an [ApiError].
///
abstract class NetworkClientInterface {
  Future<EitherResponse<T>> request<T>({
    required HttpMethod method,
    required String endpoint,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  });
}

enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch;

  String get value => name.toUpperCase();
}
