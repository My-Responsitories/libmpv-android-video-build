#!/bin/bash -e
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

rm -rf deps prefix

./download.sh || exit 1
./patch.sh || exit 1

# --------------------------------------------------

./build.sh || exit 1

# --------------------------------------------------

pushd deps/media-kit-android-helper || exit 1

chmod +x gradlew
# Build all ABIs - the external media-kit-android-helper project doesn't properly support
# the -Pandroid.injected.build.abi filter from command line, so we build all and extract only arm64-v8a
./gradlew assembleRelease

unzip -q -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

mkdir -p "../../../libmpv/src/main/jniLibs/arm64-v8a"
cp "app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/arm64-v8a/"

popd

# --------------------------------------------------

pushd deps/media_kit/media_kit_native_event_loop || exit 1

flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

if ! grep -q android "pubspec.yaml"; then
  printf "      android:\n        ffiPlugin: true\n" >> pubspec.yaml
fi

flutter pub get

# Configure gradle to only build arm64-v8a
insert_abi_filter "android/build.gradle" \
	'/android \{/ {print; print "    defaultConfig {"; print "        ndk {"; print "            abiFilters \"arm64-v8a\""; print "        }"; print "    }"; next}1'

insert_abi_filter "example/android/app/build.gradle" \
	'/defaultConfig \{/ {print; print "        ndk {"; print "            abiFilters \"arm64-v8a\""; print "        }"; next}1'

cp -a ../../mpv/include/mpv/. src/include/

pushd example || exit 1

flutter clean
flutter build apk --release --target-platform android-arm64

unzip -q -o build/app/outputs/apk/release/app-release.apk -d build/app/outputs/apk/release

pushd build/app/outputs/apk/release || exit 1

# --------------------------------------------------

rm -r lib/*/libapp.so
rm -r lib/*/libflutter.so

zip -q -r "default-arm64-v8a.jar"                lib/arm64-v8a

mkdir -p ../../../../../../../../../../output

cp *.jar ../../../../../../../../../../output

md5sum *.jar

popd
popd
popd

# --------------------------------------------------

# zip -q -r debug-symbols-default.zip prefix/*/lib
