special: prelim

prelim:

ifeq ($(wildcard $(DIR)/go.mod),)
 	@echo "$(arrow)$(blue)Initialising new go module $(green)$(name)$(end)"
	@go mod init $(NAME) > /dev/null
endif

	@echo "$(arrow)$(blue)Tidying up$(end)"
	@go mod tidy

build: config
	@echo "$(arrow)$(green)Building go app$(end)"
	@$(GO_ENV) go $(GO_FULL)
