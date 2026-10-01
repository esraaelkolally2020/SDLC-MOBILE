---
paths:
  - "**"
---
# Security

- Secrets (base URLs for private envs, DSNs, SHA fingerprints, API keys) go only in `api_end_points.env`, which is git-ignored. Code reads them with `String.fromEnvironment('KEY')`. Add every new key to `api_end_points.env.example` with an empty value and a comment.
- Never commit `*.env`, `key.properties`, `*.jks`, `*.keystore`, `*.pem`, `*.p12`, `*.cer`, `google-services.json` or `GoogleService-Info.plist`. The pre-commit hook and `.claude/hooks/block_secrets.sh` enforce this.
- No real credentials or test-account passwords in docs, code, comments or tests.
- Tokens and session data go in `flutter_secure_storage` (`core/services/local_storage/secure_storage`), never `SharedPreferences`.
- Don't `print`. Use `AppLog`. It runs only in debug, and network logs go through `log_sanitizer`. Never log tokens, passwords, national IDs or full request bodies.
- Certificate pinning (`http_certificate_pinning`) is on for native builds when `SHA_FINGERPRINTS` is set. Don't turn it off to "fix" a network error.
- Release builds use `--obfuscate --split-debug-info=build/symbols`. See `/release`.
