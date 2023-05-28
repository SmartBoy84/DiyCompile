include $(MKPATH)/c/flags.mk

FILES := $(if $(FILES),$(FILES),.)

GO_ENV := CGO_ENABLED=1 GOARCH=$(ARCH) GOOS=ios CC="$(C_CLANG) $(C_FLAGS)"
GO_FULL := build $(CUSTOM_GO) -o $(MKDIR)/$(NAME) $(FILES)