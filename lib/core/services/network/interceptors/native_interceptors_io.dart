import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

Interceptor? certificatePinningInterceptor(
  List<String> allowedSHAFingerprints,
) => CertificatePinningInterceptor(
  allowedSHAFingerprints: allowedSHAFingerprints,
);
