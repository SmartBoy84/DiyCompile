clean:
	@echo "$(arrow)$(green)Cleaning...$(end)"
	
	-@rm -r $(MKDIR) $(MUTE)
	-@rm -r packages $(MUTE)

install:
	$(REMOTETEST)
	@if [ ! -f packages/*.deb ]; then echo "$(red)Build a package first!$(end)"; $(RERUN) deb; fi
	
	@echo "$(arrow)$(green)Installing to $(IP)...$(end)"
	@scp packages/*.deb root@$(IP):/tmp/build.deb > /dev/null
	@ssh root@$(IP) "dpkg -i /tmp/build.deb && uicache"