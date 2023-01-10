# boilerplate
include $(MKPATH)/common.mk
include $(MKPATH)/setup.mk
include $(MKPATH)/post.mk

include $(MKPATH)/swift/flags.mk

special: scout

scout:
	@echo "$(arrow)$(green)Configuring...$(end)"
	@echo "mksystem=${DIYCOMPILE}\nsdk=$(SDK)\nios=$(OS)\narch=$(ARCH)\nresourceDir=$(TOOLCHAIN)/lib/swift" > $(MKDIR)/.spm.conf;
	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

build: config scout
	@echo "$(arrow)$(green)Building swift app...$(end)"
	@$(SWIFTC) $(FULLSWIFT)
#compile_commands.json needs to be in the same dir as package.swift in order to have working intellisaense in vs-code and other code editors
	@$(ROOT)/bin/CommandGen.js $(DIR) "$(FULLSWIFT)" $(FILES) > $(DIR)/compile_commands.json

	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	@touch $(MKDIR)/.swift-stamp.tmp;