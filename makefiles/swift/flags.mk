# unused CDIAGNOSTICS (-fcolor-diagnostics) FULLSWIFT (-Xfrontend -color-diagnostics -g -v)
# unused SWIFTOPTIMIZE -whole-module-optimization
# todo, add support for multiple targets (will need to do manual linking), update toolchain

#$(date -r $(DIR)/Makefile)

SWIFTC := $(TBINS)/swiftc

# worry about this when you need to compile c headers
CDEBUG := -ggdb -O0 # off by default
COPTIMIZE := -Os
CDIAGNOSTICS := -DTARGET_IPHONE=1 -Wall -Wno-unused-command-line-argument -Qunused-arguments -Werror
CARGS = -isysroot $(SDK) -target $(TARGET) -fmodules -fcxx-modules -fbuild-session-file=$(MKDIR)/build_session -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session -arch arm64 -stdlib=libc++ -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib

# actual swift stuff
SWIFTDEBUG = -DDEBUG -Onone
SWIFTOPTIMIZE := -O -num-threads 1
# SWIFT := -module-name $(NAME) -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib -swift-version 5 -sdk "$(SDK)" -resource-dir $(ROOT)/toolchain/linux/iphone/bin/../lib/swift -incremental -target $(TARGET) -output-file-map $(MKDIR)/output-file-map.json -emit-dependencies -emit-module-path $(MKDIR)/$(NAME).swiftmodule
SWIFT_LIB = -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib -resource-dir $(TOOLCHAIN)/lib/swift
SWIFT = -emit-executable -o $(MKDIR)/$(NAME) -sdk $(SDK) -target $(TARGET) -F$(ROOT)/lib -incremental -output-file-map $(MKDIR)/output-file-map.json -emit-dependencies -swift-version 5
FULLSWIFT = -c $(SWIFT) $(SWIFT_LIB) $(CUSTOM_SWIFT)

ifdef DEBUG
FULLSWIFT += $(SWIFTDEBUG)
else
FULLSWIFT += $(SWIFTOPTIMIZE)
endif

FULLSWIFT += $(FILES)