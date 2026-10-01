import 'package:dio/dio.dart';

import 'native_interceptors_stub.dart'
    if (dart.library.io) 'native_interceptors_io.dart'
    as impl;

/// Certificate pinning is impossible on web (the browser owns the TLS stack),
/// and `http_certificate_pinning` is a native-only package.
/// Returns `null` on web so callers can simply skip it.
Interceptor? certificatePinningInterceptor(
  List<String> allowedSHAFingerprints,
) => impl.certificatePinningInterceptor(allowedSHAFingerprints);
