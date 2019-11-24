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
SDL_SOURCE_CODE ?= $(REPO)/thirdparty/sdl
SDL_IMAGE_SOURCE_CODE ?= $(REPO)/thirdparty/sdl_image
SDL_MIXER_SOURCE_CODE ?= $(REPO)/thirdparty/sdl_mixer
SDL_TTF_SOURCE_CODE ?= $(REPO)/thirdparty/sdl_ttf
SETUPTOOLS_SOURCE_CODE ?= $(REPO)/thirdparty/setuptools
PYGAME_SOURCE_CODE ?= $(REPO)/thirdparty/pygame
EASYGUI_SOURCE_CODE ?= $(REPO)/thirdparty/easygui
LIBTELNET_SOURCE_CODE ?= $(REPO)/thirdparty/libtelnet
REMOTE_CMDS_SOURCE_CODE ?= $(REPO)/thirdparty/remote_cmds

export CFLAGS = -arch x86_64 -mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET) -O2

default: $(APP)
	
%: %.dl.txt scripts/dl.sh
	cat $< | xargs scripts/dl.sh $<

TCL_FRAMEWORK = $(TEMP_INSTALL_ROOT)/Library/Frameworks/Tcl.framework
$(TCL_FRAMEWORK): $(TCL_SOURCE_CODE)
	mkdir -p $(TEMP_INSTALL_ROOT)
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
	mkdir -p $(TEMP_INSTALL_ROOT)
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

QMAKE = $(TEMP_INSTALL_ROOT)/bin/qmake
QT_FRAMEWORK_NAMES = $(addsuffix .framework,QtConcurrent QtCore QtDesigner QtDesignerComponents QtGui QtHelp QtMacExtras QtNetwork QtOpenGL QtPrintSupport QtPublishSubscribe QtSql QtSvg QtTest QtTextToSpeech QtUiPlugin QtWidgets QtXml)
QT_FRAMEWORKS_INSTALLROOT = $(addprefix $(TEMP_INSTALL_ROOT)/lib/,$(QT_FRAMEWORK_NAMES))
QT_FRAMEWORKS_APP = $(addprefix $(APP)/Contents/Frameworks/,$(QT_FRAMEWORK_NAMES))
QT_PLUGINS = $(TEMP_INSTALL_ROOT)/plugins
QT_DESIGNER = $(TEMP_INSTALL_ROOT)/bin/Designer.app
$(QMAKE) $(QT_FRAMEWORKS_INSTALLROOT) $(QT_PLUGINS) $(QT_DESIGNER): $(QT_SOURCE_CODE)
	cd $(QT_SOURCE_CODE) && \
		./configure -prefix $(TEMP_INSTALL_ROOT) -release -opensource -confirm-license \
		-system-zlib -qt-libjpeg -qt-libpng -qt-freetype -qt-pcre -qt-harfbuzz \
		-nomake examples -nomake tests -no-dbus -skip qt3d \
		-skip qtdeclarative -skip qtquickcontrols -skip qtquickcontrols2 -skip qtwebengine \
		-skip qtsensors -skip qtwebview -skip qt3d -skip qtcanvas3d -skip qtdatavis3d \
		-skip qtscript -skip qtpurchasing -skip qtcharts -skip qtlottie -skip qtconnectivity \
		-skip qtgamepad -skip qtmultimedia -skip qtnetworkauth -skip qtlocation \
		-skip qtremoteobjects -skip qtserialbus -skip qtserialport -skip qtwebchannel \
		-skip qtwebsockets -skip qtxmlpatterns \
		-no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci \
		-no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 \
		-no-sql-tds
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
		 --no-qml-plugin --sip $(SIP) --qmake $(QMAKE)
	$(MAKE) -C $(PYQT_SOURCE_CODE)
	$(MAKE) -C $(PYQT_SOURCE_CODE) -j1 install


SDL_LIBRARY = $(TEMP_INSTALL_ROOT)/lib/libSDL2-2.0.0.dylib
SDL_CONFIG = $(TEMP_INSTALL_ROOT)/bin/sdl2-config
$(SDL_LIBRARY) $(SDL_CONFIG): $(SDL_SOURCE_CODE)
	cd $(SDL_SOURCE_CODE) && \
		./configure --disable-static --enable-shared --enable-rpath --disable-video-x11 --prefix=$(TEMP_INSTALL_ROOT)
	$(MAKE) -C $(SDL_SOURCE_CODE)
	$(MAKE) -C $(SDL_SOURCE_CODE) -j1 install
	
SDL_IMAGE_LIBRARY = $(TEMP_INSTALL_ROOT)/lib/libSDL2_image-2.0.0.dylib
SDL_IMAGE_SOURCE_ABS = $(abspath $(SDL_IMAGE_SOURCE_CODE))
$(SDL_IMAGE_LIBRARY): $(SDL_IMAGE_SOURCE_CODE) $(SDL_LIBRARY)
	cd $(SDL_IMAGE_SOURCE_CODE)/external/zlib-*/ && \
		./configure --static --64 --prefix=$(TEMP_INSTALL_ROOT)
	$(MAKE) -C $(SDL_IMAGE_SOURCE_CODE)/external/zlib-*/
	$(MAKE) -C $(SDL_IMAGE_SOURCE_CODE)/external/zlib-*/ -j1 install
	set -e; for library in jpeg libpng; do \
		cd $(SDL_IMAGE_SOURCE_ABS)/external/$${library}-*/ && \
			./configure --disable-shared --enable-static --prefix=$(TEMP_INSTALL_ROOT); \
		$(MAKE) -C $(SDL_IMAGE_SOURCE_ABS)/external/$${library}-*/; \
		$(MAKE) -C $(SDL_IMAGE_SOURCE_ABS)/external/$${library}-*/ -j1 install; \
	done
	cd $(SDL_IMAGE_SOURCE_CODE) && \
		./configure --disable-static --enable-shared --disable-jpg-shared --disable-png-shared --disable-tif-shared --disable-webp-shared --prefix=$(TEMP_INSTALL_ROOT)
	$(MAKE) -C $(SDL_IMAGE_SOURCE_CODE)
	$(MAKE) -C $(SDL_IMAGE_SOURCE_CODE) -j1 install

SDL_TTF_LIBRARY = $(TEMP_INSTALL_ROOT)/lib/libSDL2_ttf-2.0.0.dylib
$(SDL_TTF_LIBRARY) $(FREETYPE_CONFIG): $(SDL_TTF_SOURCE_CODE) $(SDL_LIBRARY)
	cd $(SDL_TTF_SOURCE_CODE)/external/freetype*/ && \
		./configure --disable-shared --enable-static --enable-freetype-config --with-bzip2=no --with-zlib=no --prefix=$(TEMP_INSTALL_ROOT)
	$(MAKE) -C $(SDL_TTF_SOURCE_CODE)/external/freetype-*/
	$(MAKE) -C $(SDL_TTF_SOURCE_CODE)/external/freetype-*/ -j1 install
	cd $(SDL_TTF_SOURCE_CODE) && \
		FT2_CONFIG=$(TEMP_INSTALL_ROOT)/bin/freetype-config ./configure --disable-static --enable-shared --prefix=$(TEMP_INSTALL_ROOT)
	$(MAKE) -C $(SDL_TTF_SOURCE_CODE)
	$(MAKE) -C $(SDL_TTF_SOURCE_CODE) -j1 install

SDL_MIXER_LIBRARY = $(TEMP_INSTALL_ROOT)/lib/libSDL2_mixer-2.0.0.dylib
SDL_MIXER_SOURCE_ABS = $(abspath $(SDL_MIXER_SOURCE_CODE))
$(SDL_MIXER_LIBRARY): $(SDL_MIXER_SOURCE_CODE) $(SDL_LIBRARY)
	set -e; for library in flac libmodplug mpg123 libogg libvorbis ; do \
		cd $(SDL_MIXER_SOURCE_ABS)/external/$${library}-*/ && \
			./configure --disable-shared --enable-static --prefix=$(TEMP_INSTALL_ROOT); \
		$(MAKE) -C $(SDL_MIXER_SOURCE_ABS)/external/$${library}-*/; \
		$(MAKE) -C $(SDL_MIXER_SOURCE_ABS)/external/$${library}-*/ -j1 install; \
	done
	cd $(SDL_MIXER_SOURCE_CODE) && \
		 CPPFLAGS=-I$(TEMP_INSTALL_ROOT)/include LDFLAGS=-L$(TEMP_INSTALL_ROOT)/lib \
		 ./configure --disable-static --enable-shared --prefix=$(TEMP_INSTALL_ROOT) \
		 	--disable-music-mp3-mpg123-shared --disable-music-ogg-shared --disable-music-flac-shared --disable-music-mod-modplug-shared --disable-music-opus-shared
	CPPFLAGS=-I$(TEMP_INSTALL_ROOT)/include LDFLAGS=-L$(TEMP_INSTALL_ROOT)/lib $(MAKE) -C $(SDL_MIXER_SOURCE_CODE)
	$(MAKE) -C $(SDL_MIXER_SOURCE_CODE) -j1 install

SETUPTOOLS_MODULE = $(PYTHON_FRAMEWORK)/Versions/3.7/lib/python3.7/site-packages/setuptools.pth
$(SETUPTOOLS_MODULE): $(SETUPTOOLS_SOURCE_CODE) $(PYTHON_FRAMEWORK)
	cd $(SETUPTOOLS_SOURCE_CODE) && $(PYTHON_FRAMEWORK)/Versions/Current/bin/python3 bootstrap.py
	cd $(SETUPTOOLS_SOURCE_CODE) && $(PYTHON_FRAMEWORK)/Versions/Current/bin/python3 setup.py install

PYGAME_MODULE = $(TEMP_INSTALL_ROOT)/pygame-built
$(PYGAME_MODULE): $(PYGAME_SOURCE_CODE) Pygame-Setup $(SDL_LIBRARY) $(SDL_IMAGE_LIBRARY) $(SDL_MIXER_LIBRARY) $(SDL_TTF_LIBRARY) $(SETUPTOOLS_MODULE)
	sed s~TEMP_INSTALL_ROOT~$(TEMP_INSTALL_ROOT)~g Pygame-Setup > $(PYGAME_SOURCE_CODE)/Setup
	cd $(PYGAME_SOURCE_CODE) && $(PYTHON_FRAMEWORK)/Versions/Current/bin/python3 setup.py install
	touch $(PYGAME_MODULE)

EASYGUI_MODULE = $(TEMP_INSTALL_ROOT)/easygui-built
$(EASYGUI_MODULE): $(EASYGUI_SOURCE_CODE) $(SETUPTOOLS_MODULE)
	cd $(EASYGUI_SOURCE_CODE) && $(PYTHON_FRAMEWORK)/Versions/Current/bin/python3 setup.py install
	touch $(EASYGUI_MODULE)

LIBTELNET_LIBRARY = $(TEMP_INSTALL_ROOT)/lib/libtelnet.a
$(LIBTELNET_LIBRARY): $(LIBTELNET_SOURCE_CODE)
	cd $(LIBTELNET_SOURCE_CODE) && xcodebuild SYMROOT=build -arch x86_64
	mkdir -p $(TEMP_INSTALL_ROOT)/lib
	mkdir -p $(TEMP_INSTALL_ROOT)/include
	cp $(LIBTELNET_SOURCE_CODE)/build/Release/libtelnet.a $(TEMP_INSTALL_ROOT)/lib/libtelnet.a
	cp -r $(LIBTELNET_SOURCE_CODE)/build/Release/usr/local/include/libtelnet $(TEMP_INSTALL_ROOT)/include/libtelnet

TELNET_BINARY = $(TEMP_INSTALL_ROOT)/bin/telnet
$(TELNET_BINARY): $(REMOTE_CMDS_SOURCE_CODE) $(LIBTELNET_LIBRARY)
	mkdir -p $(REMOTE_CMDS_SOURCE_CODE)/build/Intermediates/telnet
	mkdir -p $(REMOTE_CMDS_SOURCE_CODE)/build/Products
	$(MAKE) -C $(REMOTE_CMDS_SOURCE_CODE)/telnet.tproj OBJROOT=../build/Intermediates \
		SYMROOT=../build/Products DSTROOT=../build/Archive \
		SDKROOT=`xcrun --sdk macosx --show-sdk-path` \
		CFLAGS="$(CFLAGS) -isystem$(TEMP_INSTALL_ROOT)/include -fPIE -D__FBSDID=__RCSID -DTERMCAP -DKLUDGELINEMODE -DUSE_TERMIO -DENV_HACK -DAUTHENTICATION -DKRB5 -DSKEY -DIPSEC -DINET6 -DFORWARD" \
		LDFLAGS="$(LDFLAGS) -arch x86_64 -L$(TEMP_INSTALL_ROOT)/lib -lcurses -lkrb4 -lkrb5 -lipsec -ltelnet"
	mkdir -p $(TEMP_INSTALL_ROOT)/bin
	cp $(REMOTE_CMDS_SOURCE_CODE)/build/Products/telnet $(TEMP_INSTALL_ROOT)/bin/telnet

$(APP)/Contents/%: app/%
	mkdir -p $(@D) && cp $< $@

$(APP)/Contents/%.nib: app/%.xib
	mkdir -p $(@D) && ibtool --compile $@ $<

$(APP)/Contents/MacOS/%: app/%.m
	mkdir -p $(@D) && $(CC) $(CFLAGS) -fobjc-arc -framework Cocoa $< -o $@
$(APP)/Contents/MacOS/%: app/%.c
	mkdir -p $(@D) && $(CC) $(CFLAGS) $< -o $@


$(APP)/Contents/Frameworks/%.framework: $(TEMP_INSTALL_ROOT)/Library/Frameworks/%.framework
	./copy_bundle.py $< $@ $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/Library/Frameworks $(TEMP_INSTALL_ROOT)/lib
$(APP)/Contents/Frameworks/%.framework: $(TEMP_INSTALL_ROOT)/lib/%.framework
	./copy_bundle.py $< $@ $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/Library/Frameworks $(TEMP_INSTALL_ROOT)/lib
$(APP)/Contents/Frameworks/%.framework: $(TEMP_INSTALL_ROOT)/lib/%.framework
	./copy_bundle.py $< $@ $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/Library/Frameworks $(TEMP_INSTALL_ROOT)/lib
$(APP)/Contents/Frameworks/%.dylib: $(TEMP_INSTALL_ROOT)/lib/%.dylib
	./copy_bundle.py $< $@ $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/lib
$(APP)/Contents/MacOS/%: $(TEMP_INSTALL_ROOT)/bin/%
	./copy_bundle.py $< $@ $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/lib
$(APP)/Contents/MacOS/%.app: $(TEMP_INSTALL_ROOT)/bin/%.app qt.conf
	./copy_bundle.py $< $@ $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/Library/Frameworks $(TEMP_INSTALL_ROOT)/lib
	mkdir -p $@/Contents/Resources
	cp qt.conf $@/Contents/Resources/

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
	$(PYQT_MODULE) $(APP)/Contents/Frameworks/Tcl.framework $(APP)/Contents/Frameworks/Tk.framework \
	$(APP)/Contents/MacOS/IDLE.app $(APP)/Contents/MacOS/Designer.app $(QT_FRAMEWORKS_APP) $(QT_PLUGINS) \
	$(APP)/Contents/Frameworks/libSDL2-2.0.0.dylib $(APP)/Contents/Frameworks/libSDL2_image-2.0.0.dylib \
	$(APP)/Contents/Frameworks/libSDL2_mixer-2.0.0.dylib $(APP)/Contents/Frameworks/libSDL2_ttf-2.0.0.dylib \
	$(PYGAME_MODULE) $(EASYGUI_MODULE) $(APP)/Contents/MacOS/python $(APP)/Contents/MacOS/python3 \
	$(APP)/Contents/MacOS/telnet
	# Need to copy Python.framework in this step, not using the rules above, so we
	# know Tk/Qt/etc have been properly installed into them.
	./copy_bundle.py $(TEMP_INSTALL_ROOT)/Library/Frameworks/Python.framework $(APP)/Contents/Frameworks/Python.framework $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/Library/Frameworks $(TEMP_INSTALL_ROOT)/lib
	./copy_bundle.py $(QT_PLUGINS) $(APP)/Contents/PlugIns $(APP)/Contents/Frameworks $(TEMP_INSTALL_ROOT)/Library/Frameworks


clean-%: $(REPO)/thirdparty/%/.git
	cd $(REPO)/thirdparty/$* && git clean -xfd && git submodule foreach --recursive git clean -xfd

clean-%: $(REPO)/thirdparty/%.dl.txt
	rm -rf $(REPO)/thirdparty/$*/

clean-python: clean-cpython
clean-telnet: clean-libtelnet clean-remote_cmds

clean: clean-python clean-easygui clean-telnet clean-openssl clean-pygame clean-pyqt clean-qt5 clean-sdl_image clean-sdl_mixer clean-sdl_ttf clean-setuptools clean-sip clean-sqlite clean-tcl clean-tk clean-xz
	rm -rf $(TEMP_INSTALL_ROOT)
	rm -rf $(APP)

.PHONY: clean default