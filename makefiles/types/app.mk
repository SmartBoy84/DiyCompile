### lang ambiguities
# I don't know why it needs this (not for rust, doesn't affect it's build)
SWIFT_FULL += -parse-as-library

# excuse this
INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH)/$(NAME).app,/Applications/$(NAME).app)
IPA = $(COUNTERS)/IPA

APPLICATION_MODE = 1

all: config special build strip sign post
ipa: post stage _bundle_ipa
do: all deb install run

post:

run:
	@echo "$(arrow)$(green)Launching$(end)"
	-@$(SSH) "killall $(NAME) > /dev/null; uiopen $(NAME)://"

_bundle_ipa:
	@echo "$(arrow)$(green)Making IPA$(end)"

	-@mkdir -p packages/.old
	-@mv packages/*.ipa packages/.old ${SHUTUP}

	$(eval COUNTER=$(shell [ -f $(IPA) ] && echo $$(($$(cat $(IPA)) + 1)) || echo 0))
	@echo $(COUNTER) > $(IPA)

	@mkdir $(MKDIR)/Payload $(SHUTUP)
	@mv $(STAGED_EXECUTABLE) $(MKDIR)/Payload/
	@cd $(MKDIR); zip -ryq $(DIR)/packages/$(NAME)-$(VERSION)_$(COUNTER).ipa Payload;\
	@mv $(MKDIR)/Payload/* $(STAGED_EXECUTABLE)

__ultradangerous_do:
	$(REMOTETEST)
	@$(RERUN) all

	@if $(SSH) "stat $(INSTALL_PATH)/$(NAME).app/$(NAME)" > /dev/null; then \
		echo "$(arrow)$(green)Updating files to $(blue)$(CLIENT)$(end)$(green)$(end)"; \
		rsync -ar --info=progress2 $(LOCAL_APP_DIR)/ $(CLIENT):/$(INSTALL_PATH)/$(NAME).app/ --delete ; \
	else \
		echo "$(arrow)$(red)App isn't installed at all!$(end)"; \
		$(RERUN) install; \
	fi

	@$(RERUN) run
