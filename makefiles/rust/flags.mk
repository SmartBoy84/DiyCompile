include $(MKPATH)/c/flags.mk

CONFIG_PREFIX = --config target.$(TARGET).
LINKER_PREFIX = -Clink-args=

# rust moment, arm64 (ios) == aarch64 (ios)
TARGET := $(if $(filter arm64,$(ARCH)),aarch64,$(ARCH))-apple-ios

# rustc pass-through arguments
RUST_FLAGS =
RUST_CONFIG = linker=\"$(TBINS)/clang\"

# cargo (compiler front frontend) flags and configuration
CARGO_DEBUG =
CARGO_OPTIMIZE = --release

CARGO_FLAGS = $(CUSTOM_RUST)

# C linker
C_FLAGS += -Wno-unused-command-line-argument

# build environment prelim
CARGO_FLAGS += $(if $(DEBUG),$(CARGO_DEBUG),$(CARGO_OPTIMIZE))
RUST_FLAGS += $(addprefix $(LINKER_PREFIX),$(C_FLAGS) $(C_BUILD))

OUTPUT_DIR := $(DIR)/target/$(TARGET)/$(if $(DEBUG),debug,release)

CARGO_ENV = SDKROOT=$(SDK) RUSTFLAGS="$(RUST_FLAGS)"
CARGO_BUILD = --target $(TARGET) $(addprefix $(CONFIG_PREFIX),$(RUST_CONFIG))
CARGO_FULL = build $(CARGO_BUILD) $(CARGO_FLAGS)
