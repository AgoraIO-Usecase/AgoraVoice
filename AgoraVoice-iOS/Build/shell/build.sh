WORKING_PATH="./"
APP_Project="AgoraVoice"
APP_TARGET=$1
MODE=$2

echo "WORKING_PATH: ${WORKING_PATH}"
echo "APP_TARGET: ${APP_TARGET}"

cd ${WORKING_PATH}
echo `pwd`

rm -f *.ipa
rm -rf *.app
rm -f *.zip
rm -rf dSYMs
rm -rf *.dSYM
rm -f *dSYMs.zip
rm -rf *.xcarchive

BUILD_DATE=`date +%Y-%m-%d-%H.%M.%S`
ArchivePath=../Build/product/${APP_TARGET}-${BUILD_DATE}_${MODE}.xcarchive

if [[ $MODE =~ "Release" ]] 
then
Export_Plist_File=exportPlist_release.plist
elif [[ $MODE =~ "Lab2020" ]] 
then
Export_Plist_File=exportPlist_Lab2020.plist
elif [[ $MODE =~ "Test2019" ]] 
then
Export_Plist_File=exportPlist_Test2019.plist
else 
Export_Plist_File=exportPlist.plist
fi

Plist_Path=../Build/plist/${Export_Plist_File}

cd ../../AgoraVoice/

TARGET_FILE=""
if [ ! -f "Podfile" ];then
TARGET_FILE="${APP_Project}.xcodeproj"
xcodebuild clean -project ${TARGET_FILE} -scheme "${APP_TARGET}" -configuration ${MODE}
xcodebuild -project ${TARGET_FILE} -scheme "${APP_TARGET}" -configuration ${MODE} -archivePath ${ArchivePath} archive
else
pod install
TARGET_FILE="${APP_Project}.xcworkspace"
xcodebuild clean -workspace ${TARGET_FILE} -scheme "${APP_TARGET}" -configuration ${MODE}
xcodebuild -workspace ${TARGET_FILE} -scheme "${APP_TARGET}" -configuration ${MODE} -archivePath ${ArchivePath} archive
fi

xcodebuild -exportArchive -exportOptionsPlist ${Plist_Path} -archivePath ${ArchivePath} -exportPath .

PRODUCT_PATH=../Build/product

mv -f *.ipa ${PRODUCT_PATH}
mv -f DistributionSummary.plist ${PRODUCT_PATH}
mv -f ExportOptions.plist ${PRODUCT_PATH}
mv -f Packaging.log ${PRODUCT_PATH}

cd ${PRODUCT_PATH}

mkdir app
mv *.ipa app && mv *.xcarchive app
zip -q -r app.zip app