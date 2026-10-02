---
name: add-tests
description: BUILD stage. Writes unit tests for a feature's cubit, use case and models following test/features/example/ (hand-written fakes, no mocking package). Use after /new-feature or /new-endpoint, when the spec has acceptance criteria to cover, or when asked to add or fix tests.
argument-hint: <feature_name>
---

# Add tests

## Steps
1. Read `.claude/rules/testing.md`, `test/features/example/example_cubit_test.dart` and the feature's cubit, use case, repository interface and models. Read the spec's acceptance criteria if `docs/specs/<feature>.md` exists.
2. Create `test/features/<feature>/` mirroring `lib/features/<feature>/`:
   - `<feature>_cubit_test.dart`: for each cubit method, test the success path (Loading → Loaded), the empty path if the method emits `EmptyState`, and the failure path (Loading → Error with the message). Use a private `_Fake<Feature>Repository` that implements the abstract repository and returns a canned `EitherResponse`
   - `<name>_model_test.dart`: `fromMap` with a full sample, with missing/null fields, and with casing variants if the model reads both; `toMap` omits nulls
   - Use-case tests only when the use case contains logic beyond forwarding
3. Failure responses: build them with `ResponseFailure(NetworkException...)` as the example does. Do not reach the network.
4. Run `flutter test test/features/<feature>` and fix until green. Then `dart format test`.
5. Report which acceptance criteria are covered by tests and which are manual for QA.

## Rules
- No `mocktail`, `mockito` or network calls. Add a package only after the lead approves.
- Tests assert behavior (emitted states, parsed values), not implementation details.
- A test that needs real device, plugin or platform behavior is a manual QA case, not a unit test.
