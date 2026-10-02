# tool/: project scripts

| File | When | What it does |
|---|---|---|
| `setup.sh` | Once after every clone | Enables `.githooks` (`core.hooksPath`), makes hooks and scripts executable, creates `api_end_points.env` from `api_end_points.env.example` if missing (git-ignored, fill in real values), runs `flutter pub get` |
| `rename_project.sh` | Once, on a fresh copy of the template, before the first commit | `tool/rename_project.sh <package_name> <bundle_id> "<App Name>"`. Renames the Dart package and imports, Android and iOS bundle ids, the Kotlin package folder, and the app name. Works on macOS and Linux `sed` |
