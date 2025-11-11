#!/usr/bin/env bash
set -euo pipefail

# Simple Android/Flutter sanity checker and helper.
# - Verifies entrypoint, required CLIs, ADB device presence
# - Verifies signing files for release builds and tells you what to edit
# - Prints clear next steps without changing your project
#
# Usage:
#   tools/adb_check.sh
#

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_DIR/android"
APP_GRADLE="$ANDROID_DIR/app/build.gradle.kts"
KEY_PROPERTIES="$ANDROID_DIR/key.properties"

info()  { printf "info: %s\n"  "$*"; }
warn()  { printf "warn: %s\n"  "$*" >&2; }
error() { printf "error: %s\n" "$*" >&2; }
head1() { printf "\n== %s ==\n" "$*"; }

missing_any=0
issues=()

head1 "Project"
info "Root: $PROJECT_DIR"
if [[ ! -f "$PROJECT_DIR/lib/main.dart" ]]; then
  error "Entrypoint not found: lib/main.dart"
  error "Open the project root in Android Studio: $PROJECT_DIR"
  issues+=("Missing entrypoint: $PROJECT_DIR/lib/main.dart")
fi

head1 "CLI tools"
need_cmds=(adb flutter java)
for c in "${need_cmds[@]}"; do
  if ! command -v "$c" >/dev/null 2>&1; then
    missing_any=1
    issues+=("Missing CLI: $c (install and ensure it's on PATH)")
    error "Missing CLI: $c"
  else
    info "Found $c: $(command -v "$c")"
  fi
done
if command -v keytool >/dev/null 2>&1; then
  info "Found keytool (optional): $(command -v keytool)"
else
  warn "keytool not found (only needed for creating a release keystore)"
fi

head1 "ADB devices"
adb start-server >/dev/null 2>&1 || true
device_list=$(adb devices | awk 'NR>1 && $2=="device"{print $1}')
if [[ -z "${device_list// /}" ]]; then
  warn "No devices connected. Start an emulator or plug in a device."
  info "Tip: flutter emulators --launch <id>  or  adb devices"
else
  info "Connected devices:"
  echo "$device_list" | sed 's/^/  - /'
fi

head1 "Android signing (for release builds)"
if [[ -f "$KEY_PROPERTIES" ]]; then
  info "Found: android/key.properties"
  # Parse key.properties (key=value, may contain spaces after =)
  storeFile=$(grep -E '^storeFile=' "$KEY_PROPERTIES" | sed 's/^storeFile=//')
  keyAlias=$(grep -E '^keyAlias=' "$KEY_PROPERTIES" | sed 's/^keyAlias=//')
  [[ -z "${storeFile:-}" ]] && warn "key.properties: storeFile is empty"
  [[ -z "${keyAlias:-}"  ]] && warn "key.properties: keyAlias is empty"
  # Resolve relative path against android/ dir
  if [[ -n "${storeFile:-}" && ! "$storeFile" = /* ]]; then
    storeFile="$ANDROID_DIR/$storeFile"
  fi
  if [[ -n "${storeFile:-}" && ! -f "$storeFile" ]]; then
    issues+=("Keystore file not found: $storeFile (set storeFile in android/key.properties)")
    error "Keystore file not found: $storeFile"
  else
    [[ -n "${storeFile:-}" ]] && info "Keystore file: $storeFile"
  fi
else
  warn "android/key.properties not found (only required for Play release)."
  issues+=("Create android/key.properties for release signing.")
  cat <<'TEMPLATE'
To enable release signing, create android/key.properties with:
  storePassword=YOUR_STORE_PASSWORD
  keyPassword=YOUR_KEY_PASSWORD
  keyAlias=upload
  storeFile=/absolute/path/to/your/upload-keystore.jks   # or relative (e.g., keystore/upload-keystore.jks)
Then reference it in android/app/build.gradle.kts (release signingConfigs).
TEMPLATE
fi

head1 "Gradle signing config (android/app/build.gradle.kts)"
if [[ -f "$APP_GRADLE" ]]; then
  if grep -q 'signingConfigs.getByName("debug")' "$APP_GRADLE"; then
    warn "Release build currently uses debug signing (OK for local debug, not for Play)."
    info "Edit: $APP_GRADLE and configure a proper release signing config that loads key.properties."
    issues+=("Configure release signing in $APP_GRADLE for Play release.")
  else
    info "Custom signing configuration detected."
  fi
else
  issues+=("Missing $APP_GRADLE")
  error "Missing $APP_GRADLE"
fi

head1 "Result"
if [[ ${#issues[@]} -eq 0 ]]; then
  echo "All basic checks passed."
  echo "You can build and install debug with:"
  echo "  flutter run -t lib/main.dart"
else
  echo "Found ${#issues[@]} issue(s):"
  for i in "${issues[@]}"; do
    echo " - $i"
  done
  echo
  echo "Fix the above, then re-run: tools/adb_check.sh"
fi


