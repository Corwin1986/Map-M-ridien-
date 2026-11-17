#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_HOME:?Indiquer ANDROID_HOME vers le SDK Android et configurer le JDK dans Godot}"
BUILD_TOOLS="${MERIDIEN_BUILD_TOOLS:-$ANDROID_HOME/build-tools/35.0.0}"
OUT="${1:-../Meridien_v19.apk}"
python3 native/check_artifact.py
godot --headless --editor --path . --export-debug Android "$OUT"
python3 scripts/finalize_apk.py "$OUT"
python3 scripts/inject_notifications.py "$OUT" native/classes.dex
"$BUILD_TOOLS/zipalign" -p -f 4 "$OUT" "$OUT.aligned"
mv "$OUT.aligned" "$OUT"
"$BUILD_TOOLS/apksigner" sign --ks tools/debug.keystore --ks-pass pass:android --ks-key-alias androiddebugkey "$OUT"
"$BUILD_TOOLS/apksigner" verify --verbose "$OUT"
