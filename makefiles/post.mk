DEB := $(MKDIR)/_/DEB

clean:
	@echo "$(arrow)$(green)Cleaning...$(end)"
	
	-@rm -r $(MKDIR) $(MUTE)
	-@rm -r packages $(MUTE)

deb:
	@echo "$(arrow)$(green)Making deb...$(end)"
	$(BUILD_TEST)

	-@mkdir -p packages/.old
	@mv packages/*.deb packages/.old $(MUTE)

	@cp control $(STAGE)/DEBIAN

	$(eval COUNTER=$(shell [ -f $(DEB) ] && echo $$(($$(cat $(DEB)) + 1)) || echo 1))
	@echo $(COUNTER) > $(DEB)

	@cd $(STAGE) ;\
	dpkg-deb -Zxz -z0 -b . $(DIR)/packages/$(PACKAGE)_$(VERSION)-$(COUNTER)_$(PLATFORM).deb > /dev/null;\

install:
	@echo "$(arrow)$(green)Installing...$(end)"
	$(REMOTETEST)
	@if [ ! -f packages/*.deb ]; then echo "$(red)Build a package first!$(end)"; $(RERUN) deb; fi
	
	@echo "$(arrow)$(green)Installing to $(IP)...$(end)"
	@scp packages/*.deb root@$(IP):/tmp/build.deb > /dev/null
	@ssh root@$(IP) "dpkg -i /tmp/build.deb && uicache"

remove:
	$(REMOTETEST)
	@ssh root@$(IP) "dpkg -r $(PACKAGE) && uicache"