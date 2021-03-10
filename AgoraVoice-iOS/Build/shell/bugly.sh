NEED_BUGLY=$1

if [[ $NEED_BUGLY = 0 ]] ; then
echo "no need bugly"
exit 0
fi

echo "bugly upload --------------"

Project_Path=$2
Product_Path=$3
BundleId=$4

APP_ID=$5
APP_KEY=$6

Current_Path=`pwd`

cd ${Project_Path}

Project_Name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

echo "Project_Name" ${Project_Name}

App_Version=`sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ./${Project_Name}.xcodeproj/project.pbxproj`

echo "App_Version" ${App_Version}
echo "BundleId" ${BundleId}

cd ${Current_Path}

cd ${Product_Path}

for I in `ls`
do
    echo "product ls" $I
    if [[ $I =~ "archive" ]] 
    then
    ArchiveFolder=$I
    fi
done

cd ${ArchiveFolder}/dSYMs

echo `pwd`

for I in `ls`
do
    echo "dsym ls" $I
    rm -f upload.zip

    if [[ $I =~ "dSYM" ]]
    then
        zip -q -r upload.zip $I
        echo "bugly request"
        curl -k "https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=${APP_KEY}&app_id=${APP_ID}" --form "api_version=1" --form "app_id=${APP_ID}" --form "app_key=${APP_KEY}" --form "symbolType=2"  --form "bundleId=${BundleId}" --form "productVersion=${App_Version}" --form "fileName=upload.zip" --form "file=@upload.zip" --verbose
    else
        echo "uninclude dsym"
    fi
done

echo "bugly upload success --------------"
