include $(MKPATH)/c/flags.mk

FILES := $(if $(FILES),$(FILES),build)

ENV_GO := CGO_ENABLED=1 GOARCH=$(ARCH) GOOS=ios CC="$(CLANG) $(FLAGS)"
FULL_GO := $(CUSTOM_GO) $(FILES) -o $(MKDIR)/$(NAME)