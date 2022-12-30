# boilerplate
include $(MKPATH)/swift/compile.mk

INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

do: config scout build sign post deb install run

post:
	@echo "$(arrow)$(green)Staging package dirs$(end)"
	@cp $(MKDIR)/$(NAME) $(STAGEDIR)

run:
	@echo "$(arrow)$(green)Running...$(end)"
	@ssh mobile@$(IP) "$(INSTALL_PATH)/$(NAME)"