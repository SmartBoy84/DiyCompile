CLANG := $(TBINS)/clang
FLAGS := $(CUSTOM_C) -isysroot $(SDK) -target $(TARGET)
FULL_CLANG := $(FLAGS) $(FILES) -o $(MKDIR)/$(NAME)