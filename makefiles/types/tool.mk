INSTALL_PATH := $(if $(INSTALL_PATH),$(INSTALL_PATH),/usr/local/bin)
STAGEDIR := $(STAGE)/$(INSTALL_PATH)

do: scout build sign post install run

post:
	echo $(STAGEDIR)
	@echo "$(arrow)$(green) Staging package dirs$(end)"
	@rsync --info=progress2 $(MKDIR)/$(NAME) $(STAGEDIR)

run:
	ssh mobile@$(IP) "$(INSTALL_PATH)/$(NAME)"