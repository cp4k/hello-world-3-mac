REPO ?= ..
WORKDIR ?= build
DISTDIR ?= dist
MACOSX_DEPLOYMENT_TARGET ?= 10.12
TK_VERSION ?= 8.6

TEMP_INSTALL_ROOT ?= $(abspath $(WORKDIR))/temporary_install_root
APP ?= $(DISTDIR)/HelloWorld3.app

TCL_SOURCE_CODE ?= $(REPO)/thirdparty/tcl
TK_SOURCE_CODE ?= $(REPO)/thirdparty/tk
XZ_SOURCE_CODE ?= $(REPO)/thirdparty/xz
SQLITE_SOURCE_CODE ?= $(REPO)/thirdparty/sqlite
OPENSSL_SOURCE_CODE ?= $(REPO)/thirdparty/openssl
PYTHON_SOURCE_CODE ?= $(REPO)/thirdparty/cpython
QT_SOURCE_CODE ?= $(REPO)/thirdparty/qt5
SIP_SOURCE_CODE ?= $(REPO)/thirdparty/sip
PYQT_SOURCE_CODE ?= $(REPO)/thirdparty/pyqt

export CFLAGS = -arch x86_64 -mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET) -O2

default: build-app

$(REPO)/thirdparty/xz:
	cd $(REPO)/thirdparty && \
	curl https://tukaani.org/xz/xz-5.2.4.tar.gz --output xz.tar.gz -L && \
	echo 'b512f3b726d3b37b6dc4c8570e137b9311e7552e8ccbab4d39d47ce5f4177145  xz.tar.gz' | shasum -a 256 -c && \
	tar -xvf xz.tar.gz && \
	mv xz-5.2.4 xz && \
	rm xz.tar.gz

$(REPO)/thirdparty/sip:
	cd $(REPO)/thirdparty && \
	curl https://www.riverbankcomputing.com/static/Downloads/sip/4.19.18/sip-4.19.18.tar.gz --output sip.tar.gz -L && \
	echo 'c0bd863800ed9b15dcad477c4017cdb73fa805c25908b0240564add74d697e1e  sip.tar.gz' | shasum -a 256 -c && \
	tar -xvf sip.tar.gz && \
	mv sip-4.19.18 sip && \
	rm sip.tar.gz
	
$(REPO)/thirdparty/pyqt:
	cd $(REPO)/thirdparty && \
	curl https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.13.0/PyQt5_gpl-5.13.0.tar.gz --output pyqt.tar.gz -L && \
	echo '0cdbffe5135926527b61cc3692dd301cd0328dd87eeaf1313e610787c46faff9  pyqt.tar.gz' | shasum -a 256 -c && \
	tar -xvf pyqt.tar.gz && \
	mv PyQt5_gpl-5.13.0 pyqt && \
	rm pyqt.tar.gz

TCL_FRAMEWORK = $(TEMP_INSTALL_ROOT)/Library/Frameworks/Tcl.framework
$(TCL_FRAMEWORK): $(TCL_SOURCE_CODE)
	cd $(TCL_SOURCE_CODE)/unix && ./configure --enable-framework --enable-threads --prefix=$(TEMP_INSTALL_ROOT) --libdir=$(TEMP_INSTALL_ROOT)/Library/Frameworks
	$(MAKE) -C $(TCL_SOURCE_CODE)/unix
	$(MAKE) -C $(TCL_SOURCE_CODE)/unix install -j1 -W html -W html-tcl -W html-tk -W install-doc

TK_FRAMEWORK = $(TEMP_INSTALL_ROOT)/Library/Frameworks/Tk.framework
$(TK_FRAMEWORK): $(TK_SOURCE_CODE) $(TCL_FRAMEWORK)
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
	ditto $(TEMP_INSTALL_ROOT)/Applications/*/IDLE.app $(TEMP_INSTALL_ROOT)/Applications/IDLE.app

QMAKE = $(TEMP_INSTALL_ROOT)/bin/qmake
$(QMAKE): $(QT_SOURCE_CODE)
	cd $(QT_SOURCE_CODE) && \
		./configure -prefix $(TEMP_INSTALL_ROOT) -release -opensource -confirm-license \
		-system-zlib -qt-libjpeg -qt-libpng -qt-freetype -qt-pcre -qt-harfbuzz \
		-nomake examples -nomake tests -skip qt3d -skip qtdeclarative \
		-skip qtquickcontrols -skip qtquickcontrols2 -skip qtwebengine \
		-skip qtsensors -skip qtwebview -skip qt3d -skip qtcanvas3d -skip qtdatavis3d \
		-skip qtscript -skip qtpurchasing -skip qtcharts -skip qtlottie -skip qtconnectivity
	$(MAKE) -C $(QT_SOURCE_CODE)
	$(MAKE) -C $(QT_SOURCE_CODE) -j1 install

SIP = $(PYTHON_FRAMEWORK)/Versions/Current/bin/sip
$(SIP): $(SIP_SOURCE_CODE) $(PYTHON_FRAMEWORK)
	cd $(SIP_SOURCE_CODE) && \
		$(PYTHON_FRAMEWORK)/Versions/Current/bin/python3 configure.py --arch x86_64 \
		--deployment-target $(MACOSX_DEPLOYMENT_TARGET) --sip-module PyQt5.sip
	$(MAKE) -C $(SIP_SOURCE_CODE)
	$(MAKE) -C $(SIP_SOURCE_CODE) -j1 install

PYQT_MODULE = $(PYTHON_FRAMEWORK)/Versions/Current/share/sip/PyQt5
$(PYQT_MODULE): $(PYQT_SOURCE_CODE) $(SIP) $(PYTHON_FRAMEWORK) $(QMAKE)
	cd $(PYQT_SOURCE_CODE) && \
	    $(PYTHON_FRAMEWORK)/Versions/Current/bin/python3 configure.py --confirm-license \
		 --no-qml-plugin --sip $(SIP) --qmake $(QMAKE) # TODO --qtconf-prefix
	$(MAKE) -C $(PYQT_SOURCE_CODE)
	$(MAKE) -C $(PYQT_SOURCE_CODE) -j1 install

$(APP)/Contents/%: app/%
	mkdir -p $(@D) && cp $< $@

$(APP)/Contents/%.nib: app/%.xib
	mkdir -p $(@D) && ibtool --compile $@ $<

$(APP)/Contents/MacOS/Launcheroni: app/main.m
	mkdir -p $(@D) && $(CC) $(CFLAGS) -fobjc-arc -framework Cocoa $< -o $@

$(APP)/Contents/MacOS/%.app: $(TEMP_INSTALL_ROOT)/Applications/%.app
	./copy_bundle.py $< $@ $(TEMP_INSTALL_ROOT)/Library/Frameworks $(APP)/Contents/Frameworks
$(APP)/Contents/Frameworks/%.framework: $(TEMP_INSTALL_ROOT)/Library/Frameworks/%.framework
	./copy_bundle.py $< $@ $(TEMP_INSTALL_ROOT)/Library/Frameworks $(APP)/Contents/Frameworks
$(APP)/Contents/MacOS/%.app: $(TEMP_INSTALL_ROOT)/bin/%.app
	ditto $< $@
$(APP)/Contents/Frameworks/%.framework: $(TEMP_INSTALL_ROOT)/lib/%.framework
	ditto $< $@

IDLE_APP=$(APP)/Contents/MacOS/IDLE.app
$(IDLE_APP)/Contents/%: idle_app/%
	mkdir -p $(@D) && cp $< $@

$(IDLE_APP)/Contents/MacOS/%: idle_app/%.c
	mkdir -p $(@D) && $(CC) $(CFLAGS) $< -o $@

$(IDLE_APP): $(IDLE_APP)/Contents/Info.plist $(IDLE_APP)/Contents/Resources/IDLE.icns \
	$(IDLE_APP)/Contents/Resources/PythonCompiled.icns $(IDLE_APP)/Contents/Resources/PythonSource.icns \
	$(IDLE_APP)/Contents/MacOS/IDLE

APP_IMAGES = $(addsuffix .png,$(addprefix $(APP)/Contents/Resources/,IDLE Designer Terminal IDLE@2x Designer@2x Terminal@2x))
$(APP): $(APP)/Contents/Info.plist $(APP)/Contents/MacOS/Launcheroni $(APP)/Contents/Resources/AppIcon.icns $(APP_IMAGES) \
	$(APP)/Contents/Resources/setup_environment.sh $(APP)/Contents/Resources/Base.lproj/MainMenu.nib \
	$(PYTHON_FRAMEWORK) $(APP)/Contents/Frameworks/Tcl.framework $(APP)/Contents/Frameworks/Tk.framework \
	$(APP)/Contents/MacOS/IDLE.app
	./copy_bundle.py $(TEMP_INSTALL_ROOT)/Library/Frameworks/Python.framework $(APP)/Contents/Frameworks/Python.framework $(TEMP_INSTALL_ROOT)/Library/Frameworks $(APP)/Contents/Frameworks

build-tk: $(TCL_FRAMEWORK) $(TK_FRAMEWORK)
build-xz: $(XZ_LIBRARY)
build-sqlite: $(SQLITE_LIBRARY)
build-openssl: $(OPENSSL_LIBRARY)
build-python: $(PYTHON_FRAMEWORK)
build-qt: $(QMAKE)
build-sip: $(SIP)
build-pyqt: $(PYQT_MODULE)
build-app: $(APP)
build-idle: $(IDLE_APP)

clean: clean-tk clean-xz clean-sqlite clean-openssl clean-python clean-qt clean-sip clean-pyqt
	rm -rf $(TEMP_INSTALL_ROOT)
	rm -rf $(APP)
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
clean-qt:
	# Qt's `make clean` takes FOREVER!
	cd $(QT_SOURCE_CODE) && git clean -xfd && git submodule foreach --recursive git clean -xfd
clean-sip:
	$(MAKE) -C $(SIP_SOURCE_CODE) clean || true
clean-pyqt:
	$(MAKE) -C $(PYQT_SOURCE_CODE) clean || true
	
.PHONY: build-tk build-xz build-sqlite build-openssl build-python build-qt build-sip build-pyqt build-idle build-app
.PHONY: clean clean-tk clean-xz clean-sqlite clean-openssl clean-python clean-qt clean-sip clean-pyqt
.PHONY: default
