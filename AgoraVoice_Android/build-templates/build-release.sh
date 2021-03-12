#!/bin/sh

# Replace product permission and id configuration
python ./build-templates/replace-release.py

# Build release
chmod +x ./gradlew
./gradlew assembleRelease