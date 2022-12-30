# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them
# fix intellisense by generating an appropriate package.swift or compile_commands.json (easier?)

# to be set in project's makefile - these are default values
ARCH := $(if $(ARCH),$(ARCH),arm64)
OS := $(if $(OS),$(OS),14.5)
PORT := $(if $(PORT),$(PORT),22)

MKPATH = $(DIYCOMPILE)/makefiles
TYPE=""
LANG=""

ifdef APP_NAME
	TYPE=app
	LANG=swift
else ifdef SWIFT_NAME
	TYPE=tool
	LANG=swift
else ifdef C_NAME
	TYPE=tool
	LANG=c
else ifdef GO_NAME
	TYPE=tool
	LANG=go
else
$(error Type not defined! Ensure something like APP_NAME is set in makefile)
endif

# FINALLY!
include $(MKPATH)/$(LANG)/compile.mk
include $(MKPATH)/types/$(TYPE).mk

