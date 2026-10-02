# features/: one folder per feature

Each feature is `lib/features/<feature_name>/` (snake_case) with exactly this layout. Rules: `.claude/rules/architecture.md`.

```
<feature>/
  data/
    model/        <name>_request_model.dart, <name>_response_model.dart   hand-written fromMap / toMap
    repository/   <feature>_repository_impl.dart     extends MainRepository, implements the abstract contract
  domain/
    repository/   <feature>_repository.dart          abstract contract (what the use case depends on)
    use_case/     <feature>_use_case.dart            what the cubit calls; one method per action
  presentation/
    cubit/        <feature>_cubit.dart               SafeCubit<BaseState>, emits shared states
    ui/<screen>/
      screen/     <screen>_main_screen.dart          CustomLayoutBuilder
                  <screen>_mobile_body.dart / _web_body.dart / _desktop_body.dart
      widgets/    one widget per file
```

## Layer responsibilities
| Layer | Does | Must not |
|---|---|---|
| presentation | Renders state, calls cubit methods, handles one-off effects with `BlocListener` | Call use cases, repositories or Dio |
| domain | Defines the repository contract and the use cases | Import `data/` implementations |
| data | Calls `NetworkClientInterface.request`, parses models | Throw (the client never throws); import presentation |

## Reference
`example/` is the working reference (`/posts` demo API):

| File | Shows |
|---|---|
| `data/model/example_response_model.dart` | A model with `fromMap`, `toMap` |
| `data/repository/example_repository_impl.dart` | `remoteData.request` with a parser (comment explains the `ApiResponse` envelope for real backends) |
| `domain/repository/example_repository.dart` | The abstract contract |
| `domain/use_case/example_use_case.dart` | A forwarding use case |
| `presentation/cubit/example_cubit.dart` | Loading → Loaded / Empty / Error |
| `presentation/ui/example/screen/example_main_screen.dart` | `CustomLayoutBuilder` entry |
| `…/example_mobile_body.dart`, `_web_body.dart`, `_desktop_body.dart` | State `switch`; web and desktop reuse the mobile body with different parameters |
| `…/widgets/example_card.dart` | A one-widget-per-file component |

Create a real feature with `/new-feature`, after its spec is approved. Delete `example/` (and its route, DI entries, endpoint constant and test) once the first real feature exists.
