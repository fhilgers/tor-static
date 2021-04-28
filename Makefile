#!/bin/sh 
SOURCE_DIR = sources
BUILD_DIR = build

TOR_VER = 0.4.5.7
OPENSSL_VER = 1.1.1k
ZLIB_VER = 1.2.11
LIBEVENT_VER = 2.1.12
LIBCAP_VER = 2.49

LIBCAP_SITE = https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2
OPENSSL_SITE = https://www.openssl.org/source
LIBEVENT_SITE = https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT_VER)-stable
ZLIB_SITE = https://zlib.net
TOR_SITE = https://dist.torproject.org

LIBCAP = libcap-$(LIBCAP_VER)
OPENSSL = openssl-$(OPENSSL_VER)
LIBEVENT = libevent-$(LIBEVENT_VER)-stable
ZLIB = zlib-$(ZLIB_VER)
TOR = tor-$(TOR_VER)

SRC_DIRS = $(LIBCAP) $(OPENSSL) $(LIBEVENT) $(ZLIB) $(TOR)

DL_CMD = wget -c -O

OUTPUT = $(PWD)/install


all:

clean:
	rm -rf libcap-* openssl-* zlib-* libevent-* tor-*

distclean: clean
	rm -rf sources

$(SOURCE_DIR):
	mkdir -p $@

$(SOURCE_DIR)/$(TOR).tar.gz: SITE = $(TOR_SITE)
$(SOURCE_DIR)/$(LIBCAP).tar.gz: SITE = $(LIBCAP_SITE)
$(SOURCE_DIR)/$(OPENSSL).tar.gz: SITE = $(OPENSSL_SITE)
$(SOURCE_DIR)/$(LIBEVENT).tar.gz: SITE = $(LIBEVENT_SITE)
$(SOURCE_DIR)/$(ZLIB).tar.gz: SITE = $(ZLIB_SITE)

$(SOURCE_DIR)/%.tar.gz: | $(SOURCES)
	mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) $(SITE)/$(notdir $@)
	mv $@.tmp/$(notdir $@) $@
	rm -rf $@.tmp

%: $(SOURCE_DIR)/%.tar.gz | $(SOURCES)
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && tar zxvf - ) < $<
	rm -rf $@
	mv $@.tmp/$@ $@
	rm -rf $@.tmp

all: | $(SRC_DIRS)
	( cd $(LIBCAP) && $(MAKE) )
	( cd $(OPENSSL) && ./config \
				--prefix=$(OUTPUT) \
				no-shared \
				no-dso \
				no-zlib \
				&& $(MAKE) && $(MAKE) install_sw )
	( cd $(LIBEVENT) && ./configure \
				--prefix=$(OUTPUT) \
				--disable-shared \
				--enable-static \
				--with-pic \
				--disable-samples \
				--disable-libevent-regress \
				CPPFLAGS=-I$(OUTPUT)/include \
				LDFLAGS=-L$(OUTPUT)/lib \
				&& $(MAKE) && $(MAKE) install )
	( cd $(ZLIB) && ./configure \
			--prefix=$(OUTPUT) \
			--static && $(MAKE) \
			&& $(MAKE) install )
	( cd $(TOR) && ./configure \
			--prefix=$(OUTPUT) \
			--disable-gcc-hardening \
			--disable-system-torrc \
			--disable-asciidoc \
			--disable-manpage \
			--disable-html-manual \
			--with-libevent-dir=$(OUTPUT) \
			--with-openssl-dir=$(OUTPUT) \
			--with-zlib-dir=$(OUTPUT) \
			--disable-systemd \
			--disable-lzma \
			--disable-zstd \
			--disable-seccomp \
			--disable-libscrypt \
			--enable-static-tor \
			LDFLAGS=-L$(PWD)/$(LIBCAP)/libcap \
			&& $(MAKE) && $(MAKE) install )
