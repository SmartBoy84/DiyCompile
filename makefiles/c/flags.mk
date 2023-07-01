C_CLANG := $(TBINS)/clang

C_OPTIMIZE := -O3
C_DEBUG := -ggdb -O0 -DTARGET_IPHONE=1 -Wall -Wno-unused-command-line-argument -Qunused-arguments -Werror # off by default

C_FLAGS := $(CUSTOM_C)
C_BUILD := -isysroot $(SDK) -target $(TARGET)

C_FULL = $(C_FLAGS) $(C_BUILD) $(FILES) -o $(MKDIR)/$(NAME)

ifdef DEBUG
C_FLAGS += $(C_DEBUG)
else
C_FLAGS += $(C_OPTIMIZE)
endif