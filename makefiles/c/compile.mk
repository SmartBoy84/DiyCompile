# boilerplate
include $(MKPATH)/common.mk
include $(MKPATH)/setup.mk
include $(MKPATH)/post.mk

include $(MKPATH)/go/flags.mk

special:

build:
	@echo "$(arrow)$(green)Building C app$(end)"
	@$(CLANG) $(FULL_CLANG)