INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

all: config special build strip sign post
raw: all upload inject run
do: all deb install inject run

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@cp $(MKDIR)/$(NAME) $(STAGEDIR)

upload:
	@echo "$(arrow)$(red)[WARNING] $(blue)Uploading static binary $(red)(did you mean to run $(green)make install$(red)?)$(end)"
	@scp $(MKDIR)/$(NAME) $(SSH):$(INSTALL_PATH) > /dev/null

inject:
	@if [ ! -z $(TRUST_BIN) ]; then\
 		echo "$(arrow)$(blue)Injecting into trustcache$(end)"; \
		ssh $(SSH) "$(TRUST_BIN) $(NAME)"; \
	fi;\

run:
	@echo "$(arrow)$(green)Running...$(end)"
	@echo ""
	@ssh $(SSH) "$(INSTALL_PATH)/$(NAME)"