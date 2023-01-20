include $(MKPATH)/c/flags.mk

FILES := $(if $(FILES),$(FILES),.)

ENV_GO := CGO_ENABLED=1 GOARCH=$(ARCH) GOOS=ios CC="$(CLANG) $(FLAGS)"
FULL_GO := build $(CUSTOM_GO) -o $(MKDIR)/$(NAME) $(FILES)