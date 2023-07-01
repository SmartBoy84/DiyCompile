SSH = ssh -p $(PORT) $(CLIENT)
SCP = scp -q -P $(PORT)

# this is for stuff I just do NOT give a damn about
SHUTUP=2> /dev/null ||:

# Color escape codes
green=\033[0;32m
red=\033[0;31m
blue=\033[0;34m
end=\033[0m
arrow=$(red)=> $(end)
MUTE=2>/dev/null; true
space := $(subst ,, )

ROOT = ${DIYCOMPILE}
LIBRARY = $(ROOT)/lib
SDK = $(ROOT)/sdks/iPhoneOS$(SDK_OS).sdk

DIR = $(shell pwd)

# scrape the control file for variables
NAME = $(shell cat $(DIR)/control | awk 'match($$0, /^[n|N]ame:\s*(.*)$$/, arr) {print arr[1]}')
PACKAGE = $(shell cat $(DIR)/control | awk 'match($$0, /^[p|P]ackage:\s*(.*)$$/, arr) {print arr[1]}')
VERSION = $(shell cat $(DIR)/control | awk 'match($$0, /^[v|V]ersion:\s*(.*)$$/, arr) {print arr[1]}')
PLATFORM = $(shell cat $(DIR)/control | awk 'match($$0, /^[a|A]rchitecture:\s*(.*)$$/, arr) {print arr[1]}')

MKDIR = $(DIR)/.build
STAGE = $(MKDIR)/stage
STAGED_EXECUTABLE = $(STAGE)/$(INSTALL_PATH)
COUNTERS = $(MKDIR)/_

REMOTETEST = @(([ "${CLIENT}" ] || (echo "IP not defined"; $(EARLY_EXIT))) && $(SSH) "echo" > /dev/null)
BUILD_TEST = @if [ ! -f $(MKDIR)/$(NAME) ]; then echo "$(arrow)$(red)Run make first!$(end)"; fi
RERUN = $(MAKE) --no-print-directory
EARLY_EXIT = exit 1 # future insurance - in case I need to run something prior to exiting

TOOLCHAIN = $(ROOT)/toolchain/linux/iphone
TBINS = $(TOOLCHAIN)/bin

# must expand files to get working compile_commands.json
FILES := $(shell echo $(FILES))

# needed for ld to work
export PATH := $(TBINS):$(PATH)

# HALLELUJAH! *Ordering very much matters - do NOT change it
include $(MKPATH)/setup.mk
include $(MKPATH)/post.mk

include $(MKPATH)/$(LANG)/flags.mk

include $(MKPATH)/types/$(TYPE).mk
include $(MKPATH)/$(LANG)/compile.mk
