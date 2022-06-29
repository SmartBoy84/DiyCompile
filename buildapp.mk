# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them

# unused CDIAGNOSTICS (-fcolor-diagnostics) FULLSWIFT (-Xfrontend -color-diagnostics)
# todo, add support for multiple targets (will need to do manual linking), update toolchain

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SDK := $(ROOT)/sdks/iPhoneOS14.4.sdk

DIR := $(shell pwd)
MKDIR := $(DIR)/.build
APPDIR := $(MKDIR)/$(NAME).app

ARCH := arm64e
TARGET := $(ARCH)-apple-ios14.0

TBINS := $(ROOT)/toolchain/bin

SWIFTC := $(TBINS)/swiftc
MAPGEN := $(ROOT)/bin/FileMapGenerator.js

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
FULLSWIFT = -c $(SWIFT) -g -v -parseable-output

ifdef DEBUG
FULLSWIFT += $(SWIFTDEBUG)
else
FULLSWIFT += $(SWIFTOPTIMIZE)
endif
FULLSWIFT += $(FILES)

all: scout build post package

clean:
	@rm -r $(MKDIR)

scout:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi

	@touch $(MKDIR)/.swift-stamp.tmp;
	@$(MAPGEN) $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

build:
	@echo "Building the app..."
	$(SWIFTC) $(FULLSWIFT)

post:
	@echo "Signing the app..."
	CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate
	$(TBINS)/ldid -S $(MKDIR)/$(NAME)

	@if [ ! -z DEBUG ]; then\
		echo "Stripping binary"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME);\
	fi

package:
	@if [ ! -d $(APPDIR) ]; then mkdir -p $(APPDIR); fi

	mkdir -p $(APPDIR)
	rsync --info=progress2 $(MKDIR)/$(NAME) Resources/* $(APPDIR)

ipa:
	@if [ ! -f $(APPDIR)/$(NAME) ]; then echo "run make first!"; $(MAKE) all; fi
	-@mkdir -p packages
	cd $(APPDIR)/.. && zip -r $(NAME).ipa $(NAME).app && cd $(ROOT)
	mv $(APPDIR)/../$(NAME).ipa packages
	

	

	