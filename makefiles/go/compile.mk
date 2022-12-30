# boilerplate
include $(MKPATH)/common.mk
include $(MKPATH)/setup.mk
include $(MKPATH)/post.mk

include $(MKPATH)/go/flags.mk

special: prelim

prelim:
	@if [ ! -f $(DIR)/go.mod ]; then\
 		echo "$(arrow)$(blue)Initialising new go module $(green)$(name)$(end)"; \
		go mod init $(NAME) > /dev/null; \
	fi;\
	
	@echo "$(arrow)$(blue)Tidying up...$(end)"

build: prelim
	@echo "$(arrow)$(green)Building go app...$(end)"
	@$(ENV_GO) go $(FULL_GO)