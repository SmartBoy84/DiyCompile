set -euo pipefail # -u (exit on undefined var) -e (exit on error) -o pipefail (prevent errors from being masked, ensures they're logged) -x (log every command being executed)
[ -d $DIYCOMPILE ] # idk what I'm doing man

if [[ -f $DIYCOMPILE/.bootstrapped ]]; then
    read -p "Are you sure? It's already bootstrapped " CHOICE
    [ -z $CHOICE ]
fi

TOOLCHAIN=$DIYCOMPILE/toolchain
SDKS=$DIYCOMPILE/sdks

reset() { find $1/* ! -name '.keep' -delete  > /dev/null 2>&1 || true; }
reset $TOOLCHAIN
reset $SDKS

TMP=$(mktemp -d)

FILE=swift-5.3.2-RELEASE-ubuntu20.04

wget -q --show-progress -O $TMP/$FILE https://github.com/CRKatri/llvm-project/releases/download/swift-5.3.2-RELEASE/$FILE.tar.zst

tar -xvf $TMP/$FILE -C $TMP
mv $TMP/$FILE/* $TOOLCHAIN

git clone https://github.com/theos/sdks $TMP/sdks

mv $TMP/sdks/iPhoneOS14.0.sdk $SDKS # for now, this is all I need

rm -rf $TMP # won't delete automatically since we cloned a git repo into it
touch $DIYCOMPILE/.bootstrapped