#!/bin/bash -e

source $BUILDSCRIPTS_DIR/include/depinfo.sh

[ -z "$TRAVIS" ] && TRAVIS=0 # skip steps not required for CI?
[ -z "$WGET" ] && WGET=wget # possibility of calling wget differently

set -euo pipefail

if [ $TRAVIS -eq 0 ]; then
    sudo apt-get update;
    sudo apt-get install -y autoconf pkg-config libtool ninja-build nasm unzip python3-pip python3-setuptools;
    python3 -m pip install meson jsonschema jinja2;
fi

mkdir -p $BUILDSCRIPTS_DIR/sdk && pushd $BUILDSCRIPTS_DIR/sdk
echo sdk: $(realpath $BUILDSCRIPTS_DIR/sdk)

if [ ! -d "android-sdk-linux" ]; then
    $WGET "https://dl.google.com/android/repository/commandlinetools-linux-${v_sdk}.zip"
    mkdir "android-sdk-linux"
    unzip -q -d "android-sdk-linux" "commandlinetools-linux-${v_sdk}.zip"
    rm "commandlinetools-linux-${v_sdk}.zip"
fi
sdkmanager() {
    local exe="./android-sdk-linux/cmdline-tools/latest/bin/sdkmanager"
    [ -x "$exe" ] || exe="./android-sdk-linux/cmdline-tools/bin/sdkmanager"
    "$exe" --sdk_root="${ANDROID_HOME}" "$@"
}

echo y | sdkmanager \
    "platforms;${v_platform}" \
    "build-tools;${v_sdk_build_tools}" \
    "ndk;${v_ndk}" \
    "cmake;${v_cmake}"

popd
