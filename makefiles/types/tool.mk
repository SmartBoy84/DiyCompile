
INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

all: config special build strip sign post
do: config special build strip sign post deb install run

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@cp $(MKDIR)/$(NAME) $(STAGEDIR)

run:
	@echo "$(arrow)$(green)Running...$(end)"
	@echo ""
	@ssh $(SSH) "$(INSTALL_PATH)/$(NAME)"