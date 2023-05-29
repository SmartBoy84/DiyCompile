DEB := $(COUNTERS)/DEB
SNOOPY := com.barfie.snoopy

APPLICATION_MODE := $(if $(RESOURCES),1,$(APPLICATION_MODE))
APPLICATION_PATH := /Applications/$(NAME).app

deb: all special stage _bundle_deb

stage:	
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	
ifeq ($(APPLICATION_MODE),1)
	@echo "$(arrow)$(red)Applications mode enabled!$(end)"
	@echo "$(RESOURCES) bro"
ifeq ($(suffix $(INSTALL_PATH)),.app)
	@echo "$(arrow)$(blue)[Warning] Install path ends with .app so not symlinking as assumed app bundle$(end)"
else
	@ln -rsf $(APPLICATION_PATH)/$(NAME) $(STAGED_EXECUTABLE)/$(NAME)
	@$(eval INSTALL_PATH=$(APPLICATION_PATH))
endif
	
	@mkdir -p $(STAGED_EXECUTABLE)
	@rsync -r --info=progress2 $(MKDIR)/$(NAME) $(RESOURCES) $(STAGED_EXECUTABLE)
else
	@cp $(MKDIR)/$(NAME) $(STAGED_EXECUTABLE)
endif

clean:
	@echo "$(arrow)$(green)Cleaning$(end)"

	-@rm -r $(MKDIR) $(MUTE)
	-@rm -r packages $(MUTE)

_bundle_deb:
	@echo "$(arrow)$(green)Making deb$(end)"

	-@mkdir -p packages/.old
	@mv packages/*.deb packages/.old $(MUTE)

	@cp control $(STAGE)/DEBIAN

ifeq ($(GIMME_PERM),1)
	
	@echo "/usr/bin/snoopy add $(PACKAGE) $(INSTALL_PATH)/$(NAME)" > $(STAGE)/DEBIAN/postinst
	
	@chmod +x $(STAGE)/DEBIAN/postinst
	@chmod 0755 $(STAGE)/DEBIAN/postinst
	
	@echo "/usr/bin/snoopy remove $(PACKAGE) $(INSTALL_PATH)/$(NAME)" > $(STAGE)/DEBIAN/prerm
	
	@chmod +x $(STAGE)/DEBIAN/prerm
	@chmod 0755 $(STAGE)/DEBIAN/prerm
	
	@if grep -q "^Depends:" "$(STAGE)/DEBIAN/control"; then sed -i "/^Depends:/ s/$$/, $(SNOOPY)/" "$(STAGE)/DEBIAN/control"; else echo "Depends: $(SNOOPY)" >> "$(STAGE)/DEBIAN/control"; fi;
endif

	@cp -r layout/* $(STAGE) > /dev/null $(SHUTUP)

	$(eval COUNTER=$(shell [ -f $(DEB) ] && echo $$(($$(cat $(DEB)) + 1)) || echo 1))
	@echo $(COUNTER) > $(DEB)

	@cd $(STAGE) && dpkg-deb -Zxz -z0 -b . $(DIR)/packages/$(PACKAGE)_$(VERSION)-$(COUNTER)_$(PLATFORM).deb > /dev/null

strip:
ifndef DEBUG
	@echo "$(arrow)$(green)Stripping binary$(end)"
	@$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null
endif

install:
	$(REMOTETEST)

ifeq ("$(wildcard packages/*.deb)","")
	@echo "$(arrow)$(red)Build a package first!$(end)"
	@$(RERUN) deb
endif
	
	@echo "$(arrow)$(green)Installing to $(CLIENT)...$(end)"
	@$(SCP) packages/*.deb $(CLIENT):/tmp/build.deb > /dev/null
	@$(SSH) "dpkg -i /tmp/build.deb && uicache"

remove:
	$(REMOTETEST)
	@$(SSH) "dpkg -r $(PACKAGE) && uicache"

sign:
	@echo "$(arrow)$(green)Signing the app$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate $(TBINS)/ldid -S$(ENTITLEMENTS) $(MKDIR)/$(NAME) > /dev/null
