#!/bin/bash -e
export BUILDSCRIPTS_DIR=$(realpath $(dirname ${BASH_SOURCE[0]}))
source $BUILDSCRIPTS_DIR/include/path.sh

set -euo pipefail

# Helper function to insert ABI filter in build.gradle
insert_abi_filter() {
	local gradle_file="$1"
	local pattern="$2"

	if [ -f "$gradle_file" ] && ! grep -q "abiFilters" "$gradle_file"; then
		if awk "$pattern" "$gradle_file" > "$gradle_file.tmp"; then
			mv "$gradle_file.tmp" "$gradle_file"
		else
			rm -f "$gradle_file.tmp"
			return 1
		fi
	fi
}

# --------------------------------------------------

mkdir -p $BUILD_DIR
pushd $BUILD_DIR

rm -rf deps prefix
mkdir deps prefix

chmod +x $BUILDSCRIPTS_DIR/download-all.sh
$BUILDSCRIPTS_DIR/download-all.sh

$BUILDSCRIPTS_DIR/patch.sh

$BUILDSCRIPTS_DIR/setup_wrapper.sh

$BUILDSCRIPTS_DIR/build.sh

# --------------------------------------------------

pushd deps/media_kit/media_kit_native_event_loop

flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

if ! grep -q android pubspec.yaml; then
	printf "      android:\n        ffiPlugin: true\n" >> pubspec.yaml
fi

flutter pub get

# Configure gradle to only build arm64-v8a
insert_abi_filter "android/build.gradle" '
/android \{/ {
    block = \
"    defaultConfig {\n" \
"        ndk {\n" \
"            abiFilters \"arm64-v8a\",\"armeabi-v7a\",\"x86_64\"\n" \
"        }\n" \
"    }"
    print
    print block
    next
}
1
'

cp -a $DEPS_DIR/mpv/include/mpv/. src/include/

pushd example

flutter clean
flutter build apk --release

unzip -q -o build/app/outputs/apk/release/app-release.apk -d build/app/outputs/apk/release

pushd build/app/outputs/apk/release

# --------------------------------------------------

rm -f lib/*/libapp.so
rm -f lib/*/libflutter.so

mkdir -p $BUILD_DIR/output
zip -q -r "$BUILD_DIR/output/default-arm64-v8a.jar"   lib/arm64-v8a
zip -q -r "$BUILD_DIR/output/default-armeabi-v7a.jar" lib/armeabi-v7a
zip -q -r "$BUILD_DIR/output/default-x86_64.jar"      lib/x86_64

popd
popd
popd

# --------------------------------------------------

# zip -q -r debug-symbols-default.zip prefix/*/lib

popd
