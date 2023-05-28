INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

all: config special build strip sign
raw: all upload inject run
do: all deb install inject run

# ln -rs important as I want it to be relative

post:
	$(BUILD_TEST)
	
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	
	@if [ $(GIMME_PERM) -eq 1 ]; then\
		echo "$(arrow)$(red)Permissions hack enabled!$(end)";\
		mkdir -p $(STAGE)/Applications/$(NAME).app;\
		cp $(MKDIR)/$(NAME) $(STAGE)/Applications/$(NAME).app;\
		ln -rsf /Applications/$(NAME).app/$(NAME) $(STAGEDIR)/$(NAME);\
		INSTALL_PATH=/Applications/$(NAME).app;\
	else\
		cp $(MKDIR)/$(NAME) $(STAGEDIR);\
	fi;

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
