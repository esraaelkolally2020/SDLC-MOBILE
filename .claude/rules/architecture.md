---
paths:
  - "lib/**"
---
# Architecture

Each feature lives in `lib/features/<feature_name>/` (snake_case) and uses exactly these folders:

```
data/model/<name>_request_model.dart | <name>_response_model.dart
data/repository/<feature>_repository_impl.dart     extends MainRepository implements <Feature>Repository
domain/repository/<feature>_repository.dart        abstract class <Feature>Repository
domain/use_case/<feature>_use_case.dart            class <Feature>UseCase
presentation/cubit/<feature>_cubit.dart            class <Feature>Cubit extends SafeCubit<BaseState>
presentation/ui/<screen>/screen/<screen>_main_screen.dart  (+ _mobile_body, _web_body, _desktop_body)
presentation/ui/<screen>/widgets/<widget>.dart
```

Do not create `repo/`, `repos/`, `usecase/`, `usecases/`, `bloc/`, `business_logic/` or `view/`.
Older projects may use them. Don't rename existing folders unless asked.

## Dependency direction
`presentation → domain → data → core`. Never the other way.
- A cubit depends on a use case, never on a repository or `NetworkClientInterface`.
- A use case depends on the abstract repository in `domain/`, never on the `Impl`.
- Widgets never call use cases directly. They go through the cubit.
- One feature never imports another feature's `data/` or `presentation/`. Shared code goes in `lib/core/`.

## Wiring
- `lib/di.dart`: register the use case and the repository with `registerLazySingleton`, in the existing "use cases" and "repositories" sections. Cubits are **not** registered.
- `lib/core/data/constants/app_router.dart`: add the path constant.
- `lib/core/services/route_manager/router_manager.dart`: add a `GoRoute` whose builder wraps the screen in `BlocProvider(create: (_) => XCubit(xUseCase: getIt()))`.

## Reference
`lib/features/example/` is the canonical, compiling example of all of the above.
