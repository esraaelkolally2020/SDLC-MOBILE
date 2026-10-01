import 'package:dio/dio.dart';

// Web / unsupported platforms: no native certificate pinning.
Interceptor? certificatePinningInterceptor(
  List<String> allowedSHAFingerprints,
) => null;
