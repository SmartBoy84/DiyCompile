#$(date -r $(DIR)/Makefile)

mkfile := $(DIR)/Makefile
mkstore := $(MKDIR)/.makefile

all: scout build sign post

scout:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	
	@if [ -f $(mkstore) ] && [ $(mkfile) -nt $(mkstore) ]; then echo "$(red)Changes to Makefile detected, please run $(blue)make clean $(red)and retry!$(end)" & exit 1; fi

	-@rm $(mkstore) ${SHUTUP}
	@cp --preserve=timestamps $(mkfile) $(mkstore)

	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

build:
	@echo "$(arrow)$(green)Building the app...$(end)"
	@$(SWIFTC) $(FULLSWIFT) $(FILES)
	@$(ROOT)/bin/CommandGen.js $(DIR) "$(FULLSWIFT)" $(FILES) > $(DIR)/compile_commands.json

	@mkdir -p $(STAGEDIR)
	@mkdir -p $(STAGE)/DEBIAN
	@mkdir -p $(MKDIR)/_

sign:
	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	
	@touch $(MKDIR)/.swift-stamp.tmp;
	
	@echo "$(arrow)$(green)Signing the app...$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate
	@$(TBINS)/ldid -S $(MKDIR)/$(NAME) > /dev/null

	@if [ ! -z DEBUG ]; then\
		echo "$(arrow)$(green)Stripping binary$(end)"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null;\
	fi