# excuse this
STAGE := main
APPDIR := $(MKDIR)/app/$(STAGE)
IPA := $(MKDIR)/_/IPA
DEB := $(MKDIR)/_/DEB

all: scout build post

remove:
	$(REMOTETEST)
	@ssh root@$(IP) "dpkg -r $(PACKAGE) && uicache"

do:
	$(REMOTETEST)
	@$(RERUN)
	
	@if ssh root@192.168.0.251 "stat /Applications/$(NAME).app/$(NAME)" > /dev/null; then \
		echo "$(arrow)$(green)Updating files to $(blue)$(IP)$(end)$(green)...$(end)"; \
		rsync -ar --info=progress2 $(APPDIR)/$(NAME).app/ root@$(IP):/Applications/$(NAME).app/ --delete ; \
	else \
		echo "$(red)App isn't installed at all!$(end)"; \
		$(RERUN) install; \
	fi
	-@ssh root@$(IP) "killall $(NAME); uiopen $(NAME)://"

post:
	@if [ -f $(MKDIR)/.swift-stamp.tmp ]; then rm $(MKDIR)/.swift-stamp.tmp; fi
	@touch $(MKDIR)/.swift-stamp.tmp;
	
	@echo "$(arrow)$(green)Signing the app...$(end)"
	@CODESIGN_ALLOCATE=$(TBINS)/codesign_allocate
	@$(TBINS)/ldid -S $(MKDIR)/$(NAME) > /dev/null

	@if [ ! -z DEBUG ]; then\
		echo "$(arrow)$(green)Stripping binary$(end)"; \
		$(TBINS)/strip -x $(MKDIR)/$(NAME) > /dev/null;\
	fi

	@mkdir -p $(APPDIR)
	@mkdir -p $(APPDIR)/../DEBIAN
	@mkdir -p $(MKDIR)/_
	
	@rsync --info=progress2 $(MKDIR)/$(NAME) $(DIR)/Resources/* $(APPDIR)/$(NAME).app
	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(APPDIR)/$(NAME).app/Info.plist

ipa:
	@$(RERUN) all
	@echo "$(arrow)$(green)Making IPA...$(end)"

	-@mkdir -p packages/.old
	-@mv packages/*.ipa packages/.old ${SHUTUP}

	$(eval COUNTER=$(shell [ -f $(IPA) ] && echo $$(($$(cat $(IPA)) + 1)) || echo 0))
	@echo $(COUNTER) > $(IPA)

	@cd $(APPDIR)/.. ;\
	mv $(STAGE) Payload ;\
	zip -rq $(DIR)/packages/$(NAME)-$(VERSION)_$(COUNTER).ipa Payload ;\
	mv Payload $(STAGE) ;\

deb:
	@$(RERUN) all
	@echo "$(arrow)$(green)Making deb...$(end)"
			
	-@mkdir -p packages/.old
	@mv packages/*.deb packages/.old $(MUTE)

	@cp control $(APPDIR)/../DEBIAN

	$(eval COUNTER=$(shell [ -f $(DEB) ] && echo $$(($$(cat $(DEB)) + 1)) || echo 1))
	@echo $(COUNTER) > $(DEB)

	@cd $(APPDIR)/.. ;\
	mv $(STAGE) Applications ;\
	dpkg-deb -Zxz -z0 -b . $(DIR)/packages/$(PACKAGE)_$(VERSION)-$(COUNTER)_$(PLATFORM).deb > /dev/null;\
	mv Applications $(STAGE) ;\