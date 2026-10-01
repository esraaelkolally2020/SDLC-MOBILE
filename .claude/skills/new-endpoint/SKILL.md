---
name: new-endpoint
description: BUILD stage. Adds one API call to an existing feature through every layer (endpoint constant → request/response model → abstract repository → repository impl → use case → cubit method). Use when the user asks to call, integrate or add an API or endpoint in a feature that already exists.
argument-hint: <feature_name> <METHOD> <path> [description]
---

# New endpoint

## Inputs
Feature folder, HTTP method, path, request params or body, and a sample response JSON. Ask if the response shape is missing.

## Steps (in this order, one method name used throughout, e.g. `getLeaveBalance`)
1. **Endpoint**: in `lib/core/data/constants/api_endpoints_constants.dart`, add `static const String leaveBalance = '/api/...';` next to related endpoints.
2. **Models**: in `data/model/`, add `<name>_request_model.dart` (fields, const constructor, `toMap()` without nulls) and/or `<name>_response_model.dart` (`fromMap`, `toMap`, `toString`). Reuse an existing model if one already matches.
3. **Contract**: in `domain/repository/<feature>_repository.dart`, add the abstract method that returns `Future<EitherResponse<ApiResponse<T>>>`.
4. **Impl**: in `data/repository/<feature>_repository_impl.dart`, add the `@override` that calls `remoteData.request(method: HttpMethod.x, endpoint: ..., queryParameters:/body: ..., parser: (data) => ApiResponse.fromMap(data, (d) => ...))`.
   - GET: `queryParameters: query.toMap()`. POST, PUT, PATCH: `body: request.toMap()`. Multipart: `body: FormData.fromMap(...)`.
5. **Use case**: in `domain/use_case/<feature>_use_case.dart`, add a forwarding method.
6. **Cubit**: add a method using the standard `emit(LoadingState()) → fold → ErrorState/LoadedState` shape.
   - For submit actions, use `ButtonLoadingState`, and show `ApiResponse.displayMessage` on success via a `BlocListener`.
7. Add translations for any new user-facing message (`/add-translation`).
8. `dart format lib test && flutter analyze`.

Never call `NetworkClientInterface` from a cubit, and never add try/catch around `request`. It never throws.
