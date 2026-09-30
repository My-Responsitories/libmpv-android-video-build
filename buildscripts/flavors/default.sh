#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
	--target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --ar=$AR --cc=$CC --ranlib=$RANLIB \
	--arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
	--extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
	\
	--disable-gpl \
	--disable-nonfree \
	--enable-version3 \
	--enable-static \
	--disable-shared \
	--disable-vulkan \
	--disable-iconv \
	--disable-debug \
	--pkg-config-flags=--static \
	\
	--disable-muxers \
	--disable-decoders \
	--disable-encoders \
	--disable-demuxers \
	--disable-parsers \
	--disable-protocols \
	--disable-devices \
	--disable-filters \
	--disable-doc \
	--disable-avdevice \
	--disable-programs \
	--disable-gray \
	--disable-swscale-alpha \
	\
	--enable-jni \
	--enable-bsfs \
	--enable-mediacodec \
	\
	--disable-dxva2 \
	--disable-vaapi \
	--disable-vdpau \
	--disable-bzlib \
	--disable-linux-perf \
	--disable-videotoolbox \
	--disable-audiotoolbox \
	\
	--enable-small \
	--enable-hwaccels \
	--enable-optimizations \
	--enable-runtime-cpudetect \
	\
	--enable-mbedtls \
	\
	--enable-libdav1d \
	\
	--enable-avutil \
	--enable-avcodec \
	--enable-avfilter \
	--enable-avformat \
	--enable-swscale \
	--enable-swresample \
	\
	--enable-libwebp \
	\
	--enable-decoder=flv \
	--enable-decoder=h264* \
	--enable-decoder=mpeg1video \
	--enable-decoder=mpeg4* \
	--enable-decoder=vp8* \
	--enable-decoder=vp9* \
	--enable-decoder=hevc* \
	--enable-decoder=av1* \
	\
	--enable-decoder=aac* \
	--enable-decoder=ac3 \
	--enable-decoder=eac3 \
	--enable-decoder=flac \
	--enable-decoder=mp3* \
	--enable-decoder=opus \
	--enable-decoder=wavpack \
	--enable-decoder=pcm* \
	\
	--enable-decoder=srt \
	--enable-decoder=subrip \
	--enable-decoder=webvtt \
	--enable-decoder=movtext \
	\
	--enable-demuxer=concat \
	--enable-demuxer=data \
	--enable-demuxer=flv \
	--enable-demuxer=hls \
	--enable-demuxer=live_flv \
	--enable-demuxer=loas \
	--enable-demuxer=m4v \
	--enable-demuxer=mov \
	--enable-demuxer=mpegps \
	--enable-demuxer=mpegts \
	--enable-demuxer=mpegvideo \
	--enable-demuxer=hevc \
	--enable-demuxer=av1 \
	--enable-demuxer=matroska \
	--enable-demuxer=webm_dash_manifest \
	--enable-muxer=webp \
	\
	--enable-demuxer=aac \
	--enable-demuxer=ac3 \
	--enable-demuxer=au \
	--enable-demuxer=flac \
	--enable-demuxer=flv \
	--enable-demuxer=mp3 \
	--enable-demuxer=wav \
	\
	--enable-demuxer=srt \
	--enable-demuxer=webvtt \
	\
	--enable-parser=h264 \
	--enable-parser=hevc \
	--enable-parser=mpeg4video \
	--enable-parser=mpegvideo \
	\
	--enable-parser=aac* \
	--enable-parser=ac3 \
	--enable-parser=flac \
	--enable-parser=mpegaudio \
	\
	--enable-filter=overlay \
	--enable-filter=equalizer \
	--enable-filter=aresample \
 	--enable-filter=dynaudnorm \
 	--enable-filter=loudnorm \
 	--enable-filter=alimiter \
	\
	--enable-protocol=async \
	--enable-protocol=cache \
	--enable-protocol=crypto \
	--enable-protocol=data \
	--enable-protocol=file \
	--enable-protocol=hls \
	--enable-protocol=http \
	--enable-protocol=httpproxy \
	--enable-protocol=https \
	--enable-protocol=pipe \
	--enable-protocol=subfile \
	--enable-protocol=tcp \
	--enable-protocol=tls \
	\
	--enable-encoder=libwebp \
	--enable-encoder=libwebp_anim \
	\
	--enable-network \

make -j$cores
make DESTDIR="$prefix_dir" install

ln -sf "$prefix_dir"/lib/libswresample.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavutil.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavcodec.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavformat.so "$native_dir"
ln -sf "$prefix_dir"/lib/libswscale.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavfilter.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavdevice.so "$native_dir"