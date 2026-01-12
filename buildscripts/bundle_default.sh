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

$BUILDSCRIPTS_DIR/download.sh
export PATH=$(realpath deps/flutter/bin):$PATH

$BUILDSCRIPTS_DIR/patch.sh

$BUILDSCRIPTS_DIR/setup_wrapper.sh

$BUILDSCRIPTS_DIR/build.sh

# --------------------------------------------------

pushd deps/media-kit-android-helper

chmod +x gradlew
# Build all ABIs - the external media-kit-android-helper project doesn't properly support
# the -Pandroid.injected.build.abi filter from command line, so we build all and extract only arm64-v8a
./gradlew assembleRelease

unzip -q -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

mkdir -p $ROOT_DIR/libmpv/src/main/jniLibs/arm64-v8a
cp app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so $ROOT_DIR/libmpv/src/main/jniLibs/arm64-v8a/

popd

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
"            abiFilters \"arm64-v8a\"\n" \
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
flutter build apk --release --target-platform android-arm64

unzip -q -o build/app/outputs/apk/release/app-release.apk -d build/app/outputs/apk/release

pushd build/app/outputs/apk/release

# --------------------------------------------------

rm -f lib/*/libapp.so
rm -f lib/*/libflutter.so

mkdir -p $BUILD_DIR/output
zip -q -r $BUILD_DIR/output/default-arm64-v8a.jar lib/arm64-v8a

popd
popd
popd

# --------------------------------------------------

# zip -q -r debug-symbols-default.zip prefix/*/lib

popd
