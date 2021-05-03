-include config.mak

FULL_OPENSSL_CONFIG = \
	$(OPENSSL_HOST) \
	--cross-compile-prefix=$(HOST)- \
	CC="$(CC)" \
	LDFLAGS="$(LDFLAGS)" \
	CPPFLAGS="$(CPPFLAGS)" \
	no-shared \
	no-dso \
	no-zlib 

FULL_LIBEVENT_CONFIG = \
	--prefix= \
	--host=$(HOST) \
	CC="$(HOST)-$(CC)" \
	LDFLAGS="$(LDFLAGS)" \
	CPPFLAGS="$(CPPFLAGS)" \
	--disable-shared \
	--enable-static \
	--with-pic \
	--disable-samples \
	--disable-libevent-regress \
	--disable-openssl

FULL_ZLIB_CONFIG = \
	--prefix= \
	--static

FULL_TOR_CONFIG = \
	--prefix= \
	--host=$(HOST) \
	CC="$(HOST)-$(CC)" \
	LDFLAGS="$(LDFLAGS)" \
	CPPFLAGS="$(CPPFLAGS)" \
	--disable-tool-name-check \
	--disable-gcc-hardening \
	--disable-system-torrc \
	--disable-asciidoc \
	--disable-manpage \
	--disable-html-manual \
	--with-libevent-dir=$(CURDIR) \
	--with-openssl-dir=$(CURDIR) \
	--with-zlib-dir=$(CURDIR) \
	--disable-systemd \
	--disable-lzma \
	--disable-zstd \
	--disable-seccomp \
	--disable-libscrypt \
	--enable-static-tor 

TORFILE = tor

ifeq ($(HOST), x86_64-w64-mingw32)
	TORFILE = tor.exe
endif

all: tor

install: install-tor

install-tor: | tor
	cd obj_tor && $(MAKE) DESTDIR=$(CURDIR) install
	cp $(CURDIR)/bin/$(TORFILE) $(OUTPUT)/$(TORFILE)
install-openssl: | openssl
	cd obj_openssl && $(MAKE) INSTALLTOP=$(CURDIR) OPENSSLDIR=$(CURDIR)/ssl install_sw
install-libevent: | libevent
	cd obj_libevent && $(MAKE) DESTDIR=$(CURDIR) install
install-zlib: | zlib
	cd obj_zlib && $(MAKE) DESTDIR=$(CURDIR) install

tor: obj_tor/.lc_built
openssl: obj_openssl/.lc_built
libevent: obj_libevent/.lc_built
zlib: obj_zlib/.lc_built

obj_%:
	mkdir -p $@

obj_tor/.lc_configured: | obj_tor src_tor install-zlib install-openssl install-libevent
	cd obj_tor && ../src_tor/configure $(FULL_TOR_CONFIG)
	touch $@
obj_openssl/.lc_configured: | obj_openssl src_openssl
	cd obj_openssl && ../src_openssl/Configure $(FULL_OPENSSL_CONFIG)
	touch $@
obj_libevent/.lc_configured: | obj_libevent src_libevent
	cd src_libevent && ./autogen.sh
	echo "$(FULL_LIBEVENT_CONFIG)"
	cd obj_libevent && ../src_libevent/configure $(FULL_LIBEVENT_CONFIG)
	touch $@
obj_zlib/.lc_configured: | obj_zlib src_zlib
	cd obj_zlib && CC=$(HOST)-$(CC) LDFLAGS="$(LDFLAGS)" CPPFLAGS="$(CPPFLAGS)" ../src_zlib/configure $(FULL_ZLIB_CONFIG)
	touch $@

obj_tor/.lc_built: | obj_tor/.lc_configured
	cd obj_tor && $(MAKE) all
	touch $@
obj_openssl/.lc_built: | obj_openssl/.lc_configured
	cd obj_openssl && $(MAKE) all
	touch $@
obj_libevent/.lc_built: | obj_libevent/.lc_configured
	cd obj_libevent && $(MAKE) all
	touch $@
obj_zlib/.lc_built: | obj_zlib/.lc_configured
	cd obj_zlib && $(MAKE) all
	touch $@

src_openssl: | $(OPENSSL_SRCDIR)
	ln -sf $(OPENSSL_SRCDIR) $@

src_libevent: | $(LIBEVENT_SRCDIR)
	ln -sf $(LIBEVENT_SRCDIR) $@

src_zlib: | $(ZLIB_SRCDIR)
	ln -sf $(ZLIB_SRCDIR) $@

src_tor: | $(TOR_SRCDIR)
	ln -sf $(TOR_SRCDIR) $@
