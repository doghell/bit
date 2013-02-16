#
#   bit-freebsd-default.mk -- Makefile to build Embedthis Bit for freebsd
#

PRODUCT         := bit
VERSION         := 0.8.1
BUILD_NUMBER    := 0
PROFILE         := default
ARCH            := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS              := freebsd
CC              := /usr/bin/gcc
LD              := /usr/bin/ld
CONFIG          := $(OS)-$(ARCH)-$(PROFILE)
LBIN            := $(CONFIG)/bin

BIT_ROOT_PREFIX       := /
BIT_BASE_PREFIX       := $(BIT_ROOT_PREFIX)/usr/local
BIT_DATA_PREFIX       := $(BIT_ROOT_PREFIX)/
BIT_STATE_PREFIX      := $(BIT_ROOT_PREFIX)/var
BIT_APP_PREFIX        := $(BIT_BASE_PREFIX)/lib/$(PRODUCT)
BIT_VAPP_PREFIX       := $(BIT_APP_PREFIX)/$(VERSION)
BIT_BIN_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/bin
BIT_INC_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/include
BIT_LIB_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/lib
BIT_MAN_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/share/man
BIT_SBIN_PREFIX       := $(BIT_ROOT_PREFIX)/usr/local/sbin
BIT_ETC_PREFIX        := $(BIT_ROOT_PREFIX)/etc/$(PRODUCT)
BIT_WEB_PREFIX        := $(BIT_ROOT_PREFIX)/var/www/$(PRODUCT)-default
BIT_LOG_PREFIX        := $(BIT_ROOT_PREFIX)/var/log/$(PRODUCT)
BIT_SPOOL_PREFIX      := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)
BIT_CACHE_PREFIX      := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)/cache
BIT_SRC_PREFIX        := $(BIT_ROOT_PREFIX)$(PRODUCT)-$(VERSION)

CFLAGS          += -fPIC  -w
DFLAGS          += -D_REENTRANT -DPIC  $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc
LDFLAGS         += '-g'
LIBPATHS        += -L$(CONFIG)/bin
LIBS            += -lpthread -lm -ldl

DEBUG           := debug
CFLAGS-debug    := -g
DFLAGS-debug    := -DBIT_DEBUG
LDFLAGS-debug   := -g
DFLAGS-release  := 
CFLAGS-release  := -O2
LDFLAGS-release := 
CFLAGS          += $(CFLAGS-$(DEBUG))
DFLAGS          += $(DFLAGS-$(DEBUG))
LDFLAGS         += $(LDFLAGS-$(DEBUG))

unexport CDPATH

all compile: prep \
        $(CONFIG)/bin/libest.so \
        $(CONFIG)/bin/ca.crt \
        $(CONFIG)/bin/libmpr.so \
        $(CONFIG)/bin/libmprssl.so \
        $(CONFIG)/bin/makerom \
        $(CONFIG)/bin/libpcre.so \
        $(CONFIG)/bin/libhttp.so \
        $(CONFIG)/bin/http \
        $(CONFIG)/bin/libejs.so \
        $(CONFIG)/bin/ejs \
        $(CONFIG)/bin/ejsc \
        $(CONFIG)/bin/ejs.mod \
        $(CONFIG)/bin/bit.es \
        $(CONFIG)/bin/bit \
        $(CONFIG)/bin/bits

.PHONY: prep

prep:
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(BIT_APP_PREFIX)" = "" ] ; then echo WARNING: BIT_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/bit-freebsd-default-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/bit-freebsd-default-bit.h >/dev/null ; then\
		echo cp projects/bit-freebsd-default-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/bit-freebsd-default-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
clean:
	rm -rf $(CONFIG)/bin/libest.so
	rm -rf $(CONFIG)/bin/ca.crt
	rm -rf $(CONFIG)/bin/libmpr.so
	rm -rf $(CONFIG)/bin/libmprssl.so
	rm -rf $(CONFIG)/bin/makerom
	rm -rf $(CONFIG)/bin/libpcre.so
	rm -rf $(CONFIG)/bin/libhttp.so
	rm -rf $(CONFIG)/bin/http
	rm -rf $(CONFIG)/bin/libejs.so
	rm -rf $(CONFIG)/bin/ejs
	rm -rf $(CONFIG)/bin/ejsc
	rm -rf $(CONFIG)/bin/ejs.mod
	rm -rf $(CONFIG)/obj/estLib.o
	rm -rf $(CONFIG)/obj/mprLib.o
	rm -rf $(CONFIG)/obj/mprSsl.o
	rm -rf $(CONFIG)/obj/manager.o
	rm -rf $(CONFIG)/obj/makerom.o
	rm -rf $(CONFIG)/obj/pcre.o
	rm -rf $(CONFIG)/obj/httpLib.o
	rm -rf $(CONFIG)/obj/http.o
	rm -rf $(CONFIG)/obj/ejsLib.o
	rm -rf $(CONFIG)/obj/ejs.o
	rm -rf $(CONFIG)/obj/ejsc.o
	rm -rf $(CONFIG)/obj/removeFiles.o
	rm -rf $(CONFIG)/obj/bit.o

clobber: clean
	rm -fr ./$(CONFIG)

$(CONFIG)/inc/est.h: 
	rm -fr $(CONFIG)/inc/est.h
	cp -r src/deps/est/est.h $(CONFIG)/inc/est.h

$(CONFIG)/inc/bitos.h: 
	rm -fr $(CONFIG)/inc/bitos.h
	cp -r src/bitos.h $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/estLib.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

$(CONFIG)/bin/libest.so: \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/obj/estLib.o
	$(CC) -shared -o $(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/estLib.o $(LIBS)

$(CONFIG)/bin/ca.crt: src/deps/est/ca.crt
	rm -fr $(CONFIG)/bin/ca.crt
	cp -r src/deps/est/ca.crt $(CONFIG)/bin/ca.crt

$(CONFIG)/inc/mpr.h: 
	rm -fr $(CONFIG)/inc/mpr.h
	cp -r src/deps/mpr/mpr.h $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/mprLib.o: \
    src/deps/mpr/mprLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/mprLib.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprLib.c

$(CONFIG)/bin/libmpr.so: \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/obj/mprLib.o
	$(CC) -shared -o $(CONFIG)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/mprLib.o $(LIBS)

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/est.h
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprSsl.c

$(CONFIG)/bin/libmprssl.so: \
    $(CONFIG)/bin/libmpr.so \
    $(CONFIG)/bin/libest.so \
    $(CONFIG)/obj/mprSsl.o
	$(CC) -shared -o $(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/mprSsl.o -lest -lmpr $(LIBS)

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/makerom.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/makerom.c

$(CONFIG)/bin/makerom: \
    $(CONFIG)/bin/libmpr.so \
    $(CONFIG)/obj/makerom.o
	$(CC) -o $(CONFIG)/bin/makerom $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o -lmpr $(LIBS) -lmpr -lpthread -lm -ldl $(LDFLAGS)

$(CONFIG)/inc/pcre.h: 
	rm -fr $(CONFIG)/inc/pcre.h
	cp -r src/deps/pcre/pcre.h $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/deps/pcre/pcre.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/pcre.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/pcre/pcre.c

$(CONFIG)/bin/libpcre.so: \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/obj/pcre.o
	$(CC) -shared -o $(CONFIG)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/pcre.o $(LIBS)

$(CONFIG)/inc/http.h: 
	rm -fr $(CONFIG)/inc/http.h
	cp -r src/deps/http/http.h $(CONFIG)/inc/http.h

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/httpLib.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/httpLib.c

$(CONFIG)/bin/libhttp.so: \
    $(CONFIG)/bin/libmpr.so \
    $(CONFIG)/bin/libpcre.so \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/obj/httpLib.o
	$(CC) -shared -o $(CONFIG)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/httpLib.o -lpcre -lmpr $(LIBS)

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/http.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/http.c

$(CONFIG)/bin/http: \
    $(CONFIG)/bin/libhttp.so \
    $(CONFIG)/obj/http.o
	$(CC) -o $(CONFIG)/bin/http $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o -lhttp $(LIBS) -lpcre -lmpr -lhttp -lpthread -lm -ldl -lpcre -lmpr $(LDFLAGS)

$(CONFIG)/inc/ejs.h: 
	rm -fr $(CONFIG)/inc/ejs.h
	cp -r src/deps/ejs/ejs.h $(CONFIG)/inc/ejs.h

$(CONFIG)/inc/ejs.slots.h: 
	rm -fr $(CONFIG)/inc/ejs.slots.h
	cp -r src/deps/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

$(CONFIG)/inc/ejsByteGoto.h: 
	rm -fr $(CONFIG)/inc/ejsByteGoto.h
	cp -r src/deps/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

$(CONFIG)/obj/ejsLib.o: \
    src/deps/ejs/ejsLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/inc/bitos.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/ejs.slots.h
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsLib.c

$(CONFIG)/bin/libejs.so: \
    $(CONFIG)/bin/libhttp.so \
    $(CONFIG)/bin/libpcre.so \
    $(CONFIG)/bin/libmpr.so \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/ejs.slots.h \
    $(CONFIG)/inc/ejsByteGoto.h \
    $(CONFIG)/obj/ejsLib.o
	$(CC) -shared -o $(CONFIG)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsLib.o -lmpr -lpcre -lhttp $(LIBS) -lpcre -lmpr

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejs.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejs.c

$(CONFIG)/bin/ejs: \
    $(CONFIG)/bin/libejs.so \
    $(CONFIG)/obj/ejs.o
	$(CC) -o $(CONFIG)/bin/ejs $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o -lejs $(LIBS) -lmpr -lpcre -lhttp -lejs -lpthread -lm -ldl -lmpr -lpcre -lhttp $(LDFLAGS)

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejsc.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsc.c

$(CONFIG)/bin/ejsc: \
    $(CONFIG)/bin/libejs.so \
    $(CONFIG)/obj/ejsc.o
	$(CC) -o $(CONFIG)/bin/ejsc $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o -lejs $(LIBS) -lmpr -lpcre -lhttp -lejs -lpthread -lm -ldl -lmpr -lpcre -lhttp $(LDFLAGS)

$(CONFIG)/bin/ejs.mod: $(CONFIG)/bin/ejsc
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es

$(CONFIG)/bin/bit.es: src/bit.es
	rm -fr $(CONFIG)/bin/bit.es
	cp -r src/bit.es $(CONFIG)/bin/bit.es

$(CONFIG)/bin/bits: 
	rm -fr ./$(CONFIG)/bin/bits
	cp -r bits ./$(CONFIG)/bin

$(CONFIG)/obj/bit.o: \
    src/bit.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/bit.o -fPIC $(LDFLAGS) $(DFLAGS) $(IFLAGS) src/bit.c

$(CONFIG)/bin/bit: \
    $(CONFIG)/bin/libmpr.so \
    $(CONFIG)/bin/libhttp.so \
    $(CONFIG)/bin/libejs.so \
    $(CONFIG)/bin/bits \
    $(CONFIG)/bin/bit.es \
    $(CONFIG)/inc/bitos.h \
    $(CONFIG)/obj/bit.o
	$(CC) -o $(CONFIG)/bin/bit $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/bit.o -lejs -lhttp -lmpr $(LIBS) -lpcre -lejs -lhttp -lmpr -lpthread -lm -ldl -lpcre $(LDFLAGS)

version: 
	@cd bits; echo 0.8.1-0 ; cd ..

_install: 
	

_uninstall: 
	rm -rf $(BIT_VAPP_PREFIX)/bin/bit $(BIT_MAN_PREFIX)/man1/bit.1 '$(BIT_APP_PREFIX)'

stop: 
	

installBinary: stop
	install -d "$(BIT_VAPP_PREFIX)/bin"
	install  "$(CONFIG)/bin/bit" "$(BIT_VAPP_PREFIX)/bin/bit"
	rm -f "$(BIT_BIN_PREFIX)/bit"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/bit" "$(BIT_BIN_PREFIX)/bit"
	install  "$(CONFIG)/bin/bit.es" "$(BIT_VAPP_PREFIX)/bin/bit.es"
	install  "$(CONFIG)/bin/ca.crt" "$(BIT_VAPP_PREFIX)/bin/ca.crt"
	install  "$(CONFIG)/bin/ca.crt" "$(BIT_VAPP_PREFIX)/bin/ca.crt"
	install  "$(CONFIG)/bin/libejs.so" "$(BIT_VAPP_PREFIX)/bin/libejs.so"
	install  "$(CONFIG)/bin/libest.so" "$(BIT_VAPP_PREFIX)/bin/libest.so"
	install  "$(CONFIG)/bin/libhttp.so" "$(BIT_VAPP_PREFIX)/bin/libhttp.so"
	install  "$(CONFIG)/bin/libmpr.so" "$(BIT_VAPP_PREFIX)/bin/libmpr.so"
	install  "$(CONFIG)/bin/libmprssl.so" "$(BIT_VAPP_PREFIX)/bin/libmprssl.so"
	install  "$(CONFIG)/bin/libpcre.so" "$(BIT_VAPP_PREFIX)/bin/libpcre.so"
	install -d "$(BIT_VAPP_PREFIX)/bin/bits"
	install  "bits/embedthis-manifest.bit" "$(BIT_VAPP_PREFIX)/bin/bits/embedthis-manifest.bit"
	install  "bits/embedthis.bit" "$(BIT_VAPP_PREFIX)/bin/bits/embedthis.bit"
	install  "bits/embedthis.es" "$(BIT_VAPP_PREFIX)/bin/bits/embedthis.es"
	install  "bits/gendoc.es" "$(BIT_VAPP_PREFIX)/bin/bits/gendoc.es"
	install  "bits/getbitvals" "$(BIT_VAPP_PREFIX)/bin/bits/getbitvals"
	install -d "$(BIT_VAPP_PREFIX)/bin/bits/os"
	install  "bits/os/freebsd.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/freebsd.bit"
	install  "bits/os/gcc.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/gcc.bit"
	install  "bits/os/linux.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/linux.bit"
	install  "bits/os/macosx.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/macosx.bit"
	install  "bits/os/posix.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/posix.bit"
	install  "bits/os/solaris.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/solaris.bit"
	install  "bits/os/vxworks.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/vxworks.bit"
	install  "bits/os/windows.bit" "$(BIT_VAPP_PREFIX)/bin/bits/os/windows.bit"
	install -d "$(BIT_VAPP_PREFIX)/bin/bits/packs"
	install  "bits/packs/compiler.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/compiler.pak"
	install  "bits/packs/doxygen.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/doxygen.pak"
	install  "bits/packs/dsi.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/dsi.pak"
	install  "bits/packs/dumpbin.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/dumpbin.pak"
	install  "bits/packs/ejs.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/ejs.pak"
	install  "bits/packs/ejscript.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/ejscript.pak"
	install  "bits/packs/est.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/est.pak"
	install  "bits/packs/http.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/http.pak"
	install  "bits/packs/lib.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/lib.pak"
	install  "bits/packs/link.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/link.pak"
	install  "bits/packs/man.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/man.pak"
	install  "bits/packs/man2html.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/man2html.pak"
	install  "bits/packs/matrixssl.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/matrixssl.pak"
	install  "bits/packs/md5.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/md5.pak"
	install  "bits/packs/mocana.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/mocana.pak"
	install  "bits/packs/openssl.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/openssl.pak"
	install  "bits/packs/pcre.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/pcre.pak"
	install  "bits/packs/pmaker.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/pmaker.pak"
	install  "bits/packs/ranlib.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/ranlib.pak"
	install  "bits/packs/rc.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/rc.pak"
	install  "bits/packs/sqlite.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/sqlite.pak"
	install  "bits/packs/ssl.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/ssl.pak"
	install  "bits/packs/strip.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/strip.pak"
	install  "bits/packs/tidy.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/tidy.pak"
	install  "bits/packs/utest.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/utest.pak"
	install  "bits/packs/vxworks.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/vxworks.pak"
	install  "bits/packs/winsdk.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/winsdk.pak"
	install  "bits/packs/zip.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/zip.pak"
	install  "bits/packs/zlib.pak" "$(BIT_VAPP_PREFIX)/bin/bits/packs/zlib.pak"
	install  "bits/sample-main.bit" "$(BIT_VAPP_PREFIX)/bin/bits/sample-main.bit"
	install  "bits/sample-start.bit" "$(BIT_VAPP_PREFIX)/bin/bits/sample-start.bit"
	install  "bits/simple.bit" "$(BIT_VAPP_PREFIX)/bin/bits/simple.bit"
	install  "bits/standard.bit" "$(BIT_VAPP_PREFIX)/bin/bits/standard.bit"
	install  "bits/vstudio.es" "$(BIT_VAPP_PREFIX)/bin/bits/vstudio.es"
	install  "bits/xcode.es" "$(BIT_VAPP_PREFIX)/bin/bits/xcode.es"
	install -d "$(BIT_VAPP_PREFIX)/doc/man/man1"
	install  "doc/man/bit.1" "$(BIT_VAPP_PREFIX)/doc/man/man1/bit.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/bit.1"
	install -d "$(BIT_MAN_PREFIX)/man1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man/man1/bit.1" "$(BIT_MAN_PREFIX)/man1/bit.1"
	rm -f "$(BIT_APP_PREFIX)/latest"
	install -d "$(BIT_APP_PREFIX)"
	ln -s "0.8.1" "$(BIT_APP_PREFIX)/latest"


start: 
	

install: stop installBinary start
	

uninstall: stop
	

