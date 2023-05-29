special: scout framework

scout:
	@echo "$(arrow)$(green)Configuring$(end)"
	@echo "mksystem=${DIYCOMPILE}\nsdk=$(SDK)\nios=$(OS)\narch=$(ARCH)\nresourceDir=$(TOOLCHAIN)/lib/swift" > $(MKDIR)/.spm.conf;
	@mkdir -p $(addprefix $(MKDIR)/,$(sort $(dir $(wildcard $(FILES)))))

	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json
#compile_commands.json needs to be in the same dir as package.swift in order to have working intellisaense in vs-code and other code editors
	@$(ROOT)/bin/CommandGen.js $(DIR) "$(SWIFT_FULL)" $(FILES) > $(DIR)/compile_commands.json

build: config
	@echo "$(arrow)$(green)Building swift app$(end)"
	@$(SWIFT_COMPILER) $(SWIFT_FULL) $(FILES)

	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	@touch $(MKDIR)/.swift-stamp.tmp;

FRAMEWORK_PATH := $(MKDIR)/Frameworks

framework:
ifdef FRAMEWORKS
	@echo "$(arrow)$(green)Bundling frameworks$(end)"
	
	@for file in $(FRAMEWORKS); do \
		if [ -e "$(LIBRARY)/$$file.framework" ] && [ -e "$(LIBRARY)/$$file.framework/$$file" ]; then \
			mkdir -p $(FRAMEWORK_PATH)/$$file.framework; \
			cp "$(LIBRARY)/$$file.framework/$$file" $(FRAMEWORK_PATH)/$$file.framework; \
			cp "$(LIBRARY)/$$file.framework/Info.plist" $(FRAMEWORK_PATH)/$$file.framework; \
		else \
			echo "$(red)$(arrow)$(LIBRARY)/$$file does not exist"; \
		fi \
    done
endif

ifeq ("$(wildcard $(FRAMEWORK_PATH))","")
	@$(eval RESOURCES+=$(FRAMEWORK_PATH))

	@echo "$(RESOURCES)"
endif
