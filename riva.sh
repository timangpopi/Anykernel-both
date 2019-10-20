#!bin/bash
echo "It's Different bro"
git clone https://github.com/fabianonline/telegram.sh telegram

TELEGRAM_ID=${chat_id}
TELEGRAM_TOKEN=${token}
TELEGRAM=telegram/telegram

export TELEGRAM_TOKEN

# Push kernel installer to channel
function push() {
	ZIP=$(echo Steel*.zip)
	curl -F document=@$ZIP  "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
			-F chat_id="${TELEGRAM_ID}" \
			-F "disable_web_page_preview=true" \
			-F "parse_mode=html" \
			-F caption="<b>For Xiaomi Redmi 5A</b> | <b>${TOOLCHAIN}</b> |  [ <code>$UTS</code> ]"
}

# Fin Error
function finerr() {
	curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
		-d "parse_mode=markdown" \
		-d text="Build throw an error(s)" \
		-d chat_id="${TELEGRAM_ID}" \
		-d "disable_web_page_preview=true"
	exit 1
}

# Fin prober
function fin() {
	tg_sendinfo "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). <b>For Xiaomi Redmi 4A</b> [ <code>$UTS</code> ]"
}

# Clean stuff
function clean() {
	rm -rf out anykernel3/Steel* anykernel3/zImage
}

#
# Telegram FUNCTION end
#

# Main environtment
KERNEL_DIR="$(pwd)"
KERN_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"
ZIP_DIR="$KERNEL_DIR/anykernel3"
NUM=$(echo $CIRCLE_BUILD_NUM | cut -c 1-2)
CONFIG="riva_defconfig"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
THREAD="-j60"
LOAD="-l50"
ARM="arm64"
CT="$(pwd)/clang/bin/clang"
GCC="$(pwd)/gcc/bin/aarch64-linux-android-"
GCC32="$(pwd)/gcc32/bin/arm-linux-androideabi-"

# Export
export ARCH=arm64
export KBUILD_BUILD_USER=Mhmmdfas
export KBUILD_BUILD_HOST=SteelHeartCI-${NUM}
export USE_CCACHE=1
export CACHE_DIR=~/.ccache

# Clone toolchain
git clone --quiet -j32 https://github.com/crDroidMod/android_prebuilts_clang_host_linux-x86_clang-5900059 -b 9.0 --depth=1 clang
git clone --quiet -j32 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-9.0.0_r49 --depth=1 gcc
git clone --quiet -j32 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-9.0.0_r49 --depth=1 gcc32
# Clone AnyKernel3
git clone --quiet -j32 https://github.com/fadlyas07/AnyKernel3 --depth=1 anykernel3

# Build start
tanggal=$(TZ=Asia/Jakarta date +'%H%M-%d%m%y')
DATE=`date`
BUILD_START=$(date +"%s")

make -s -C $(pwd) ${THREAD} ${LOAD} O=out ${CONFIG}
make -s -C $(pwd) CC=${CT} \
                  CROSS_COMPILE=${GCC} \
                  CROSS_COMPILE_ARM32=${GCC32} \
                  O=out ${THREAD} ${LOAD} 2>&1| tee build.log
UTS=$(cat out/include/generated/compile.h | grep UTS_VERSION | cut -d '"' -f2)
TOOLCHAIN=$(cat out/include/generated/compile.h | grep LINUX_COMPILER | cut -d '"' -f2 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')

if ! [ -a ${KERN_IMG} ]; then
	finerr
	exit 1
fi

cp ${KERN_IMG} ${ZIP_DIR}/zImage
cd ${ZIP_DIR}
zip -r9 Steelheart-riva-"${tanggal}".zip *
BUILD_END=$(date +"%s")
DIFF=$((${BUILD_END} - ${BUILD_START}))
push
cd ../..
fin
clean
# Build end
