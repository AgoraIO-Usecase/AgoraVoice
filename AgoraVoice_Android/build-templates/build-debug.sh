#!/bin/sh

# Replace product permission and id configuration
python ./build-templates/replace-debug.py

# Build debug
chmod +x ./gradlew
./gradlew assembleDebug