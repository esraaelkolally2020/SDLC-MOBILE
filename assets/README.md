# assets/: translations and images

| Path | Purpose |
|---|---|
| `translations/en-US.json` | English strings. Every user-facing text is a key used as `'key'.tr()` |
| `translations/ar-SA.json` | Arabic strings. Must have exactly the same keys as en-US (CI checks this). Never leave English text here. Use `/add-translation` |
| `images/svg/` | Vector icons (preferred): `back_left`, `back_right`, `error`, `success`, `warning` |
| `images/png/` | Raster images: `empty_state.png` |

Reference assets only through the constants in `lib/core/data/assets_helper/` (`app_icon.dart`, `app_svg_icon.dart`), never raw path strings. New asset folders must be declared in `pubspec.yaml`.
