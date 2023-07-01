include $(MKPATH)/c/flags.mk

TARGET := aarch64-apple-ios

CONFIG_PREFIX = --config target.$(TARGET).
LINKER_PREFIX = -Clink-args=

RUST_DEBUG :=
RUST_OPTIMIZE := --release

RUST_ENV := RUSTFLAGS="$(addprefix $(LINKER_PREFIX),$(C_FLAGS))"
RUST_CONFIG = linker=\"$(TBINS)/clang\" ar=\"$(TBINS)/ar\"

RUST_FLAGS := $(CUSTOM_RUST)
RUST_BUILD := --target $(TARGET) $(addprefix $(CONFIG_PREFIX),$(RUST_CONFIG))

RUST_FULL = build $(RUST_BUILD) $(RUST_FLAGS)

ifdef DEBUG
RUST_FLAGS += $(RUST_DEBUG)
else
RUST_FLAGS += $(RUST_OPTIMIZE)
endif
