# excuse this
INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/Applications)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

IPA := $(COUNTERS)/IPA

all: config special scout build strip sign post
# do: all deb install run

# could make this universal but can you see why I'm not going to risk it? --delete (delete root?)
LOCAL_APP_DIR := $(STAGEDIR)/$(NAME).app
REMOTE_APP_DIR := $(INSTALL_PATH)/$(NAME).app/

do:
	$(REMOTETEST)
	@$(RERUN) all

	@if $(SSH) "stat $(REMOTE_APP_DIR)/$(NAME)" > /dev/null; then \
		echo "$(arrow)$(green)Updating files to $(blue)$(CLIENT)$(end)$(green)...$(end)"; \
		rsync -ar --info=progress2 $(LOCAL_APP_DIR)/ $(CLIENT):/$(REMOTE_APP_DIR)/ --delete ; \
	else \
		echo "$(red)App isn't installed at all!$(end)"; \
		$(RERUN) install; \
	fi

	@$(RERUN) run

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@rsync --info=progress2 $(MKDIR)/$(NAME) $(DIR)/Resources/* $(LOCAL_APP_DIR)
	@sed -i "s/@@VERSION@@/$(VERSION)/g" $(LOCAL_APP_DIR)//Info.plist

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

	@mkdir $(MKDIR)/Payload $(SHUTUP)
	@mv $(LOCAL_APP_DIR) $(MKDIR)/Payload/
	@cd $(MKDIR); zip -ryq $(DIR)/packages/$(NAME)-$(VERSION)_$(COUNTER).ipa Payload;\
	@mv $(MKDIR)/Payload/* $(LOCAL_APP_DIR)
