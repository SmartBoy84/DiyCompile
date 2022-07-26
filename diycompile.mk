# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them
# fix intellisense by generating an appropriate package.swift or compile_commands.json (easier?)

# to be set in project's makefile
ARCH := $(if $(ARCH),$(ARCH),arm64)
OS := $(if $(OS),$(OS),14.5)

MKPATH = $(DIYCOMPILE)/makefiles
TYPE=""

ifdef APP_NAME
	TYPE=app
else ifdef TOOL_NAME
	TYPE=tool
else
$(error Type not defined! Ensure something like APP_NAME is set in makefile)
endif

# boilerplate
include $(MKPATH)/common.mk
include $(MKPATH)/compile.mk
include $(MKPATH)/post.mk

# FINALLY!
include $(MKPATH)/types/$(TYPE).mk

