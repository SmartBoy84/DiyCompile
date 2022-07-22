MKPATH = $(DIYCOMPILE)/makefiles
TYPE=""

ifdef APP_NAME
	TYPE=app
else ifdef TOOL_NAME
	TYPE=tool
else
	$(error  Type not defined! Ensure something like APP_NAME is set in makefile)
endif

# finally!
include $(MKPATH)/common.mk
include $(MKPATH)/types/$(TYPE).mk
include $(MKPATH)/post.mk