# good idea to create an md5sum hash based on compiler arguments, that way if you add a file, framework or header everything will be recompiled but if you go back to how it was before the old files can be reused
# rather than manually do -Xcc [c flag] make a list of c flags and loop over them

# to be set in project's makefile - these are default values
ARCH := $(if $(ARCH),$(ARCH),arm64)
OS := $(if $(OS),$(OS),14.4)
SDK_OS := $(if $(SDK_OS),$(SDK_OS),$(OS))
PORT := $(if $(PORT),$(PORT),22)

# following allows for obtaining perms and bundling libraries/resources
APPLICATION_MODE = $(GIMME_PERM)

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
else ifdef RUST_NAME
	TYPE=tool
	LANG=rust
else
$(error Type not defined! Ensure something like [TYPE]_NAME is set in makefile)
endif

# FINALLY!
include $(MKPATH)/common.mk

