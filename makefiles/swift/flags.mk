include $(MKPATH)/c/flags.mk

# unused CDIAGNOSTICS (-fcolor-diagnostics) FULLSWIFT (-Xfrontend -color-diagnostics -g -v)
# unused SWIFTOPTIMIZE -whole-module-optimization

TARGET = $(ARCH)-apple-ios$(OS)

SWIFT_COMPILER := $(TBINS)/swiftc

C_ARGS = -isysroot $(C_FLAGS) -fmodules -fcxx-modules -fbuild-session-file=$(MKDIR)/build_session -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session -arch $(ARCH) -stdlib=libc++ -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib

FRAMEWORK_FOLDER := Frameworks
C_LIB = -rpath @executable_path/$(FRAMEWORK_FOLDER)

ifdef INFO
C_PLIST := $(if $(INFO), -sectcreate __TEXT __info_plist $(INFO),)
endif

# actual swift stuff
SWIFT_DEBUG = -DDEBUG -Onone
SWIFT_OPTIMIZE := -O -num-threads 1 -whole-module-optimization

SWIFT_C := $(addprefix -Xcc ,$(C_ARGS) $(C_FLAGS))
SWIFT_LINKER := $(addprefix -Xlinker ,$(C_PLIST) $(C_LIB))

SWIFT_LIB = -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib -resource-dir $(TOOLCHAIN)/lib/swift

SWIFT_FLAGS := $(CUSTOM_C)
SWIFT_BUILD = -emit-executable -o $(MKDIR)/$(NAME) -sdk $(SDK) -target $(TARGET) -F$(ROOT)/lib -incremental -output-file-map $(MKDIR)/output-file-map.json -emit-dependencies -swift-version 5

SWIFT_FULL = -c $(SWIFT_BUILD) $(SWIFT_FLAGS) $(SWIFT_C) $(SWIFT_LINKER) $(SWIFT_LIB)

ifdef DEBUG
SWIFT_FULL += $(SWIFT_DEBUG)
else
SWIFT_FULL += $(SWIFT_OPTIMIZE)
endif