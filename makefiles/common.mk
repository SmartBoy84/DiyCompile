
# this is for stuff I just do NOT give a damn about
SHUTUP=2> /dev/null ||:

# Color escape codes
green=\033[0;32m
red=\033[0;31m
blue=\033[0;34m
end=\033[0m
arrow=$(red)=> $(end)
MUTE= 2>/dev/null; true

TARGET := $(ARCH)-apple-ios$(OS)

ROOT := ${DIYCOMPILE}
SDK := $(ROOT)/sdks/iPhoneOS$(OS).sdk

DIR := $(shell pwd)

# scrape the control file for variables
NAME := $(shell cat $(DIR)/control | awk 'match($$0, /^[n|N]ame:\s*(.*)$$/, arr) {print arr[1]}')
PACKAGE := $(shell cat $(DIR)/control | awk 'match($$0, /^[p|P]ackage:\s*(.*)$$/, arr) {print arr[1]}')
VERSION := $(shell cat $(DIR)/control | awk 'match($$0, /^[v|V]ersion:\s*(.*)$$/, arr) {print arr[1]}')
PLATFORM := $(shell cat $(DIR)/control | awk 'match($$0, /^[a|A]rchitecture:\s*(.*)$$/, arr) {print arr[1]}')

MKDIR := $(DIR)/.build
STAGE := $(MKDIR)/stage

REMOTETEST=@(([ "${IP}" ] || (echo "IP not defined"; exit 1)) && ssh root@$(IP) "echo" > /dev/null)
BUILD_TEST=	@if [ ! -f $(MKDIR)/$(NAME) ]; then echo "$(red)Run make first!$(end)"; $(RERUN) all; fi
RERUN := $(MAKE) --no-print-directory

TOOLCHAIN := $(ROOT)/toolchain/linux/iphone
TBINS := $(TOOLCHAIN)/bin

# needed for ld to work
export PATH := $(TBINS):$(PATH)