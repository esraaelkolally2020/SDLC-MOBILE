---
name: new-feature
description: BUILD stage. Scaffolds a complete feature in lib/features/<name>/ (model, abstract + impl repository, use case, cubit, main/mobile/web/desktop screens), registers DI and the route, adds translations, then runs analyze. Use when the user asks to create or add a new feature or module.
argument-hint: <feature_name> [spec path]
---

# New feature

Use `lib/features/example/` as the template. Read its files before generating, and copy their style exactly.

## Inputs
- `feature_name` in snake_case (e.g. `leave_balance`). Derive `Feature` = PascalCase and `feature` = camelCase.
- If `docs/specs/<feature_name>.md` exists, take the endpoints, models, screens and translations from it. Otherwise ask for the endpoint path(s) and the response JSON. Don't guess field names.

## Files to create
```
lib/features/<f>/data/model/<f>_response_model.dart            (+ <f>_request_model.dart if it takes params)
lib/features/<f>/data/repository/<f>_repository_impl.dart
lib/features/<f>/domain/repository/<f>_repository.dart
lib/features/<f>/domain/use_case/<f>_use_case.dart
lib/features/<f>/presentation/cubit/<f>_cubit.dart
lib/features/<f>/presentation/ui/<f>/screen/<f>_main_screen.dart
lib/features/<f>/presentation/ui/<f>/screen/<f>_mobile_body.dart
lib/features/<f>/presentation/ui/<f>/screen/<f>_web_body.dart
lib/features/<f>/presentation/ui/<f>/screen/<f>_desktop_body.dart
lib/features/<f>/presentation/ui/<f>/widgets/                   (only if needed)
```

## Templates (real backend: ApiResponse envelope)

Repository contract:
```dart
abstract class FeatureRepository {
  Future<EitherResponse<ApiResponse<List<FeatureModel>?>>> getFeatures({required FeatureRequestModel query});
}
```

Implementation:
```dart
class FeatureRepositoryImpl extends MainRepository implements FeatureRepository {
  FeatureRepositoryImpl({required super.remoteData});

  @override
  Future<EitherResponse<ApiResponse<List<FeatureModel>?>>> getFeatures({required FeatureRequestModel query}) {
    return remoteData.request(
      method: HttpMethod.get,
      endpoint: ApiEndpointsConstants.features,
      queryParameters: query.toMap(),
      parser: (data) => ApiResponse.fromMap(
        data,
        (d) => (d as List?)?.map((e) => FeatureModel.fromMap(e as Map<String, dynamic>)).toList(),
      ),
    );
  }
}
```

Use case: one method per repository method, forwarding the call (see `example_use_case.dart`).

Cubit:
```dart
class FeatureCubit extends SafeCubit<BaseState> {
  final FeatureUseCase featureUseCase;
  FeatureCubit({required this.featureUseCase}) : super(const InitialState());

  Future<void> getFeatures(FeatureRequestModel query) async {
    emit(LoadingState());
    final response = await featureUseCase.getFeatures(query: query);
    response.fold(
      (failure) => emit(ErrorState(failure.message)),
      (success) {
        final items = success?.data ?? [];
        emit(items.isEmpty ? const EmptyState(null) : LoadedState(items));
      },
    );
  }
}
```

Screens: copy `example_main_screen.dart`, `example_mobile_body.dart`, `example_web_body.dart` and `example_desktop_body.dart`, then rename. Keep the `switch` on states, and use `lib/core/component/` widgets where they fit.

## Wiring (edit existing files; keep their section order)
1. `lib/core/data/constants/api_endpoints_constants.dart`: `static const String features = '/api/...';`
2. `lib/core/data/constants/app_router.dart`: `static const String feature = '/feature';`
3. `lib/core/services/route_manager/router_manager.dart`: add a GoRoute:
   ```dart
   GoRoute(
     path: AppRouter.feature,
     builder: (context, state) => BlocProvider(
       create: (_) => FeatureCubit(featureUseCase: getIt())..getFeatures(const FeatureRequestModel()),
       child: const FeatureMainScreen(),
     ),
   ),
   ```
4. `lib/di.dart`: in the use cases section, `getIt.registerLazySingleton<FeatureUseCase>(() => FeatureUseCase(featureRepository: getIt()));`. In the repositories section, `getIt.registerLazySingleton<FeatureRepository>(() => FeatureRepositoryImpl(remoteData: getIt()));`.
5. Translations: run the `/add-translation` steps for every new key (title, empty and error text) in **both** JSON files.

## Finish
1. `dart format lib test`
2. `flutter analyze`: fix everything this feature introduced.
3. Report: the files created, the files edited, the route path, and anything left as a TODO for the user (e.g. design details).

Rules to respect: `.claude/rules/architecture.md`, `state-management.md`, `networking.md`, `ui-components.md`, `platform-web.md`.
