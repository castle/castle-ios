#!/bin/bash

if ! which jazzy >/dev/null; then
  echo "Jazzy not detected: You can download it from https://github.com/realm/jazzy"
  exit
fi

SOURCE_PUBLIC='Castle/Public'
SOURCEDIR='Castle'
SOURCE_TMP='TMP'

mkdir $SOURCE_TMP
mkdir "$SOURCE_TMP"/Castle
cp "$SOURCE_PUBLIC"/Castle.h "$SOURCE_TMP"/Castle.h

jazzy \
	--objc \
	--clean \
    --sdk iphonesimulator \
    --framework-root $SOURCEDIR/ \
    --umbrella-header $SOURCE_TMP/Castle.h \

rm -r $SOURCE_TMP
