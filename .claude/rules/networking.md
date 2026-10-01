---
paths:
  - "lib/**/data/**"
  - "lib/**/domain/**"
  - "lib/core/services/network/**"
  - "lib/core/data/constants/api_endpoints_constants.dart"
---
# Networking

- All HTTP goes through `NetworkClientInterface.request<T>()` (`lib/core/services/network/interface/`). Never use `Dio` or `http` directly in a feature.
- `request` **never throws**. It returns `EitherResponse<T>`: `ResponseSuccess` or `ResponseFailure(NetworkException)`. Don't wrap calls in try/catch. Handle failure with `fold`, `asyncFold`, `dataOrNull` or `errorOrNull`.
- Backend responses use the standard envelope. Parse with `ApiResponse.fromMap(data, (d) => ...)`, so repositories return `EitherResponse<ApiResponse<T>>`. `ApiResponse.displayMessage` picks the message for the current language.
- Endpoints are `static const String` values in `ApiEndpointsConstants`. Never inline URL strings. The base URL comes from the flavor (`BASE_URL_*` dart-defines).
- Repositories `extend MainRepository implements <Feature>Repository` and use `remoteData`.
  ```dart
  @override
  Future<EitherResponse<ApiResponse<List<ItemModel>?>>> getItems({required ItemsRequestModel query}) {
    return remoteData.request(
      method: HttpMethod.get,
      endpoint: ApiEndpointsConstants.items,
      queryParameters: query.toMap(),
      parser: (data) => ApiResponse.fromMap(
        data,
        (d) => (d as List?)?.map((e) => ItemModel.fromMap(e as Map<String, dynamic>)).toList(),
      ),
    );
  }
  ```
- Models are hand-written: `final` nullable fields, a `const` constructor, `factory fromMap`, `toMap`, `toString`. If the backend uses inconsistent casing, read both keys: `map['Id'] ?? map['id']`.
- Request models expose `toMap()` for query and body. Leave null values out.
- Auth headers and token refresh are handled by `HeaderInterceptor`/`TokenInterceptor`. Don't add headers per call unless the endpoint needs special ones.
- Never log request or response bodies yourself. `NetworkLoggerInterceptor` uses `log_sanitizer` to mask tokens and PII.
