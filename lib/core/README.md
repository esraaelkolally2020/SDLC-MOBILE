# core/: shared code

Used by every feature. Features may import `core/`; `core/` never imports a feature.

## cubit/ and global/
| File | Purpose |
|---|---|
| `cubit/safe_cubit.dart` | Base class for every cubit. Ignores `emit` after `close`, so late async results cannot crash |
| `global/state/base_state.dart` | Shared states: `InitialState`, `LoadingState` (timestamped, not const), `LoadedState<T>`, `ErrorState`, `EmptyState<T>`, `ButtonLoadingState` and more. Add a state here only when none fits |
| `global/enums/global_enum.dart` | Shared enums |
| `global/global_func.dart` | Small shared helper functions |

## data/
| File / folder | Purpose |
|---|---|
| `constants/api_endpoints_constants.dart` | Every endpoint as a `static const String`. No inline URLs anywhere else |
| `constants/app_router.dart` | Route path constants; `AppRouter.initial` is the start route |
| `constants/app_colors.dart` | Brand colors. Prefer `Theme.of(context).colorScheme` in widgets |
| `constants/dimensions.dart`, `global_obj.dart`, `shared_preferences_constants.dart` | Shared sizes, global objects such as the navigator key, and SharedPreferences keys |
| `app_dimensions/app_dimensions.dart` | Responsive spacing and size values |
| `assets_helper/app_icon.dart`, `app_svg_icon.dart` | Typed asset paths. Never use raw asset strings |
| `repository/main_repository.dart` | Base class of repository implementations; exposes `remoteData` (the network client) |

## extensions/
`string_extensions.dart`, `datetime_extension.dart`, `navigator_extensions.dart`: small helpers on `String`, `DateTime` and navigation.

## component/: shared widgets (check here before writing a widget)
| Folder | Widgets |
|---|---|
| `appbar/` | `CustomAppBar` |
| `button/` | `PButton`, `PullToConfirmButton` (`pulled_button.dart`), `RetryButton` |
| `text/` | `PText` |
| `text_field/` | `PTextField` |
| `image/` | `PImage` |
| `custom_dialog/`, `custom_bottom_sheet/` | `showCustomDialog`, `showCustomBottomSheet` |
| `custom_toast/` | `PToast` messages |
| `custom_loader/` | `CustomLoader` |
| `layout_builder/` | `CustomLayoutBuilder` (mobile, web, desktop bodies) |
| `list_view/`, `pagination/` | `PagedListView` and `PaginatedController` for paginated lists |

## services/
| Folder | Purpose |
|---|---|
| `network/` | The network layer, below |
| `route_manager/` | `router_manager.dart` (go_router config, global navigator key, `redirect` hook for auth), `logging_observer.dart` (logs route changes by route name) |
| `platform/` | `AppPlatform` (`isAndroid`, `isIOS`, `isWeb`) and the `_stub/_io/_web` facades `file_bytes`, `terminate_app`. The only place `dart:io` may appear is in `*_io.dart` files |
| `local_storage/` | `secure_storage_service.dart` for tokens and session data (flutter_secure_storage); `shared_preference_service.dart` for non-sensitive settings |
| `session_manager/` | Holds session and token state; cleared on 401 |
| `flavorizer/` | dev, stage and prod flavor model and base-URL selection (`FLUTTER_APP_FLAVOR`, `BASE_URL_*`) |
| `localization/` | easy_localization setup |
| `theme/` | `app_theme.dart` (light and dark Material 3), `theme_cubit.dart` (stores the mode) |
| `connectivity/` | Online/offline listener, state model and default UI actions |
| `log/app_log.dart` | The only allowed logger. Debug only. Never `print`; never log tokens or PII |
| `sentry/app_sentry.dart` | Crash reporting, prod flavor only when `SENTRY_DSN` is set |

### services/network/
```
cubit → use case → repository impl → NetworkClientInterface.request<T>() → DioNetworkClient → interceptors → API
                                       ← EitherResponse<T> (never throws) ←
```
| File | Purpose |
|---|---|
| `interface/network_client_interface.dart` | The one method features use: `request<T>({method, endpoint, parser, queryParameters, body, headers, timeouts})` |
| `client/dio_network_client.dart` | Dio implementation. Base URL from the flavor; accepts every status and maps it; turns every exception into `ResponseFailure` |
| `response/either_response_model.dart` | `sealed EitherResponse<T>` (`ResponseSuccess` / `ResponseFailure`) with `fold`, `asyncFold`, `isSuccess`, `dataOrNull`, `errorOrNull` |
| `response/api_response.dart` | The backend envelope (`data`, `status`, `code`, `message`, `englishMessage`/`arabicMessage`, `totalCount`) and `displayMessage` for the current language |
| `error/network_exception.dart`, `network_exception_handler.dart`, `network_error_handler_interface.dart` | Map Dio errors and status codes to typed exceptions with translation keys |
| `error/io_exceptions*.dart` | Web-safe reference to `SocketException` |
| `error/*parsing_error*` | Parsing-error reporter; shows a bottom sheet in the dev flavor |
| `interceptors/header_interceptor.dart` | Adds language and auth token headers |
| `interceptors/token_interceptor.dart` | On 401 clears the session and calls `onUnauthorized` (hook navigation here) |
| `interceptors/network_logger_interceptor.dart` | Debug-only request logging, masked by the sanitizer |
| `interceptors/native_interceptors*.dart` | Certificate pinning, native only, when `SHA_FINGERPRINTS` is set |
| `log/log_sanitizer.dart`, `log_error_handler_interface.dart` | Mask tokens and PII in logs |

## pickup_module/download_file_module/
A reusable file-download feature with its own cubit, repository and use case. `cubit/download_saver*.dart` is the `_stub/_io/_web` saver: web downloads use `package:web`, native uses `dart:io`.
