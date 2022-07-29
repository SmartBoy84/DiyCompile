#$(date -r $(DIR)/Makefile)

mkfile := $(DIR)/Makefile
mkstore := $(MKDIR)/.makefile

all: scout build sign post

scout:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	
	@if [ -f $(mkstore) ]; then\
		if [ $(mkfile) -nt $(mkstore) ]; then echo "$(red)Changes to Makefile detected, please run $(blue)make clean $(red)and retry!$(end)" & exit 1; fi \
		else \
 			echo "$(arrow)$(blue)Initializing new build$(end)"; \
			mkdir -p $(STAGEDIR); \
			mkdir -p $(STAGE)/DEBIAN; \
			mkdir -p $(MKDIR)/_; \
			for name in $(FILES); do mkdir -p .build/$$(dirname $$name); done; \
			echo "mksystem=${DIYCOMPILE}\nsdk=$(SDK)\nios=$(OS)\narch=$(ARCH)\nresourceDir=$(TOOLCHAIN)/lib/swift" > $(MKDIR)/.spm.conf; \
			rm $(mkstore) ${SHUTUP}; \
			cp --preserve=timestamps $(mkfile) $(mkstore); \
		fi;\


	@$(ROOT)/bin/FileMapGenerator.js $(MKDIR) $(FILES) > $(MKDIR)/output-file-map.json

initialize:
	

build:
	@echo "$(arrow)$(green)Building the app...$(end)"
	@$(SWIFTC) $(FULLSWIFT) $(FILES)
#@$(TBINS)/swift build -v
	@$(ROOT)/bin/CommandGen.js $(DIR) "$(FULLSWIFT)" $(FILES) > $(DIR)/compile_commands.json

	@if [ ! -z DEBUG ]; then\
		echo "$(arrow)$(green)Stripping binary$(end)"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null;\
	fi

sign:
	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	
	@touch $(MKDIR)/.swift-stamp.tmp;
	
	@echo "$(arrow)$(green)Signing the app...$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate $(TBINS)/ldid -S$(ENTITLEMENTS) $(MKDIR)/$(NAME) > /dev/null