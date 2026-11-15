#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_HOME:?Set ANDROID_HOME to the Android SDK}"
ANDROID_JAR="${ANDROID_JAR:-$ANDROID_HOME/platforms/android-35/android.jar}"
mkdir -p build/classes build/dex
if command -v javac >/dev/null; then
 javac -source 8 -target 8 -classpath "$ANDROID_JAR" -d build/classes src/fr/alexisuguz/meridien/discovery/*.java
else
 : "${ECJ_JAR:?Provide ECJ_JAR or install JDK javac}"
 java -jar "$ECJ_JAR" -source 1.8 -target 1.8 -classpath "$ANDROID_JAR" -d build/classes src/fr/alexisuguz/meridien/discovery/*.java
fi
"$ANDROID_HOME/build-tools/35.0.0/d8" --min-api 24 --lib "$ANDROID_JAR" --output build/dex build/classes/fr/alexisuguz/meridien/discovery/*.class
cp build/dex/classes.dex classes.dex

python3 check_artifact.py --write
