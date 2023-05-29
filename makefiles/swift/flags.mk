include $(MKPATH)/c/flags.mk

# unused CDIAGNOSTICS (-fcolor-diagnostics) FULLSWIFT (-Xfrontend -color-diagnostics -g -v)
# unused SWIFTOPTIMIZE -whole-module-optimization

SWIFT_COMPILER := $(TBINS)/swiftc

# C linker stuff
C_DEBUG := -ggdb -O0 # off by default
C_DIAGNOSTICS := -DTARGET_IPHONE=1 -Wall -Wno-unused-command-line-argument -Qunused-arguments -Werror

C_OPTIMIZE := -Os
C_ARGS = -isysroot $(SDK) -target $(TARGET) -fmodules -fcxx-modules -fbuild-session-file=$(MKDIR)/build_session -fmodules-prune-after=345600 -fmodules-prune-interval=86400 -fmodules-validate-once-per-build-session -arch arm64 -stdlib=libc++ -F$(SDK)/System/Library/PrivateFrameworks -F$(ROOT)/lib

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

SWIFT_BUILD = -emit-executable -o $(MKDIR)/$(NAME) -sdk $(SDK) -target $(TARGET) -F$(ROOT)/lib -incremental -output-file-map $(MKDIR)/output-file-map.json -emit-dependencies -swift-version 5
SWIFT_FULL = -c $(SWIFT_BUILD) $(SWIFT_C) $(SWIFT_LINKER) $(SWIFT_LIB) $(CUSTOM_SWIFT)

ifdef DEBUG
FULL_SWIFT += $(SWIFT_DEBUG)
else
FULL_SWIFT += $(SWIFT_OPTIMIZE)
endif