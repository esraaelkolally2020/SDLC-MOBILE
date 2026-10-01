import '../../localization/app_localization.dart';

class ApiResponse<T> {
  final T? data;
  final String? status;
  final String? statusCode;
  final String? message;
  final String? englishMessage;
  final String? arabicMessage;
  final String? errorMessage;
  final int? totalCount;

  const ApiResponse({
    this.data,
    this.status,
    this.statusCode,
    this.message,
    this.englishMessage,
    this.arabicMessage,
    this.errorMessage,
    this.totalCount,
  });

  factory ApiResponse.fromMap(
    Map<String, dynamic> map,
    T Function(dynamic data) dataParser,
  ) {
    return ApiResponse<T>(
      data: map['data'] != null ? dataParser(map['data']) : null,
      status: map['status']?.toString(),
      statusCode: map['code']?.toString() ?? map['statusCode']?.toString(),
      message: map['message']?.toString(),
      englishMessage: map['englishMessage']?.toString(),
      arabicMessage: map['arabicMessage']?.toString(),
      errorMessage: map['errorMessage']?.toString(),
      totalCount: _parseInt(map['totalCount']),
    );
  }

  factory ApiResponse.empty() {
    return ApiResponse<T>();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String? get displayMessage {
    final localized = AppLocalization.isArabic ? arabicMessage : englishMessage;

    if (localized != null && localized.trim().isNotEmpty) {
      return localized;
    }

    if (message != null && message!.trim().isNotEmpty) {
      return message;
    }

    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return errorMessage;
    }

    return null;
  }

  bool get isSuccess {
    final statusText = status?.toLowerCase();
    final codeNumber = int.tryParse(statusCode ?? '');

    return statusText == 'success' ||
        statusText == 'succeeded' ||
        codeNumber == 200 ||
        codeNumber == 201;
  }

  @override
  String toString() {
    return 'ApiResponse(data: $data, status: $status, statusCode: $statusCode, message: $message, englishMessage: $englishMessage, arabicMessage: $arabicMessage, errorMessage: $errorMessage, totalCount: $totalCount)';
  }
}
