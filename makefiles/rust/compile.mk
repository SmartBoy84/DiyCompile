special: prelim

prelim:

ifdef FILES
	@echo "$(arrow)$(red)Sorry but let's roll by rust's rules$(end)"
	@echo "$(arrow)$(green)Remove FILES var and run $(blue)make clean && make init$(end)"
	$(EARLY_EXIT)
endif

ifeq ($(wildcard $(DIR)/Cargo.toml),)
	@echo "$(arrow)$(blue)Initialising new rust app: $(green)$(name)$(end)"
	@cargo init > /dev/null
endif

_clean:
	@echo "$(arrow)$(blue)Tidying up$(end)"
	@cargo clean

build: config
	@echo "$(arrow)$(green)Building rust app$(end)"
	@$(CARGO_ENV) cargo $(CARGO_FULL)
	@mv $(OUTPUT_DIR)/$(NAME) $(MKDIR)
