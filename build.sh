#!bin/bash
echo "It's Different bro"
git clone https://github.com/fabianonline/telegram.sh telegram

TELEGRAM_ID=-1001158707255
TELEGRAM_TOKEN=923829062:AAHAkKpoL-iAdDm6nmp4GPjKhjfxWkTMLPY
TELEGRAM=telegram/telegram

export TELEGRAM_TOKEN

# Push kernel installer to channel
function push() {
	ZIP=$(echo *.zip)
	curl -F document=@$ZIP  "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
			-F chat_id="${TELEGRAM_ID}"
}

# Send the info up
function tg_channelcast() {
	"${TELEGRAM}" -c ${TELEGRAM_ID} -H \
		"$(
			for POST in "${@}"; do
				echo "${POST}"
			done
		)"
}

function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
		-d "parse_mode=markdown" \
		-d text="${1}" \
		-d chat_id="${TELEGRAM_ID}" \
		-d "disable_web_page_preview=true"
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

# Send sticker
function tg_sendstick() {
	curl -s -F chat_id=${TELEGRAM_ID} -F sticker="CAADBQAD3AADfULDLpHzWZltpdJ5FgQ" https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendSticker
}

# Fin prober
function fin() {
	tg_sendinfo "$(echo "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). <b>For Xiaomi Redmi 4A</b> [ <code>$UTS</code> ]")"
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
CONFIG="rolex_defconfig"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
THREAD="-j60"
LOAD="-l50"
ARM="arm64"
CC="$(pwd)/clang/bin/clang"
CT="aarch64-linux-gnu-"
GCC="$(pwd)/gcc/bin/aarch64-linux-gnu-"
GCC32="$(pwd)/gcc32/bin/arm-linux-gnueabi-"

# Export
export TZ=":Asia/Jakarta"
export ARCH=arm64
export KBUILD_BUILD_USER=Mhmmdfas
export KBUILD_BUILD_HOST=SteelHeartCI-${NUM}
export USE_CCACHE=1
export CACHE_DIR=~/.ccache

# Clone depedencies
git clone --quiet -j32 https://github.com/crDroidMod/android_prebuilts_clang_host_linux-x86_clang-5900059 -b 9.0 --depth=1 clang
git clone --quiet -j32 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-9.0.0_r49 --depth=1 gcc
git clone --quiet -j32 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-9.0.0_r49 --depth=1 gcc32
git clone --quiet -j32 https://github.com/fadlyas07/AnyKernel3 --depth=1 anykernel3

# Build start
tanggal=$(TZ=Asia/Jakarta date +'%H%M-%d%m%y')
DATE=`date`
BUILD_START=$(date +"%s")

tg_sendstick

tg_channelcast "<b>SteelHeart CI new build is up</b>!!" \
		"Kernel version: <code>Linux 3.18.140</code>" \
		"From branch <code>${BRANCH}</code>" \
                "Changelog <code>$(git log --pretty=format:'"%h : %s"' -1)</code>" \
                "Using Compiler: <code>$(${CC} --version | head -n 1 | perl -pe 's/\(.*?\)//gs' | sed -e 's/  */ /g')</code>" \
		"Compiled with: <code>$(${GCC32}gcc --version | head -n 1)</code>" \
		"Compiled with: <code>$(${GCC}gcc --version | head -n 1)</code>" \
		"Started on <code>$(TZ=Asia/Jakarta date)</code>"

make -s -C $(pwd) ${THREAD} ${LOAD} O=out ${CONFIG}
make -C $(pwd) ${THREAD} ${LOAD} 2>&1 O=out \
			       	      ARCH=${ARM} \
                        	      CC=${CC} \
       		        	      CLANG_TRIPLE=${CT} \
                     		      CROSS_COMPILE_ARM32=${GCC32} \
				      CROSS_COMPILE=${GCC}

if ! [ -a ${KERN_IMG} ]; then
	finerr
	exit 1
fi

cp ${KERN_IMG} ${ZIP_DIR}/zImage
cd ${ZIP_DIR}
zip -r9 zip -r9 Steelheart-rolex-"${tanggal}".zip *
BUILD_END=$(date +"%s")
DIFF=$((${BUILD_END} - ${BUILD_START}))
push
cd ../..
fin
clean
# Build end
