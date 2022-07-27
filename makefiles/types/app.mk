# excuse this
INSTALL_PATH := /Applications
STAGEDIR := $(STAGE)/Applications

IPA := $(MKDIR)/_/IPA

all: scout build sign post

# could make this universal but can you see why I'm not going to risk it?
do:
	$(REMOTETEST)
	@$(RERUN)
	
	@if ssh root@$(IP) "stat $(INSTALL_PATH)/$(NAME).app/$(NAME)" > /dev/null; then \
		echo "$(arrow)$(green)Updating files to $(blue)$(IP)$(end)$(green)...$(end)"; \
		rsync -ar --info=progress2 $(STAGEDIR)/$(NAME).app/ root@$(IP):/Applications/$(NAME).app/ --delete ; \
	else \
		echo "$(red)App isn't installed at all!$(end)"; \
		$(RERUN) install; \
	fi
	@echo "$(arrow)$(green)Launching...$(end)"
	-@ssh root@$(IP) "killall $(NAME) > /dev/null; uiopen $(NAME)://"

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@rsync --info=progress2 $(MKDIR)/$(NAME) $(DIR)/Resources/* $(STAGEDIR)/$(NAME).app
	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(STAGEDIR)/$(NAME).app/Info.plist

ipa:
	$(BUILD_TEST)
	@echo "$(arrow)$(green)Making IPA...$(end)"

	-@mkdir -p packages/.old
	-@mv packages/*.ipa packages/.old ${SHUTUP}

	$(eval COUNTER=$(shell [ -f $(IPA) ] && echo $$(($$(cat $(IPA)) + 1)) || echo 0))
	@echo $(COUNTER) > $(IPA)

	@cd $(STAGEDIR)/.. ;\
	mv $(FOLDER) Payload ;\
	zip -rq $(DIR)/packages/$(NAME)-$(VERSION)_$(COUNTER).ipa Payload ;\
	mv Payload $(FOLDER) ;\