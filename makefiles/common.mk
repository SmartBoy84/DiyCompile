# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them
# unused CDIAGNOSTICS (-fcolor-diagnostics) FULLSWIFT (-Xfrontend -color-diagnostics -g -v)
# todo, add support for multiple targets (will need to do manual linking), update toolchain

# this is for stuff I just do NOT give a damn about
SHUTUP=2> /dev/null ||:

# Color escape codes
green=\033[0;32m
red=\033[0;31m
blue=\033[0;34m
end=\033[0m
arrow=$(red)=> $(end)
MUTE= 2>/dev/null; true

# to be set in project's makefile
ARCH := $(if $(ARCH),$(ARCH),arm64)
OS := $(if $(OS),$(OS),14.5)

TARGET := $(ARCH)-apple-ios$(OS)

ROOT := ${DIYCOMPILE}
SDK := $(ROOT)/sdks/iPhoneOS$(OS).sdk

DIR := $(shell pwd)
MKDIR := $(DIR)/.build

# scrape the control file for variables
NAME := $(shell cat $(DIR)/control | awk 'match($$0, /^[n|N]ame:\s*(.*)$$/, arr) {print arr[1]}')
PACKAGE := $(shell cat $(DIR)/control | awk 'match($$0, /^[p|P]ackage:\s*(.*)$$/, arr) {print arr[1]}')
VERSION := $(shell cat $(DIR)/control | awk 'match($$0, /^[v|V]ersion:\s*(.*)$$/, arr) {print arr[1]}')
PLATFORM := $(shell cat $(DIR)/control | awk 'match($$0, /^[a|A]rchitecture:\s*(.*)$$/, arr) {print arr[1]}')

REMOTETEST=@(([ "${IP}" ] || (echo "IP not defined"; exit 1)) && ssh root@$(IP) "echo" > /dev/null)
RERUN := $(MAKE) --no-print-directory

TBINS := $(ROOT)/toolchain/bin
SWIFTC := $(TBINS)/swiftc

# worry about this when you need to compile c headers
CDEBUG := -ggdb -O0 # off by default
COPTIMIZE := -Os
CDIAGNOSTICS := -DTARGET_IPHONE=1 -Wall -Wno-unused-command-line-argument -Qunused-arguments -Werror
CARGS := -isysroot $(SDK) -target $(TARGET) -fmodules -fcxx-modules -fbuild-session-file=$(DIR)/.build/build_session -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session -arch arm64 -stdlib=libc++ -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib

# actual swift stuff
SWIFTDEBUG = -DDEBUG -Onone
SWIFTOPTIMIZE := -O -whole-module-optimization -num-threads 1
# SWIFT := -module-name $(NAME) -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib -swift-version 5 -sdk "$(SDK)" -resource-dir $(ROOT)/toolchain/linux/iphone/bin/../lib/swift -incremental -target $(TARGET) -output-file-map $(DIR)/.build/output-file-map.json -emit-dependencies -emit-module-path $(DIR)/.build/$(NAME).swiftmodule
SWIFT := -emit-executable -o $(MKDIR)/$(NAME) -sdk $(SDK) -target $(TARGET) -F$(ROOT)/lib -incremental -output-file-map $(MKDIR)/output-file-map.json -emit-dependencies
FULLSWIFT = -c $(SWIFT)

ifdef DEBUG
FULLSWIFT += $(SWIFTDEBUG)
else
FULLSWIFT += $(SWIFTOPTIMIZE)
endif
FULLSWIFT += $(FILES)