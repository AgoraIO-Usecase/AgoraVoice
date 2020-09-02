TARGET_ZIP="resource.zip"
TARGET_INTERNAL_FOLDER="temp_resource"

rm -rf __MACOSX
rm -rf ${TARGET_INTERNAL_FOLDER}
rm -rf ${TARGET_ZIP}

RESOURCE_URL=$1
DESTINATION=$2

FILE_PATH=`pwd`

echo "pwd" ${FILE_PATH}
echo "url" ${RESOURCE_URL}

#download
wget -q ${RESOURCE_URL} -O ${TARGET_ZIP}

#unzip
unzip -q ${TARGET_ZIP} -d ${TARGET_INTERNAL_FOLDER}

#copy
echo "copy to" ${DESTINATION}

cp -af ${TARGET_INTERNAL_FOLDER}/* ${DESTINATION}
