#!/bin/sh 
OUTPUT = $(CURDIR)/output
SOURCE_DIR = sources


TOR_VER = 0.4.5.7
OPENSSL_VER = 1.1.1k
ZLIB_VER = 1.2.11
LIBEVENT_VER = 2.1.12

OPENSSL_SITE = https://www.openssl.org/source
LIBEVENT_SITE = https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT_VER)-stable
ZLIB_SITE = https://zlib.net
TOR_SITE = https://dist.torproject.org
MUSL_SITE = https://musl.cc

OPENSSL = openssl-$(OPENSSL_VER)
LIBEVENT = libevent-$(LIBEVENT_VER)-stable
ZLIB = zlib-$(ZLIB_VER)
TOR = tor-$(TOR_VER)

DL_CMD = wget -c -O


ifeq ($(TARGET),x86_64-linux)
	MUSL = x86_64-linux-musl-cross
	HOST = x86_64-linux-musl
	OPENSSL_HOST = linux-x86_64
endif

ifeq ($(TARGET),x86_64-windows)
	MUSL = x86_64-w64-mingw32-cross
	HOST = x86_64-w64-mingw32
	OPENSSL_HOST = mingw64
endif

SRC_DIRS = $(OPENSSL) $(LIBEVENT) $(ZLIB) $(MUSL) $(TOR)

BUILD_DIR = build/$(HOST)

all:

clean:
	rm -rf libcap-* openssl-* zlib-* libevent-* tor-* build x86_64*

distclean: clean
	rm -rf sources

$(SOURCE_DIR):
	mkdir -p $@

$(SOURCE_DIR)/$(MUSL).tgz: SITE = $(MUSL_SITE)
$(SOURCE_DIR)/$(TOR).tar.gz: SITE = $(TOR_SITE)
$(SOURCE_DIR)/$(OPENSSL).tar.gz: SITE = $(OPENSSL_SITE)
$(SOURCE_DIR)/$(LIBEVENT).tar.gz: SITE = $(LIBEVENT_SITE)
$(SOURCE_DIR)/$(ZLIB).tar.gz: SITE = $(ZLIB_SITE)


$(SOURCE_DIR)/%: | $(SOURCES)
	mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) $(SITE)/$(notdir $@)
	mv $@.tmp/$(notdir $@) $@
	rm -rf $@.tmp

%: $(SOURCE_DIR)/%.tar.gz | $(SOURCES)
	case "$@" in */*) exit 1 ;; esac
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && tar zxvf - ) < $<
	rm -rf $@
	mv $@.tmp/$@ $@
	rm -rf $@.tmp

%: $(SOURCE_DIR)/%.tgz | $(SOURCES)
	case "$@" in */*) exit 1 ;; esac
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && tar zxvf - ) < $<
	rm -rf $@
	mv $@.tmp/$@ $@
	rm -rf $@.tmp

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/Makefile: | $(BUILD_DIR)
	ln -sf ../../cross/Makefile $@

$(BUILD_DIR)/config.mak: | $(BUILD_DIR)
	printf >$@ '%s\n' \
		"HOST = $(HOST)" \
		"OPENSSL_HOST = $(OPENSSL_HOST)" \
		"OPENSSL_SRCDIR = ../../$(OPENSSL)" \
		"LIBEVENT_SRCDIR = ../../$(LIBEVENT)" \
		"ZLIB_SRCDIR = ../../$(ZLIB)" \
		"TOR_SRCDIR = ../../$(TOR)" \
		"LDFLAGS = -L$(PWD)/$(MUSL)/$(HOST)/lib -L$(PWD)/$(MUSL)/lib" \
		"CPPFLAGS = -I$(PWD)/$(MUSL)/$(HOST)/include -I$(PWD)/$(MUSL)/include" \


all: | $(SRC_DIRS) $(BUILD_DIR) $(BUILD_DIR)/Makefile $(BUILD_DIR)/config.mak
	cd $(BUILD_DIR) && PATH=$(CURDIR)/$(MUSL)/$(HOST)/bin:$(CURDIR)/$(MUSL)/bin:$(PATH) $(MAKE) $@

install: | $(SRC_DIRS) $(BUILD_DIR) $(BUILD_DIR)/Makefile $(BUILD_DIR)/config.mak
	mkdir -p $(OUTPUT)
	cd $(BUILD_DIR) && $(MAKE) OUTPUT=$(OUTPUT) $@



.PHONY: all
