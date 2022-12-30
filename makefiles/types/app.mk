# excuse this
INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/Applications)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

IPA := $(MKDIR)/_/IPA

all: config special scout build strip sign post
# do: all deb install run

# could make this universal but can you see why I'm not going to risk it? --delete (delete root?)
do:
	$(REMOTETEST)
	@$(RERUN) all
	
	@if $(SSH) "stat $(INSTALL_PATH)/$(NAME).app/$(NAME)" > /dev/null; then \
		echo "$(arrow)$(green)Updating files to $(blue)$(CLIENT)$(end)$(green)...$(end)"; \
		rsync -ar --info=progress2 $(STAGEDIR)/$(NAME).app/ $(CLIENT):/Applications/$(NAME).app/ --delete ; \
	else \
		echo "$(red)App isn't installed at all!$(end)"; \
		$(RERUN) install; \
	fi

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@rsync --info=progress2 $(MKDIR)/$(NAME) $(DIR)/Resources/* $(STAGEDIR)/$(NAME).app
	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(STAGEDIR)/$(NAME).app/Info.plist

run:
	@echo "$(arrow)$(green)Launching...$(end)"
	-@$(SSH) "killall $(NAME) > /dev/null; uiopen $(NAME)://"

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