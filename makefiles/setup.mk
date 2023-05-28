MKFILE := $(DIR)/Makefile
MKSTORE := $(MKDIR)/.makefile

ifdef INFO
CONDITION := 1
endif

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
	@echo "$(red)Changes to Makefile detected, please run $(blue)make clean $(red)and retry!$(end)" 
	exit 1
endif

	@touch $(MKDIR)/build_session

# if app, requires perms or defines INFO variable then check to see if Info.plist is valid
ifeq ($(or $(filter %.app,$(suffix $(INSTALL_PATH))),$(GIMME_PERM),$(shell if [ -n "$(INFO)" ]; then echo 1; fi)),1)

ifeq ($(shell test ! -f "$(INFO)" || test "$$(basename "$(INFO)")" != "Info.plist"; echo $$?),0)
	@echo "$(arrow)$(red)$(blue)Info.plist$(red) improperly defined or doesn't exist (but context necessitates it)!$(end)"
	exit 1
endif
	@echo "$(arrow)$(blue)Will add info.plist$(end)"

	@cp $(INFO) $(MKDIR)
	@INFO=$(MKDIR)/Info.plist

	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(INFO)

endif	