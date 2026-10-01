import 'package:dio/dio.dart';

import '../../session_manager/session_manager.dart';

/// Automatically attaches the stored access token to every outgoing request.
///
/// This replaces the manual [ensureHeaders] call that was previously required
/// before each request. The interceptor reads the latest token from
/// [SessionManager] on every request, so it always uses the freshest value.
class HeaderInterceptor extends Interceptor {
  HeaderInterceptor(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? accessToken = await _sessionManager.accessToken;

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
