scout:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

build:
	@echo "$(arrow)$(green)Building the app...$(end)"
	@$(SWIFTC) $(FULLSWIFT) $(FILES)
	@$(ROOT)/bin/CommandGen.js $(DIR) "$(FULLSWIFT)" $(FILES) > $(DIR)/compile_commands.json