import 'dart:async';

import 'package:dio/dio.dart';

import '../../log/app_log.dart';
import '../../session_manager/session_manager.dart';

/// Intercepts 401 responses and ends the current session.
///
/// Provide [onUnauthorized] to react in the UI (e.g. navigate to login).
/// By default the stored session is cleared.
class TokenInterceptor extends Interceptor {
  TokenInterceptor({this.onUnauthorized});

  final FutureOr<void> Function()? onUnauthorized;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401) {
      _handleUnauthorized();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    try {
      if (onUnauthorized != null) {
        await onUnauthorized!();
      } else {
        await SessionManager().clearSession();
      }
    } catch (e) {
      AppLog.printValue('TokenInterceptor => $e');
    }
  }
}
