INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)

all: config special build strip sign post
do: all deb install inject run

# ln -rs important as I want it to be relative

post: 

inject:
	$(REMOTETEST)

ifdef TRUST_BIN
	@echo "$(arrow)$(green)Injecting into trustcache$(end)"
	@$(SSH) "$(TRUST_BIN) $(INSTALL_PATH)/$(NAME) > /dev/null"
endif

run:
	$(REMOTETEST)

	@echo "$(arrow)$(green)Running...$(end)"
	@echo ""
	@$(SSH) "$(INSTALL_PATH)/$(NAME)"

__ultradangerous_raw: all post __ultradangerous_upload inject run

__ultradangerous_upload:
	$(REMOTETEST)

	@echo "$(arrow)$(red)[WARNING] $(blue)Removing old and uploading new static binary $(red)(did you mean to run $(green)make install$(red)?)$(end)"
	@$(SSH) "rm $(INSTALL_PATH)/$(NAME)" $(SHUTUP)
	@$(SCP) $(MKDIR)/$(NAME) $(CLIENT):$(INSTALL_PATH)