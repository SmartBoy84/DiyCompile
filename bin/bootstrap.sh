set -euo pipefail # -u (exit on undefined var) -e (exit on error) -o pipefail (prevent errors from being masked, ensures they're logged) -x (log every command being executed)
[ -d $DIYCOMPILE ] # idk what I'm doing man

if [[ -f $DIYCOMPILE/.bootstrapped ]]; then
    read -p "Are you sure? It's already bootstrapped " CHOICE
    [ -z $CHOICE ]
fi

TOOLCHAIN=$DIYCOMPILE/toolchain
SDKS=$DIYCOMPILE/sdks

rm -r $TOOLCHAIN
mkdir -p $TOOLCHAIN

rm -r $SDKS
mkdir -p $SDKS

TMP=$(mktemp -d)

FILE=linux-ios-arm64e-clang-toolchain.tar.lzma

wget -q --show-progress -O $TMP/$FILE https://github.com/sbingner/llvm-project/releases/latest/download/$FILE

tar -xf $TMP/$FILE -C $TMP
mv $TMP/ios-arm64e-clang-toolchain/* $TOOLCHAIN

git clone https://github.com/theos/sdks $TMP/sdks

mv $TMP/sdks/iPhoneOS14.5.sdk $SDKS # for now, this is all I need

rm -rf $tmp # won't delete automatically since we cloned a git repo into it
touch $DIYCOMPILE/.bootstrapped