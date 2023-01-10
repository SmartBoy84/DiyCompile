DEB := $(COUNTERS)/DEB

clean:
	@echo "$(arrow)$(green)Cleaning...$(end)"
	
	-@rm -r $(MKDIR) $(MUTE)
	-@rm -r packages $(MUTE)

deb:
	$(BUILD_TEST)

	@echo "$(arrow)$(green)Making deb...$(end)"

	-@mkdir -p packages/.old
	@mv packages/*.deb packages/.old $(MUTE)

	@cp control $(STAGE)/DEBIAN
	@cp -r layout/* $(STAGE) > /dev/null $(SHUTUP)

	$(eval COUNTER=$(shell [ -f $(DEB) ] && echo $$(($$(cat $(DEB)) + 1)) || echo 1))
	@echo $(COUNTER) > $(DEB)

	@cd $(STAGE) ;\
	dpkg-deb -Zxz -z0 -b . $(DIR)/packages/$(PACKAGE)_$(VERSION)-$(COUNTER)_$(PLATFORM).deb > /dev/null;\

strip:
	@if [ ! -z DEBUG ]; then\
		echo "$(arrow)$(green)Stripping binary$(end)"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null;\
	fi

install:
	$(REMOTETEST)
	@if [ ! -f packages/*.deb ]; then echo "$(red)Build a package first!$(end)"; $(RERUN) deb; fi
	
	@echo "$(arrow)$(green)Installing to $(CLIENT)...$(end)"
	@$(SCP) packages/*.deb $(CLIENT):/tmp/build.deb > /dev/null
	@$(SSH) "dpkg -i /tmp/build.deb && uicache"

remove:
	$(REMOTETEST)
	@$(SSH) "dpkg -r $(PACKAGE) && uicache"

sign:
	@echo "$(arrow)$(green)Signing the app...$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate $(TBINS)/ldid -S$(ENTITLEMENTS) $(MKDIR)/$(NAME) > /dev/null