C_CLANG := $(TBINS)/clang
C_FLAGS := $(CUSTOM_C) -isysroot $(SDK) -target $(TARGET)
C_FULL := $(C_FLAGS) $(FILES) -o $(MKDIR)/$(NAME)