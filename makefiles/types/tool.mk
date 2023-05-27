INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

all: config special build strip sign post
raw: all upload inject run
do: all deb install inject run

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@cp $(MKDIR)/$(NAME) $(STAGEDIR)

upload:
	$(REMOTETEST)

	@echo "$(arrow)$(red)[WARNING] $(blue)Removing old and uploading new static binary $(red)(did you mean to run $(green)make install$(red)?)$(end)"
	@$(SSH) "rm $(INSTALL_PATH)/$(NAME)" $(SHUTUP)
	@$(SCP) $(MKDIR)/$(NAME) $(CLIENT):$(INSTALL_PATH)

inject:
	$(REMOTETEST)

	@if [ ! -z $(TRUST_BIN) ]; then\
 		echo "$(arrow)$(green)Injecting into trustcache$(end)"; \
		$(SSH) "$(TRUST_BIN) $(INSTALL_PATH)/$(NAME) > /dev/null"; \
	fi;\

run:
	$(REMOTETEST)

	@echo "$(arrow)$(green)Running...$(end)"
	@echo ""
	@$(SSH) "$(INSTALL_PATH)/$(NAME)"
