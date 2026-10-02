---
paths:
  - "test/**"
  - "lib/**/presentation/cubit/**"
  - "lib/**/data/model/**"
  - "lib/**/domain/**"
---
# Testing

- Tests mirror `lib/`: `test/features/<feature>/…_test.dart`. The reference is `test/features/example/example_cubit_test.dart`.
- Every new cubit method needs tests for success, empty (if it emits `EmptyState`) and failure. Every new model needs a `fromMap` test, including null fields and casing variants.
- Use hand-written fakes that implement the abstract repository. No network, no real plugins, no `mocktail`/`mockito` unless the lead approves adding it.
- Assert emitted states in order (`LoadingState` → `LoadedState`/`ErrorState`), and the data inside them.
- Test names say the behavior: `'emits ErrorState when the repository fails'`.
- A bug fix starts with a failing test that reproduces the bug.
- Tests must be deterministic: no real time, randomness or ordering assumptions.
- `flutter test` must pass before every push (`pre-push` runs it) and in CI.
- Behavior that needs a device (permissions, push, camera, deep links) goes in the spec's manual test plan for QA.
