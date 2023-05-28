# boilerplate
include $(MKPATH)/common.mk
include $(MKPATH)/setup.mk
include $(MKPATH)/post.mk

include $(MKPATH)/go/flags.mk

special:

build: config
	@echo "$(arrow)$(green)Building C app$(end)"
	@$(C_CLANG) $(C_FULL)