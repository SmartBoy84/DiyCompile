# boilerplate
include $(MKPATH)/common.mk
include $(MKPATH)/setup.mk
include $(MKPATH)/post.mk

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
FULLSWIFT = -c $(SWIFT) $(SWIFT_LIB)

ifdef DEBUG
FULLSWIFT += $(SWIFTDEBUG)
else
FULLSWIFT += $(SWIFTOPTIMIZE)
endif
# FULLSWIFT += $(FILES)

mkfile := $(DIR)/Makefile
mkstore := $(MKDIR)/.makefile

all: config scout build sign post

scout:
	@echo "$(arrow)$(green)Configuring...$(end)"
	@echo "mksystem=${DIYCOMPILE}\nsdk=$(SDK)\nios=$(OS)\narch=$(ARCH)\nresourceDir=$(TOOLCHAIN)/lib/swift" > $(MKDIR)/.spm.conf;
	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

build:
	@echo "$(arrow)$(green)Building swift app...$(end)"
	@$(SWIFTC) $(FULLSWIFT) $(FILES)
#@$(TBINS)/swift build -v
	@$(ROOT)/bin/CommandGen.js $(DIR) "$(FULLSWIFT)" $(FILES) > $(MKDIR)/compile_commands.json

	@if [ ! -z DEBUG ]; then\
		echo "$(arrow)$(green)Stripping binary$(end)"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null;\
	fi

sign:
	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	
	@touch $(MKDIR)/.swift-stamp.tmp;
	
	@echo "$(arrow)$(green)Signing the app...$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate $(TBINS)/ldid -S$(ENTITLEMENTS) $(MKDIR)/$(NAME) > /dev/null