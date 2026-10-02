# test/: unit tests

Mirrors `lib/`: `test/features/<feature>/` tests `lib/features/<feature>/`. Rules are in `.claude/rules/testing.md`; `/add-tests` writes them.

| File | What it tests |
|---|---|
| `features/example/example_cubit_test.dart` | The reference test. A hand-written `_FakeExampleRepository` drives `ExampleCubit` through: success → `LoadedState`, no items → `EmptyState`, failure → `ErrorState`, and no emit after `close()` |

For each new feature add `<feature>_cubit_test.dart` (every cubit method: success, empty, failure) and `<name>_model_test.dart` (`fromMap` with full, null and casing-variant data; `toMap` omits nulls). No network, no real plugins, no mocking package.

Run: `flutter test`. It also runs in `pre-push` and CI.
