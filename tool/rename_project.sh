#!/usr/bin/env bash
# Renames the template for a new project.
#   tool/rename_project.sh <package_name> <bundle_id> "<App Name>"
#   tool/rename_project.sh acme_hr com.acme.hr "Acme HR"
# Run it once, on a fresh copy, before the first commit.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -ne 3 ]; then
  echo "usage: $0 <package_name> <bundle_id> \"<App Name>\"" >&2
  exit 1
fi

new_pkg="$1"; new_id="$2"; new_name="$3"
old_pkg="starter_app"; old_id="com.company.starter_app"; old_ios_id="com.company.starterApp"
old_name="Starter"

[[ "$new_pkg" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "package_name must be lower_snake_case" >&2; exit 1; }
[[ "$new_id" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]] || { echo "bundle_id must look like com.company.app" >&2; exit 1; }

# sed -i differs between macOS and GNU.
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }

echo "▶ Dart package: $old_pkg → $new_pkg"
sedi "s/^name: $old_pkg$/name: $new_pkg/" pubspec.yaml
grep -rl "package:$old_pkg/" lib test 2>/dev/null | while read -r f; do sedi "s#package:$old_pkg/#package:$new_pkg/#g" "$f"; done

echo "▶ Android id: $old_id → $new_id"
sedi "s/$old_id/$new_id/g" android/app/build.gradle.kts
old_dir="android/app/src/main/kotlin/${old_id//.//}"
new_dir="android/app/src/main/kotlin/${new_id//.//}"
if [ -d "$old_dir" ] && [ "$old_dir" != "$new_dir" ]; then
  mkdir -p "$new_dir"
  mv "$old_dir"/* "$new_dir"/
  sedi "s/^package $old_id/package $new_id/" "$new_dir"/*.kt
  find android/app/src/main/kotlin -type d -empty -delete
fi

echo "▶ iOS bundle id: $old_ios_id → $new_id"
sedi "s/$old_ios_id/$new_id/g" ios/Runner.xcodeproj/project.pbxproj

echo "▶ App name: $new_name"
sedi "s/\"$old_name\(.*\)\"/\"$new_name\1\"/" android/app/build.gradle.kts
plutil_set() { /usr/libexec/PlistBuddy -c "Set :$1 $2" ios/Runner/Info.plist 2>/dev/null || true; }
plutil_set CFBundleDisplayName "$new_name"
plutil_set CFBundleName "$new_pkg"
sedi "s/$old_pkg/$new_pkg/g" web/index.html web/manifest.json

echo "▶ flutter pub get"
flutter pub get >/dev/null
echo "✔ renamed. Check 'git diff', then run: flutter analyze"
