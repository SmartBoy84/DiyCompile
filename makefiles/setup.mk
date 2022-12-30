MKFILE := $(DIR)/Makefile
MKSTORE := $(MKDIR)/.makefile

config:
	@if [ ! -d $(MKDIR) ]; then mkdir -p $(MKDIR); fi
	
	@if [ -f $(MKSTORE) ]; then\
		if [ $(MKFILE) -nt $(MKSTORE) ]; then echo "$(red)Changes to Makefile detected, please run $(blue)make clean $(red)and retry!$(end)" & exit 1; fi \
		else \
 			echo "$(arrow)$(blue)Initializing new build$(end)"; \
			mkdir -p $(STAGEDIR); \
			mkdir -p $(STAGE)/DEBIAN; \
			mkdir -p $(MKDIR)/_; \
			for name in $(FILES); do mkdir -p .build/$$(dirname $$name); done; \
			rm $(MKSTORE) ${SHUTUP}; \
			cp --preserve=timestamps $(MKFILE) $(MKSTORE); \
		fi;\