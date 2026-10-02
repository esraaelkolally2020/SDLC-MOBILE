# Optional add-ons

The template leaves these out so a new project starts small. Add them when a project needs them.
Each add-on below lists the package, the init snippet and the files involved.

## Firebase (core, messaging, Firestore, Remote Config)
- Packages: `firebase_core`, `firebase_messaging`, `cloud_firestore`, `firebase_remote_config`, `flutter_local_notifications`
- Configure with `flutterfire configure --project=<id>`, once per flavor. Keep `google-services.json` and `GoogleService-Info.plist` out of git; they're ignored and the hooks block them. CI provides them.
- `main.dart`, before `AppServices.init()`:
  ```dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler); // top-level function
  ```
- Put notification code in `lib/core/services/notifications/` as a singleton service. Push token registration goes after login.

## Maps and location
- Packages: `google_maps_flutter`, `geolocator`, `geocoding`, `detect_fake_location` (Android)
- Maps API keys: inject them through Gradle `manifestPlaceholders` from `local.properties` or CI env, never hard-coded in `build.gradle.kts`.
- Wrap the location APIs in `lib/core/services/location/`. Guard web with `AppPlatform.isWeb`.

## Device security
- `flutter_security_checker` (root/jailbreak), a VPN/proxy checker, and `local_auth` (biometrics)
- Run the check in `AppServices.init()` for the prod flavor only, and show a blocked screen.

## In-app update and store checks
- `in_app_update` (Android), `upgrader` (both)

## Network inspector (dev tooling)
- A network-inspector package (for example `api_inspector`, or your team's internal one): add `InspectorInterceptor` in `DioNetworkClient`, only when the flavor is not prod.

## Device info
- `device_info_plus`, `package_info_plus`, `android_id`: wrap them in `lib/core/services/device/` and guard web.

## Code generation (if the team adopts it)
- `freezed` + `json_serializable` + `build_runner` for models, `flutter_gen` for assets. If you adopt them, update `.claude/rules/networking.md` and the `/new-feature` templates in the same PR.

> Kotlin Gradle Plugin warning: Flutter is moving plugins to built-in Kotlin. Before adding a plugin, check that its latest version supports it, so the project doesn't pick up plugins that future Flutter versions will refuse to build.
