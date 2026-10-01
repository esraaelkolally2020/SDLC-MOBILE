# Architecture

## Layers
```
presentation (cubit, ui)  →  domain (abstract repository, use case)  →  data (repository impl, models)  →  core
```
Each feature is a folder in `lib/features/<feature>/` with exactly this layout. `lib/features/example/` is the working reference:
```
data/model/                     request/response models (fromMap/toMap)
data/repository/                <feature>_repository_impl.dart  extends MainRepository implements <Feature>Repository
domain/repository/              <feature>_repository.dart       abstract contract
domain/use_case/                <feature>_use_case.dart         what the cubit calls
presentation/cubit/             <feature>_cubit.dart            SafeCubit<BaseState>
presentation/ui/<screen>/screen <screen>_main_screen.dart + _mobile_body / _web_body / _desktop_body
presentation/ui/<screen>/widgets
```

## Startup (`lib/main.dart`)
1. `WidgetsFlutterBinding`, then SystemChrome
2. `AppServices.init()`: localization, SharedPreferences, session, flavor
3. `AppDependencies().inject()` (`lib/di.dart`, get_it)
4. Sentry wraps `runApp` only in the prod flavor and when `SENTRY_DSN` is set; otherwise `runApp` runs directly.
   `EasyLocalization → Sizer → MyApp (MaterialApp.router)`

## Dependency injection (`lib/di.dart`)
get_it with `registerLazySingleton`, in sections: use cases → repositories → network/services.
Cubits are not registered. Route builders create them with `BlocProvider(create: (_) => XCubit(xUseCase: getIt()))`.

## Routing
- Path constants: `lib/core/data/constants/app_router.dart` (`AppRouter.initial` is the start route).
- Router: `lib/core/services/route_manager/router_manager.dart` (go_router, global `navigatorKey`, `redirect` hook for auth).

## Network layer (`lib/core/services/network/`)
```
cubit ─▶ use case ─▶ repository impl ─▶ NetworkClientInterface.request<T>() ─▶ DioNetworkClient ─▶ interceptors ─▶ API
                                          ◀── EitherResponse<T> (never throws) ◀──
```
- `interface/network_client_interface.dart`: one method, `request<T>({method, endpoint, parser, queryParameters, body, headers, timeouts})`.
- `client/dio_network_client.dart`:
  - The base URL comes from the flavor.
  - `validateStatus` accepts every status, so status errors are mapped rather than thrown.
  - Every exception becomes `ResponseFailure(NetworkException)`.
- `response/either_response_model.dart`:
  - `sealed EitherResponse<T>` with `ResponseSuccess` and `ResponseFailure`
  - `fold`, `asyncFold`, `isSuccess`, `dataOrNull`, `errorOrNull`
- `response/api_response.dart`:
  - The backend envelope: `data`, `status`, `code`, `message`, `englishMessage`/`arabicMessage`, `totalCount`.
  - `displayMessage` picks the message for the current language.
- `error/`:
  - `NetworkExceptionType` maps each status or failure to a translation key; `NetworkExceptionHandler` maps Dio errors.
  - `io_exceptions*.dart` makes `SocketException` safe to reference on web.
  - The parsing-error reporter shows a bottom sheet in the dev flavor.
- `interceptors/`:
  - `HeaderInterceptor`: language, auth token
  - `TokenInterceptor`: on a 401 it clears the session and calls an `onUnauthorized` callback (hook navigation in here)
  - `NetworkLoggerInterceptor`: debug only, masked by `log/log_sanitizer.dart`
  - `native_interceptors*.dart`: certificate pinning, native only, when `SHA_FINGERPRINTS` is set

## State
- `SafeCubit<S>` ignores `emit` after `close`.
- `BaseState` subclasses are shared by all features: `InitialState`, `LoadingState` (always unique), `LoadedState<T>`, `ErrorState`, `EmptyState<T>`, `ButtonLoadingState`, …
- UI: `BlocBuilder` + `switch` on state type; `BlocListener` for one-off effects.

## Flavors and configuration
| Flavor | Android id suffix | Base URL define |
|---|---|---|
| dev | `.dev` | `BASE_URL_DEV` |
| stage | `.stage` | `BASE_URL_STAGE` |
| prod | – | `BASE_URL_PROD` |

- The flavor comes from `FLUTTER_APP_FLAVOR`, which `--flavor` sets. On web, pass it with `--dart-define`.
- Values come from `api_end_points.env` (git-ignored) via `--dart-define-from-file`. Keys are documented in `api_end_points.env.example`.

## Web support
`dart:io` is only imported in `*_io.dart` files behind conditional exports:
- `services/platform/` (`AppPlatform`, `terminate_app`, `file_bytes`)
- `network/error/io_exceptions`
- `network/interceptors/native_interceptors`
- `pickup_module/download_file_module/cubit/download_saver` (web downloads use `package:web`)

## Localization and theme
- easy_localization with `assets/translations/{en-US,ar-SA}.json`; both files must have the same keys.
- `services/theme/app_theme.dart` defines light and dark Material 3 themes. `ThemeCubit` stores the mode.
