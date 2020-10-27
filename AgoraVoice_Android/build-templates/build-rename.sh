#!/bin/sh

echo "build rename apk files"
echo $path
echo $appName
echo $ver

ts=$(date +"%Y%m%d%H%M")

echo $ts

mv $path/*.apk $path/${appName}_${ver}_${ts}.apk