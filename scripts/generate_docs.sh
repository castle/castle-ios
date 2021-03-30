if ! which jazzy >/dev/null; then
  echo "Jazzy not detected: You can download it from https://github.com/realm/jazzy"
  exit
fi

SOURCE=Castle
SOURCE_TMP=Public
SOURCEDIR=Castle/

jazzy \
	--objc \
	--clean \
    --sdk iphonesimulator \
    --framework-root $SOURCEDIR/ \
    --umbrella-header $SOURCEDIR/$SOURCE_TMP/Castle.h \
