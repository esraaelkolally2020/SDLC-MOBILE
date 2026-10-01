/// A comprehensive Logger that api request errors and parsing errors.
///
abstract class LogErrorHandlerInterface {
  const LogErrorHandlerInterface();

  void logError({
    required Object error,
    StackTrace? stackTrace,
    required String endpoint,
    required String method,
    required String baseUrl,
    int? statusCode,
    Map<String, dynamic>? headers,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    Object? responseBody,
    String? message,
    String? errorType,
  });
}

// Skip expected business errors — API returned a proper response
// (e.g. "invalid credentials", "resource not found") that the app
// already handles. Only log unexpected/parsing errors for these codes.
const expectedStatusCodes = {400, 401, 404};
