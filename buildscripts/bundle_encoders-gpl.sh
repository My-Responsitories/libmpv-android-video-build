# --------------------------------------------------
set -euxo pipefail

export ENCODERS_GPL=1

if [ -d deps ]; then
  sudo rm -r deps
fi
if [ -d prefix ]; then
  sudo rm -r prefix
fi

./download.sh
./patch-encoders-gpl.sh

# --------------------------------------------------

rm scripts/ffmpeg.sh
cp flavors/encoders-gpl.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

mkdir -p "../../../libmpv/src/main/jniLibs/arm64-v8a"
cp "app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/arm64-v8a/"

cd ../..

# --------------------------------------------------

cd deps/media_kit/media_kit_native_event_loop

flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

if ! grep -q android "pubspec.yaml"; then
  printf "      android:\n        ffiPlugin: true\n" >> pubspec.yaml
fi

flutter pub get

cp -a ../../mpv/libmpv/. src/include/

cd example

flutter clean
flutter build apk --release --target-platform android-arm64

unzip -o build/app/outputs/apk/release/app-release.apk -d build/app/outputs/apk/release

cd build/app/outputs/apk/release/

# --------------------------------------------------

rm -r lib/*/libapp.so
rm -r lib/*/libflutter.so

zip -r "encoders-gpl-arm64-v8a.jar"                lib/arm64-v8a

mkdir -p ../../../../../../../../../../output

cp *.jar ../../../../../../../../../../output

md5sum *.jar

cd ../../../../../../../../..

# --------------------------------------------------

zip -r debug-symbols-encoders-gpl.zip prefix/*/lib
cp debug-symbols-encoders-gpl.zip ../output
