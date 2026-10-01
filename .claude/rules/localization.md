---
paths:
  - "lib/**"
  - "assets/translations/**"
---
# Localization

- Every user-facing string is a key: `'leave_balance_title'.tr()` (easy_localization). Interpolation: `'hello_name'.tr(namedArgs: {'name': n})`.
- Keys are `snake_case`, prefixed with the feature for feature-specific text (`leave_balance_empty`). Shared words (`retry`, `cancel`, `save`) stay unprefixed.
- Add every new key to **both** `assets/translations/en-US.json` and `assets/translations/ar-SA.json` in the same change, with real translations. Never leave English text in the Arabic file. Use the `/add-translation` skill.
- Keep the two files' key sets identical. `/pre-pr-check` compares them.
- Format dates and numbers with locale-aware `DateFormat`/`NumberFormat` from `easy_localization`/`intl`.
