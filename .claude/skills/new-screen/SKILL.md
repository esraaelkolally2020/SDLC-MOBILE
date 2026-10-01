---
name: new-screen
description: BUILD stage. Adds a screen to an existing feature: main screen with CustomLayoutBuilder, mobile/web/desktop bodies, route constant and GoRoute with its BlocProvider. Use when the user asks for a new page, screen or view in a feature.
argument-hint: <feature_name> <screen_name> [cubit to use]
---

# New screen

1. Create `lib/features/<feature>/presentation/ui/<screen>/screen/`:
   - `<screen>_main_screen.dart`: `CustomLayoutBuilder(appBar:, mobileBody:, webBody:, desktopBody:)` (copy `example_main_screen.dart`)
   - `<screen>_mobile_body.dart`: the real layout, with `BlocBuilder<XCubit, BaseState>` and a `switch` on state
   - `<screen>_web_body.dart` / `<screen>_desktop_body.dart`: reuse the mobile body with wider parameters unless the design differs
   - Extra widgets go in `../widgets/`, one widget per file.
2. Route: add `static const String <screen> = '/<feature>/<screen>';` to `app_router.dart`, and a `GoRoute` to `router_manager.dart`.
   - If the screen needs data passed in, use `state.extra` with a typed cast, or path or query parameters for IDs. Never pass whole models through query strings.
   - Provide the cubit with `BlocProvider(create: (_) => XCubit(xUseCase: getIt()))`. To share a cubit that already exists, use `BlocProvider.value` and pass it via `extra`.
3. Navigate with `context.push(AppRouter.<screen>)` / `context.go(...)`, never `Navigator.push` with a raw widget.
4. All text through `.tr()`. Add keys to both translation files.
5. Use `lib/core/component/` widgets (`PButton`, `PText`, `PTextField`, `CustomAppBar`, …) and theme colors.
6. `dart format lib test && flutter analyze`. If layout matters, also suggest `flutter run -d chrome` to check the web body.
