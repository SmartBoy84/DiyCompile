set -euo pipefail # -u (exit on undefined var) -e (exit on error) -o pipefail (prevent errors from being masked, ensures they're logged) -x (log every command being executed)
[ -d $DIYCOMPILE ] # idk what I'm doing man

TOOLCHAIN=$DIYCOMPILE/toolchain
SDKS=$DIYCOMPILE/sdks

REPO="kabiroberai/swift-toolchain-linux"
SDK=iPhoneOS14.5.sdk

# reset() { find $1/* ! -name '.keep' -delete  > /dev/null 2>&1 || true; }
# reset $TOOLCHAIN
# reset $SDKS

FILE=toolchain.tar.xz
LINK="https://api.github.com/repos/$REPO/releases/latest"

tag=$(curl -sL --show-error $LINK | jq -r ".tag_name")

if [ $(cat $TOOLCHAIN/version 2>/dev/null || echo 0) == $tag ]; then
    echo -e "Latest found, remove version file in $DIYCOMPILE/toolchain to force";
else
    echo "Getting toolchain $tag from $REPO";
    TMP=$(mktemp -d)
    
    wget -q --show-progress -O $TMP/$FILE $(curl -sL $LINK | jq -r ".assets[].browser_download_url" | grep ubuntu20.04.tar.xz)
    tar -xvf $TMP/$FILE -C $TMP
    
    rm -r $TOOLCHAIN/* 2>/dev/null || true
    mv $TMP/linux/* $TOOLCHAIN
    
    echo $tag > $TOOLCHAIN/version
    
fi

if [[ ! -d $SDKS/$SDK ]]; then
    echo "Downloading $SDK"
    TMP=$(mktemp -d)
    
    
    git clone https://github.com/theos/sdks $TMP/sdks
    
    mv $TMP/sdks/$SDK $SDKS # for now, this is all I need
    rm -rf $TMP # won't delete automatically since we cloned a git repo into it
    
else
    echo "$SDK already downloaded!"
fi