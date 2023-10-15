MKFILE := $(DIR)/Makefile
MKSTORE := $(MKDIR)/.makefile

config: setup special

setup:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	
ifeq ("$(wildcard $(MKSTORE))","")
		
	@echo "$(arrow)$(blue)Initializing new build$(end)"
	@mkdir -p $(STAGE)/DEBIAN
	@mkdir -p $(COUNTERS)
	@mkdir -p $(STAGED_EXECUTABLE)
	@rm $(MKSTORE) ${SHUTUP}
	@cp --preserve=timestamps $(MKFILE) $(MKSTORE)
	
else ifeq ($(shell cmp --silent $(MKSTORE) $(MKFILE) || echo 1), 1)
	@echo "$(red)Changes to Makefile detected, please run $(blue)make clean $(red)$(end)"

# be a bit more strict with swift since user can add libraries
ifeq ($(LANG),swift)
	$(EARLY_EXIT)
endif
endif

	@touch $(MKDIR)/build_session

# if app, requires perms or defines INFO variable then check to see if Info.plist is valid
ifeq ($(or $(filter %.app,$(suffix $(INSTALL_PATH))),$(GIMME_PERM),$(shell if [ -n "$(INFO)" ]; then echo 1; fi)),1)

# ugly check, create info.plist if it doesn't exist
ifeq ($(wildcard $(INFO)),)
	@echo "$(arrow)$(blue)$(INFO)$(red) doesn't exist at specified path so baking a fresh Info.plist$(end)"
	@cp $(TEMPLATE_INFO) $(INFO)
	
# Configure Info.plist
	@sed -i "s/@@PROJECTNAME@@/${NAME}/g" $(INFO)
	@sed -i "s/@@PACKAGENAME@@/${PACKAGE}/g" $(INFO)
	@sed -i "s/@@VERSION@@/${OS}/g" $(INFO)

endif

	@echo "$(arrow)$(blue)Will add info.plist$(end)"

	@cp $(INFO) $(MKDIR)/Info.plist
	@INFO=$(MKDIR)/Info.plist

	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(INFO)

endif	