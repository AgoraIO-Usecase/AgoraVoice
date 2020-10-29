#!/bin/sh

agoraSdkUrl='https://download.agora.io/sdk/release/Agora_Native_SDK_for_Android_v3_0_0_62_VOICE_20200722_460.zip'
agoraSdkZip='agoraSdk.zip'
agoraSdkDir='agoraSdk'

echo "Working folder:"
pwd

curl -L $agoraSdkUrl -o $agoraSdkZip

echo "unzipping agora sdk...."
rm -r ./$agoraSdkDir
mkdir $agoraSdkDir
tar xvf $agoraSdkZip -C ./$agoraSdkDir
rm $agoraSdkZip

echo "copy agora sdk to project folder..."

sdkRoot=$agoraSdkDir/Agora_Native_SDK_for_Android_VOICE/libs

mkdir -p rte/src/main/jniLibs/arm64-v8a/
mkdir -p rte/src/main/jniLibs/armeabi-v7a/
mkdir -p rte/src/main/jniLibs/x86/
mkdir -p rte/src/main/jniLibs/x86_64/

cp -p $sdkRoot/agora-rtc-sdk.jar rte/libs
cp -p $sdkRoot/arm64-v8a/libagora-rtc-sdk-jni.so rte/src/main/jniLibs/arm64-v8a/
cp -p $sdkRoot/armeabi-v7a/libagora-rtc-sdk-jni.so rte/src/main/jniLibs/armeabi-v7a/
cp -p $sdkRoot/x86/libagora-rtc-sdk-jni.so rte/src/main/jniLibs/x86/
cp -p $sdkRoot/x86_64/libagora-rtc-sdk-jni.so rte/src/main/jniLibs/x86_64/

echo "remove downloaded agora sdk folder"
rm -rf ./$agoraSdkDir

# Replace product permission and id configuration
python ./build-templates/replace-debug.py

# Build debug
chmod +x ./gradlew
./gradlew assembleDebug