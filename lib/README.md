# lib/: app code

| File / folder | Purpose |
|---|---|
| `main.dart` | Entry point. `WidgetsFlutterBinding`, SystemChrome, `AppServices.init()`, `AppDependencies().inject()`, then `runApp`. Wraps `runApp` in Sentry only for the prod flavor when `SENTRY_DSN` is set |
| `app_services.dart` | Startup services run before the app: localization, SharedPreferences, session, flavor |
| `di.dart` | get_it registrations in three sections: use cases, repositories, network and services. Cubits are **not** registered here; routes create them with `BlocProvider` |
| `myapp.dart` | `EasyLocalization → Sizer → MaterialApp.router` with the themes and the go_router config |
| `core/` | Shared code used by every feature. See [core/README.md](core/README.md) |
| `features/` | One folder per feature. See [features/README.md](features/README.md) |

Dependency direction: `features/*/presentation → domain → data → core`. Features never import another feature's `data/` or `presentation/`.
