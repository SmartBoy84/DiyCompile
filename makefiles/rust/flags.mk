include $(MKPATH)/c/flags.mk

CONFIG_PREFIX = --config target.$(TARGET).
LINKER_PREFIX = -Clink-arg=

# rust moment, arm64 (ios) == aarch64 (ios)
TARGET := $(if $(filter arm64,$(ARCH)),aarch64,$(ARCH))-apple-ios

# rustc pass-through arguments
RUST_FLAGS = $(addprefix $(LINKER_PREFIX),$(C_BUILD))
RUST_CONFIG = linker=\"$(C_CLANG)\"

# cargo (compiler front frontend) flags and configuration
CARGO_DEBUG = -Cdebug-info=2 -Copt-level=0
CARGO_OPTIMIZE = --release

CARGO_FLAGS = $(if $(DEBUG),$(CARGO_DEBUG),$(CARGO_OPTIMIZE))
CARGO_BUILD = --target $(TARGET) $(CUSTOM_RUST) $(addprefix $(CONFIG_PREFIX),$(RUST_CONFIG))

# C linker
C_BUILD += -Wno-unused-command-line-argument

# build environment prelim
OUTPUT_DIR := $(DIR)/target/$(TARGET)/$(if $(DEBUG),debug,release)
CARGO_FULL = build $(CARGO_BUILD) $(CARGO_FLAGS)

# point CC to clang (for cc create or variants) - FIX ME, for some reason CC=".../clang" doesn't work
CARGO_ENV = CRATE_CC_NO_DEFAULTS=1 CFLAGS="$(C_BUILD)" CC_$(subst -,_,$(TARGET))="$(C_CLANG)" CC="$(C_CLANG)" SDKROOT="$(SDK)" RUSTFLAGS="$(RUST_FLAGS)"
