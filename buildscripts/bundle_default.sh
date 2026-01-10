# --------------------------------------------------

if [ ! -f "deps" ]; then
  sudo rm -r deps
fi
if [ ! -f "prefix" ]; then
  sudo rm -r prefix
fi

./download.sh || exit 1
./patch.sh || exit 1

# --------------------------------------------------

if [ ! -f "scripts/ffmpeg" ]; then
  rm scripts/ffmpeg.sh
fi
cp flavors/default.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh || exit 1

# --------------------------------------------------

echo "chdir media-kit-android-helper"
cd deps/media-kit-android-helper || exit 1

sudo chmod +x gradlew
# Build all ABIs - the external media-kit-android-helper project doesn't properly support
# the -Pandroid.injected.build.abi filter from command line, so we build all and extract only arm64-v8a
./gradlew assembleRelease

unzip -q -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

mkdir -p "../../../libmpv/src/main/jniLibs/arm64-v8a"
cp "app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/arm64-v8a/"

cd ../..

# --------------------------------------------------

cd deps/media_kit/media_kit_native_event_loop || exit 1

flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

if ! grep -q android "pubspec.yaml"; then
  printf "      android:\n        ffiPlugin: true\n" >> pubspec.yaml
fi

flutter pub get

# Configure gradle to only build arm64-v8a in the plugin's android build.gradle
if [ -f "android/build.gradle" ]; then
  if ! grep -q "abiFilters" "android/build.gradle"; then
    # Insert ABI filter configuration into the plugin's build.gradle
    awk '/android \{/ {print; print "    defaultConfig {"; print "        ndk {"; print "            abiFilters \"arm64-v8a\""; print "        }"; print "    }"; next}1' \
      "android/build.gradle" > "android/build.gradle.tmp" && \
      mv "android/build.gradle.tmp" "android/build.gradle"
  fi
fi

# Also configure the example app's build.gradle
if [ -f "example/android/app/build.gradle" ]; then
  if ! grep -q "ndk.abiFilters" "example/android/app/build.gradle"; then
    # Insert ABI filter configuration into build.gradle
    awk '/defaultConfig \{/ {print; print "        ndk {"; print "            abiFilters \"arm64-v8a\""; print "        }"; next}1' \
      "example/android/app/build.gradle" > "example/android/app/build.gradle.tmp" && \
      mv "example/android/app/build.gradle.tmp" "example/android/app/build.gradle"
  fi
fi

cp -a ../../mpv/include/mpv/. src/include/

cd example || exit 1

flutter clean
flutter build apk --release --target-platform android-arm64

unzip -q -o build/app/outputs/apk/release/app-release.apk -d build/app/outputs/apk/release

cd build/app/outputs/apk/release/ || exit 1

# --------------------------------------------------

rm -r lib/*/libapp.so
rm -r lib/*/libflutter.so

# archs=("arm64-v8a" "armeabi-v7a" "x86" "x86_64")
# pairs=("aarch64-linux-android" "arm-linux-androideabi" "i686-linux-android" "x86_64-linux-android")

# for i in "${!archs[@]}"; do
#     arch=${archs[$i]}
#     pair=${pairs[$i]}
#     cp ../../../../../../../../../prefix/${arch}/lib/{libsrt.so,libmbedcrypto.so,libmbedtls.so,libmbedx509.so} lib/${arch}
#     cp ../../../../../../../../../sdk/android-sdk-linux/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/${pair}/libc++_shared.so lib/${arch}
# done

zip -q -r "default-arm64-v8a.jar"                lib/arm64-v8a

mkdir -p ../../../../../../../../../../output

cp *.jar ../../../../../../../../../../output

md5sum *.jar

cd ../../../../../../../../..

# --------------------------------------------------

# zip -q -r debug-symbols-default.zip prefix/*/lib
