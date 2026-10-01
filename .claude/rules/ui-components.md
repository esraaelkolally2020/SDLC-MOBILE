---
paths:
  - "lib/**/presentation/ui/**"
  - "lib/core/component/**"
---
# UI and components

- Check `lib/core/component/` before writing a widget: `PButton`, `PText`, `PTextField`, `PImage`, `PToast`, `CustomAppBar`, `showCustomDialog`, `showCustomBottomSheet`, `CustomLoader`, `RetryButton`, `PullToConfirmButton`, `PagedListView` + `PagingController` (list_view) with `PaginatedController`, and more. Extend an existing component rather than making a near-copy.
- Each screen has a `<screen>_main_screen.dart` that returns `CustomLayoutBuilder(mobileBody:, webBody:, desktopBody:)`. The web and desktop bodies may reuse the mobile body with different parameters, as in `example_web_body.dart`.
- Colors come from `Theme.of(context).colorScheme` or `AppColors`. Text styles come from `Theme.of(context).textTheme`. No raw `Color(0x...)` or font sizes in feature code.
- Use `sizer` (`.w`, `.h`, `.sp`) or `AppDimensions` for responsive sizes. Avoid magic numbers in layout. Small fixed paddings (4/8/12/16) are fine.
- Make widgets `const` wherever you can. The analyzer flags non-const constructors as warnings.
- Split a widget into its own file under `widgets/` once it passes ~80 lines or is reused. Use private `_Widget` classes for one-off pieces in the same file.
- No business logic in widgets. Widgets read state and call cubit methods.
- Asset paths come from the constants in `lib/core/data/assets_helper/`. Never use raw strings.
- RTL: Arabic is supported. Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end`, not `left`/`right`.
