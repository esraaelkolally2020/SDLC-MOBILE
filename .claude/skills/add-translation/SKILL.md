---
name: add-translation
description: BUILD stage. Adds or updates localization keys in both assets/translations/en-US.json and ar-SA.json, and checks that the key sets match. Use whenever new user-facing text is added, or when asked to translate or fix missing translations.
argument-hint: <key> "<English>" ["<Arabic>"]
---

# Add translation

1. Pick the key: snake_case, prefixed with the feature for feature-specific text (`leave_balance_empty`). Search both files first. If an equivalent key already exists (`retry`, `cancel`, `no_data_available`), reuse it.
2. Add the key to **both** `assets/translations/en-US.json` and `assets/translations/ar-SA.json`, with the same key in the same relative position. Keep the JSON valid (watch trailing commas).
3. Arabic: write a natural Modern Standard Arabic translation. If unsure about a domain term, write your best translation and flag it in the report for review. Never paste English into `ar-SA.json`.
4. Placeholders: use `{name}` named args in both languages, the same names. In code: `'key'.tr(namedArgs: {'name': value})`.
5. Check the two files' key sets match:
   ```bash
   python3 -c "import json;a=json.load(open('assets/translations/en-US.json'));b=json.load(open('assets/translations/ar-SA.json'));f=lambda d,p='':{p+k for k in d} if not any(isinstance(v,dict) for v in d.values()) else set().union(*[f(v,p+k+'.') if isinstance(v,dict) else {p+k} for k,v in d.items()]);print('missing in ar:',sorted(f(a)-f(b)));print('missing in en:',sorted(f(b)-f(a)))"
   ```
6. Report the keys added and any translations that need review.
