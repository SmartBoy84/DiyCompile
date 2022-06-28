# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them

ROOT := $(abspath $(lastword $(MAKEFILE_LIST)))
SDK := $ROOT/sdks/iPhoneOS14.5.sdk

DIR := $(shell pwd)

ARCH := arm64
TARGET := arm64-apple-ios7.0

CDEBUG := -ggdb -O0 # off by default
COPTIMIZE := -Os
CDIAGNOSTICS := -fcolor-diagnostics -DTARGET_IPHONE=1 -Wall -Wno-unused-command-line-argument -Qunused-arguments -Werror
CARGS := -isysroot $SDK -target $TARGET -fmodules -fcxx-modules -fbuild-session-file=$DIR/.build/build_session -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session -arch arm64 -stdlib=libc++ -F$SDK/System/Library/PrivateFrameworks -F$ROOT/lib

SWIFTDEBUG := -g -DDEBUG -Onone
SWIFTOPTIMIZE := -O -whole-module-optimization -num-threads 1
SWIFT := -module-name $NAME -F$SDK/System/Library/PrivateFrameworks -F$ROOT/lib -swift-version 5 -sdk "$SDK" -resource-dir $ROOT/toolchain/linux/iphone/bin/../lib/swift -fmodule-name=prac -incremental -target $TARGET -output-file-map $DIR/.build/output-file-map.420d6daa.json -emit-dependencies -emit-module-path $DIR/.build/arm64/prac.swiftmodule