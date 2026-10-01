---
paths:
  - "lib/**/presentation/**"
  - "lib/core/cubit/**"
  - "lib/core/global/state/**"
---
# State management

- Every cubit extends `SafeCubit<BaseState>` (`lib/core/cubit/safe_cubit.dart`). It ignores `emit` after `close`, so async callbacks can't crash.
- Use the shared states in `lib/core/global/state/base_state.dart`: `InitialState`, `LoadingState()`, `LoadedState<T>(data)`, `ErrorState(message)`, `EmptyState(data)`, `ButtonLoadingState`, and others.
  Add a new state class there only when no existing one fits. Don't create per-feature state files.
- `LoadingState()` has a timestamp, so emitting it twice still rebuilds. It isn't `const`.
- Standard method shape:
  ```dart
  Future<void> getX() async {
    emit(LoadingState());
    final response = await xUseCase.getX();
    response.fold(
      (failure) => emit(ErrorState(failure.message)),
      (success) => emit(LoadedState(success)),
    );
  }
  ```
- Use `Bloc` with events only for multi-step flows that need event transformers (debounce, queue). The example is `core/component/media_upload/upload_bloc` in older projects.
- Create cubits in `BlocProvider` in the route builder or a parent widget, never in `build` and never in get_it.
- In widgets: `BlocBuilder<XCubit, BaseState>` with a `switch` on state types. Use `BlocListener` for one-off effects (toast, navigation). Use `context.read<XCubit>()` for calls.
- Keep mutable public fields on cubits to a minimum. Prefer putting the data in `LoadedState`.
