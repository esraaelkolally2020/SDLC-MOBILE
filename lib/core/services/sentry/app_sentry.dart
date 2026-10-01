import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../network/log/log_error_handler_interface.dart';
import '../network/log/log_sanitizer.dart';

class AppSentryLogger with LogSanitizer implements LogErrorHandlerInterface {
  AppSentryLogger._();

  static final AppSentryLogger instance = AppSentryLogger._();

  // ════════════════════════════════════════════════════════════════════════════
  // USER IDENTITY
  // ════════════════════════════════════════════════════════════════════════════

  /// Cached user information.
  ///
  /// This avoids retrieving user information from storage every time
  /// an error is reported.
  static String? _userId;
  static String? _userName;

  /// Sets the currently authenticated user in Sentry.
  ///
  /// Call this after successful login.
  static Future<void> setUserIdentity({
    required String userId,
    required String userName,
  }) async {
    _userId = userId;
    _userName = userName;

    if (!_initialized) {
      return;
    }

    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, username: userName));
    });
  }

  /// Clears the user identity from Sentry.
  ///
  /// Call this on logout.
  static Future<void> clearUserIdentity() async {
    _userId = null;
    _userName = null;

    if (!_initialized) {
      return;
    }

    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOG ERROR HANDLER
  // ════════════════════════════════════════════════════════════════════════════

  @override
  void logError({
    required Object error,
    StackTrace? stackTrace,
    required String endpoint,
    required String method,
    required String baseUrl,
    int? statusCode,
    String? message,
    String? errorType,
    Map<String, dynamic>? headers,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    Object? responseBody,
  }) {
    // Keep this interface synchronous.
    //
    // Sentry reporting happens asynchronously without blocking the
    // network error handler.
    unawaited(
      _logErrorAsync(
        error: error,
        stackTrace: stackTrace,
        endpoint: endpoint,
        method: method,
        baseUrl: baseUrl,
        statusCode: statusCode,
        message: message,
        errorType: errorType,
        headers: headers,
        requestBody: requestBody,
        queryParameters: queryParameters,
        responseBody: responseBody,
      ),
    );
  }

  Future<void> _logErrorAsync({
    required Object error,
    StackTrace? stackTrace,
    required String endpoint,
    required String method,
    required String baseUrl,
    int? statusCode,
    String? message,
    String? errorType,
    Map<String, dynamic>? headers,
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    Object? responseBody,
  }) async {
    // Skip expected business errors — API returned a proper response
    // (e.g. "invalid credentials", "resource not found") that the app
    // already handles. Only log unexpected/parsing errors for these codes.

    if (statusCode != null &&
        expectedStatusCodes.contains(statusCode) &&
        errorType != 'parsing') {
      return;
    }
    // Add breadcrumb first so the event has a lightweight network trail.
    await addBreadcrumb(
      category: 'network.error',
      message: '$method $endpoint',
      data: <String, dynamic>{
        'status_code': ?statusCode,
        'exception_type': errorType ?? 'unknown',
        'message': ?message,
      },
      level: SentryLevel.error,
    );

    await captureException(
      error,
      stackTrace: stackTrace,
      hint: 'network_${errorType ?? 'unknown'}',
      tags: <String, String>{
        'layer': 'network',
        'method': method,
        'endpoint': endpoint,
        'exception_type': errorType ?? 'unknown',
        if (statusCode != null) 'status_code': statusCode.toString(),
        'user_id': ?_userId,
      },
      extras: <String, dynamic>{
        'url': '$baseUrl$endpoint',
        'status_code': statusCode,
        'exception_type': errorType,
        'user_id': _userId,
        'user_name': _userName,
        'headers': sanitizeMap(headers),
        'response_body': safeSerialize(responseBody),
        'request_body': safeSerialize(requestBody),
        'query_parameters': queryParameters,
        'message': message,
      },

      // Group network issues using stable properties.
      fingerprint: <String>[
        errorType ?? 'unknown',
        method,
        endpoint,
        if (statusCode != null) statusCode.toString(),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════════

  static late String _projectName;
  static late String _environment;
  static late String _release;

  static bool _initialized = false;

  static String get projectName => _projectName;
  static String get environment => _environment;
  static String get release => _release;
  static bool get isInitialized => _initialized;

  static Future<void> init({
    required String dsn,
    required String environment,
    required String release,
    required String projectName,
    required Future<void> Function() appRunner,
    double tracesSampleRate = 1.0,
    double profilesSampleRate = 1.0,
    bool enableLogsInDebug = true,
    bool sendInitTestMessage = false,
    bool enabled = true,
  }) async {
    _projectName = projectName.trim();
    _environment = environment.trim();
    _release = release.trim();

    // -------------------------------------------------------------------------
    // Sentry disabled
    // -------------------------------------------------------------------------

    if (!enabled) {
      await appRunner();
      return;
    }

    if (kDebugMode && enableLogsInDebug) {
      debugPrint('SENTRY_INIT environment=$_environment');
      debugPrint('SENTRY_INIT release=$_release');
      debugPrint('SENTRY_INIT projectName=$_projectName');
    }

    // -------------------------------------------------------------------------
    // Initialize Sentry
    // -------------------------------------------------------------------------

    await SentryFlutter.init(
      (options) {
        // Don't expose the DSN in debug logs.
        options.dsn = kDebugMode ? '' : dsn;

        options.environment = _environment;
        options.release = _release;

        options.debug = kDebugMode;

        options.tracesSampleRate = tracesSampleRate;

        // ignore: experimental_member_use
        options.profilesSampleRate = profilesSampleRate;

        options.attachScreenshot = false;

        // ignore: experimental_member_use
        options.attachViewHierarchy = false;

        options.beforeSend = (event, hint) {
          event.tags = <String, String>{
            ...?event.tags,
            'app_project': _projectName,
            'app_environment': _environment,
            'app_release': _release,
          };

          if (kDebugMode && enableLogsInDebug) {
            debugPrint('SENTRY_EVENT => ${event.eventId}');

            debugPrint('SENTRY_EVENT_TAGS => ${event.tags}');
          }

          return event;
        };
      },
      appRunner: () async {
        _initialized = true;

        // ---------------------------------------------------------------------
        // Global Sentry scope
        // ---------------------------------------------------------------------

        await _configureGlobalScope();

        // ---------------------------------------------------------------------
        // Flutter error handlers
        // ---------------------------------------------------------------------

        _installFlutterErrorHandlers();

        // ---------------------------------------------------------------------
        // Optional startup test
        // ---------------------------------------------------------------------

        if (sendInitTestMessage) {
          await Sentry.captureMessage(
            'Sentry init test message',
            level: SentryLevel.info,
          );
        }

        // ---------------------------------------------------------------------
        // Run application
        // ---------------------------------------------------------------------

        await appRunner();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GLOBAL SCOPE
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> _configureGlobalScope() async {
    await Sentry.configureScope((scope) {
      // -----------------------------------------------------------------------
      // Application tags
      // -----------------------------------------------------------------------

      scope.setTag('app_project', _projectName);

      scope.setTag('app_environment', _environment);

      scope.setTag('app_release', _release);

      // -----------------------------------------------------------------------
      // Restore user context if identity was already set before Sentry init
      // -----------------------------------------------------------------------

      if (_userId != null) {
        scope.setUser(SentryUser(id: _userId, username: _userName));
      }
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GLOBAL FLUTTER ERROR HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  static void _installFlutterErrorHandlers() {
    // -------------------------------------------------------------------------
    // Flutter framework errors
    // -------------------------------------------------------------------------

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);

      unawaited(
        captureException(
          details.exception,
          stackTrace: details.stack,
          hint: 'flutter_error',
          tags: <String, String>{
            'layer': 'flutter',
            'error_type': 'flutter_framework_error',
          },
          extras: <String, dynamic>{
            'library': details.library,
            'context': details.context?.toDescription(),
            'silent': details.silent,
          },
        ),
      );
    };

    // -------------------------------------------------------------------------
    // Uncaught asynchronous errors
    // -------------------------------------------------------------------------

    PlatformDispatcher.instance.onError =
        (Object error, StackTrace stackTrace) {
          unawaited(
            captureException(
              error,
              stackTrace: stackTrace,
              hint: 'platform_dispatcher_error',
              tags: <String, String>{
                'layer': 'flutter',
                'error_type': 'uncaught_async_error',
              },
            ),
          );

          return true;
        };
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BASE TAGS
  // ════════════════════════════════════════════════════════════════════════════

  static Map<String, String> _baseTags() {
    return <String, String>{
      if (_projectName.trim().isNotEmpty) 'app_project': _projectName,
      if (_environment.trim().isNotEmpty) 'app_environment': _environment,
      if (_release.trim().isNotEmpty) 'app_release': _release,
    };
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CAPTURE EXCEPTION
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> captureException(
    dynamic error, {
    StackTrace? stackTrace,
    String? hint,
    Map<String, String>? tags,
    Map<String, dynamic>? extras,
    List<String>? fingerprint,
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint(
          'Sentry not initialized. '
          'Skipping captureException: $error',
        );
      }

      return;
    }

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        final Map<String, String> mergedTags = <String, String>{
          ..._baseTags(),
          ...?tags,
        };

        if (hint != null && hint.trim().isNotEmpty) {
          scope.setTag('hint', hint);
        }

        mergedTags.forEach(scope.setTag);

        // Store additional data as a Sentry context.
        if (extras != null && extras.isNotEmpty) {
          scope.setContexts('additional_data', extras);
        }

        if (fingerprint != null && fingerprint.isNotEmpty) {
          scope.fingerprint = fingerprint;
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CAPTURE MESSAGE
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.error,
    Map<String, String>? tags,
    Map<String, dynamic>? extras,
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint(
          'Sentry not initialized. '
          'Skipping captureMessage: $message',
        );
      }

      return;
    }

    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        final Map<String, String> mergedTags = <String, String>{
          ..._baseTags(),
          ...?tags,
        };

        mergedTags.forEach(scope.setTag);

        if (extras != null && extras.isNotEmpty) {
          scope.setContexts('additional_data', extras);
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BREADCRUMBS
  // ════════════════════════════════════════════════════════════════════════════

  static Future<void> addBreadcrumb({
    required String message,
    required String category,
    String? type,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_initialized) {
      return;
    }

    await Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        type: type,
        data: <String, dynamic>{
          'app_project': _projectName,
          'app_environment': _environment,
          'app_release': _release,
          ...?data,
        },
        level: level,
      ),
    );
  }
}
