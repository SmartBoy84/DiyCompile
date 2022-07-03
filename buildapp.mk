# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them

# unused CDIAGNOSTICS (-fcolor-diagnostics) FULLSWIFT (-Xfrontend -color-diagnostics -g -v)
# todo, add support for multiple targets (will need to do manual linking), update toolchain
green=\033[0;32m
red=\033[0;31m
blue=\033[0;34m
end=\033[0m
arrow=$(red)=> $(end)
MUTE= 2>/dev/null; true

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SDK := $(ROOT)/sdks/iPhoneOS14.5.sdk

DIR := $(shell pwd)
MKDIR := $(DIR)/.build

REMOTETEST=@(([ "${IP}" ] || (echo "IP not defined"; exit 1)) && ssh root@$(IP) "echo" > /dev/null)
RERUN := $(MAKE) --no-print-directory

# scrape the control file for variables
NAME := $(shell cat $(DIR)/control | awk 'match($$0, /^[n|N]ame:\s*(.*)$$/, arr) {print arr[1]}')
PACKAGE := $(shell cat $(DIR)/control | awk 'match($$0, /^[p|P]ackage:\s*(.*)$$/, arr) {print arr[1]}')
VERSION := $(shell cat $(DIR)/control | awk 'match($$0, /^[v|V]ersion:\s*(.*)$$/, arr) {print arr[1]}')
PLATFORM := $(shell cat $(DIR)/control | awk 'match($$0, /^[a|A]rchitecture:\s*(.*)$$/, arr) {print arr[1]}')

# excuse this
STAGE := main
APPDIR := $(MKDIR)/app/$(STAGE)
IPA := $(MKDIR)/_/IPA
DEB := $(MKDIR)/_/DEB

# to be set in project's makefile
ARCH := $(if $(ARCH),$(ARCH),arm64)
OS := $(if $(OS),$(OS),7.0)

TARGET := $(ARCH)-apple-ios$(OS)

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

all: scout build post

clean:
	@echo "$(arrow)$(green)Cleaning...$(end)"
	
	-@rm -r $(MKDIR) $(MUTE)
	-@rm -r packages $(MUTE)

install:
	$(REMOTETEST)
	@if [ ! -f packages/*.deb ]; then echo "$(red)Build a package first!$(end)"; $(RERUN) deb; fi
	
	@echo "$(arrow)$(green)Installing to $(IP)...$(end)"
	@scp packages/*.deb root@$(IP):/tmp/build.deb > /dev/null
	@ssh root@$(IP) "dpkg -i /tmp/build.deb && uicache"

remove:
	$(REMOTETEST)
	@ssh root@$(IP) "dpkg -r $(PACKAGE) && uicache"

do:
	$(REMOTETEST)
	@$(RERUN)
	
	@if ssh root@192.168.0.251 "stat /Applications/$(NAME).app/$(NAME)" > /dev/null; then \
		echo "$(arrow)$(green)Updating files to $(blue)$(IP)$(end)$(green)...$(end)"; \
		rsync -ar --info=progress2 $(APPDIR)/$(NAME).app/ root@$(IP):/Applications/$(NAME).app/ --delete ; \
	else \
		echo "$(red)App isn't installed at all!$(end)"; \
		$(RERUN) install; \
	fi
	-@ssh root@$(IP) "killall $(NAME); uicache; uiopen $(NAME)://"

scout:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

build:
	@echo "$(arrow)$(green)Building the app...$(end)"
	@$(SWIFTC) $(FULLSWIFT)

post:
	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	@touch $(MKDIR)/.swift-stamp.tmp;
	
	@echo "$(arrow)$(green)Signing the app...$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate
	@$(TBINS)/ldid -S $(MKDIR)/$(NAME) > /dev/null

	@if [ ! -z DEBUG ]; then\
		echo "$(arrow)$(green)Stripping binary$(end)"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null;\
	fi

	-@mkdir -p $(APPDIR)
	-@mkdir -p $(APPDIR)/../DEBIAN
	-@mkdir -p $(MKDIR)/_
	
	@rsync --info=progress2 $(MKDIR)/$(NAME) $(DIR)/Resources/* $(APPDIR)/$(NAME).app
	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(APPDIR)/$(NAME).app/Info.plist

ipa:
	@$(RERUN) all
	echo "$(arrow)$(green)Making IPA...$(end)"

	-@mkdir -p packages/.old
	-@mv packages/*.ipa packages/.old

	$(eval COUNTER=$(shell [ -f $(IPA) ] && echo $$(($$(cat $(IPA)) + 1)) || echo 0))
	echo $(COUNTER) > $(IPA)

	@cd $(APPDIR)/.. ;\
	mv $(STAGE) Payload ;\
	zip -r $(DIR)/packages/$(NAME)-$(VERSION)_$(COUNTER).ipa Payload ;\
	mv Payload $(STAGE) ;\

deb:
	@$(RERUN) all
	@echo "$(arrow)$(green)Making deb...$(end)"
			
	-@mkdir -p packages/.old
	@mv packages/*.deb packages/.old $(MUTE)

	@cp control $(APPDIR)/../DEBIAN

	$(eval COUNTER=$(shell [ -f $(DEB) ] && echo $$(($$(cat $(DEB)) + 1)) || echo 1))
	@echo $(COUNTER) > $(DEB)

	@cd $(APPDIR)/.. ;\
	mv $(STAGE) Applications ;\
	dpkg-deb -Zxz -z0 -b . $(DIR)/packages/$(PACKAGE)_$(VERSION)-$(COUNTER)_$(PLATFORM).deb > /dev/null;\
	mv Applications $(STAGE) ;\