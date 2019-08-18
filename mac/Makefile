REPO ?= ..
WORKDIR ?= build
DISTDIR ?= dist
MACOSX_DEPLOYMENT_TARGET ?= 10.9
TK_VERSION ?= 8.6

TEMP_INSTALL_ROOT ?= $(realpath $(WORKDIR))/temporary_install_root

TCL_SOURCE_CODE ?= $(REPO)/thirdparty/tcl
TK_SOURCE_CODE ?= $(REPO)/thirdparty/tk
XZ_SOURCE_CODE ?= $(REPO)/thirdparty/xz
SQLITE_SOURCE_CODE ?= $(REPO)/thirdparty/sqlite
OPENSSL_SOURCE_CODE ?= $(REPO)/thirdparty/openssl
PYTHON_SOURCE_CODE ?= $(REPO)/thirdparty/cpython

export CFLAGS = -arch x86_64 -mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET)

default: build-python

$(REPO)/thirdparty/xz:
	cd $(REPO)/thirdparty && \
	curl https://tukaani.org/xz/xz-5.2.4.tar.gz --output xz.tar.gz -L && \
	tar -xvf xz.tar.gz && \
	mv xz-5.2.4 xz && \
	rm xz.tar.gz

TCL_FRAMEWORK = $(TEMP_INSTALL_ROOT)/Library/Frameworks/Tcl.framework
$(TCL_FRAMEWORK): $(TCL_SOURCE_CODE)
	cd $(TCL_SOURCE_CODE)/unix && ./configure --enable-framework --enable-threads --prefix=$(TEMP_INSTALL_ROOT) --libdir=$(TEMP_INSTALL_ROOT)/Library/Frameworks
	$(MAKE) -C $(TCL_SOURCE_CODE)/unix
	$(MAKE) -C $(TCL_SOURCE_CODE)/unix install -j1 -W html -W html-tcl -W html-tk -W install-doc

TK_FRAMEWORK = $(TEMP_INSTALL_ROOT)/Library/Frameworks/Tk.framework
$(TK_FRAMEWORK): $(TK_SOURCE_CODE)
	cd $(TK_SOURCE_CODE)/unix && ./configure --enable-framework --enable-threads --enable-aqua --prefix=$(TEMP_INSTALL_ROOT) --libdir=$(TEMP_INSTALL_ROOT)/Library/Frameworks
	$(MAKE) -C $(TK_SOURCE_CODE)/unix
	$(MAKE) -C $(TK_SOURCE_CODE)/unix install -j1 -W html -W html-tcl -W html-tk -W install-doc

XZ_LIBRARY = $(TEMP_INSTALL_ROOT)/usr/local/lib/liblzma.la
$(XZ_LIBRARY): $(XZ_SOURCE_CODE)
	cd $(XZ_SOURCE_CODE) && ./configure --disable-shared --enable-static --disable-dependency-tracking
	$(MAKE) -C $(XZ_SOURCE_CODE) install DESTDIR="$(TEMP_INSTALL_ROOT)"
	
SQLITE_LIBRARY = $(TEMP_INSTALL_ROOT)/usr/local/lib/libsqlite3.a
$(SQLITE_LIBRARY): $(SQLITE_SOURCE_CODE)
	cd $(SQLITE_SOURCE_CODE) && \
	  export CFLAGS="$(CFLAGS) -Os -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_TCL=0" && \
	  ./configure --enable-threadsafe --enable-shared=no --enable-static=yes --disable-readline --disable-dependency-tracking
	$(MAKE) -C $(SQLITE_SOURCE_CODE) install DESTDIR="$(TEMP_INSTALL_ROOT)"

OPENSSL_LIBRARY = $(TEMP_INSTALL_ROOT)/usr/local/lib/pkgconfig/openssl.pc
$(OPENSSL_LIBRARY): $(OPENSSL_SOURCE_CODE)
	cd $(OPENSSL_SOURCE_CODE) && perl Configure darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 no-shared
	$(MAKE) -C $(OPENSSL_SOURCE_CODE) install_sw DESTDIR="$(TEMP_INSTALL_ROOT)" -j1

PYTHON_FRAMEWORK = $(TEMP_INSTALL_ROOT)/Library/Frameworks/Python.framework
$(PYTHON_FRAMEWORK): $(PYTHON_SOURCE_CODE) $(TK_FRAMEWORK) $(TCL_FRAMEWORK) $(XZ_LIBRARY) $(SQLITE_LIBRARY) $(OPENSSL_LIBRARY)
	cd $(PYTHON_SOURCE_CODE) && \
	    ./configure -C --enable-framework=$(TEMP_INSTALL_ROOT)/Library/Frameworks --enable-universalsdk=/ \
		--with-universal-archs=intel-64 --with-computed-gotos --without-ensurepip \
		--with-tcltk-includes="-I$(TCL_FRAMEWORK)/Headers -I$(TCL_FRAMEWORK)/PrivateHeaders -I$(TK_FRAMEWORK)/Headers -I$(TK_FRAMEWORK)/PrivateHeaders" \
		--with-tcltk-libs="-framework Tcl -framework Tk -F$(TEMP_INSTALL_ROOT)/Library/Frameworks" \
		--with-openssl=$(TEMP_INSTALL_ROOT)/usr/local \
		LDFLAGS="-g -L$(TEMP_INSTALL_ROOT)/usr/local/lib" \
		CFLAGS="-g -I$(TEMP_INSTALL_ROOT)/usr/local/include"
	$(MAKE) -C $(PYTHON_SOURCE_CODE)
	$(MAKE) -C $(PYTHON_SOURCE_CODE) -j1 install
	$(MAKE) -C $(PYTHON_SOURCE_CODE) -j1 frameworkinstallextras

build-tk: $(TCL_FRAMEWORK) $(TK_FRAMEWORK)
build-xz: $(XZ_LIBRARY)
build-sqlite: $(SQLITE_LIBRARY)
build-openssl: $(OPENSSL_LIBRARY)
build-python: $(PYTHON_FRAMEWORK)

clean: clean-tk clean-xz clean-sqlite clean-openssl clean-python
	rm -rf $(TEMP_INSTALL_ROOT)
clean-tk:
	$(MAKE) -C $(TCL_SOURCE_CODE)/unix clean || true
	$(MAKE) -C $(TK_SOURCE_CODE)/unix clean || true
clean-xz:
	$(MAKE) -C $(TK_SOURCE_CODE)/xz clean || true
clean-sqlite:
	$(MAKE) -C $(SQLITE_SOURCE_CODE) clean || true
clean-openssl:
	$(MAKE) -C $(OPENSSL_SOURCE_CODE) clean || true
clean-python:
	$(MAKE) -C $(PYTHON_SOURCE_CODE) clean || true
	$(MAKE) -C $(PYTHON_SOURCE_CODE) distclean || true
	
.PHONY: build-tk build-xz build-sqlite build-openssl build-python
.PHONY: clean clean-tk clean-xz clean-sqlite clean-openssl clean-python
.PHONY: default