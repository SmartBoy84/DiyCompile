TARGET = $(ARCH)-apple-ios$(OS)

C_CLANG := $(TBINS)/clang

C_OPTIMIZE := -O3
C_DEBUG := -ggdb -O0 -DTARGET_IPHONE=1 -Wall -Qunused-arguments -Werror # off by default

C_FLAGS := 
C_BUILD = $(CUSTOM_C) -isysroot $(SDK) -target $(TARGET)

# build environment prelim
C_BUILD += $(if $(DEBUG),$(C_DEBUG),$(C_OPTIMIZE))

C_FULL = $(C_FLAGS) $(C_BUILD) $(FILES) -o $(MKDIR)/$(NAME)