special:

build: config
	@echo "$(arrow)$(green)Building C app$(end)"
	@$(C_CLANG) $(C_FULL)