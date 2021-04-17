SHELL := /bin/bash

dummy: 
	@echo "Select target"

stage1-configure:
	@echo  "Configuring stage1"
	$(SRC)/configure \
		--prefix=$(INSTALL_DIR) \
		--host=$(HOST) \
		--target=avr \
		--enable-languages=c,c++ \
		--disable-nls \
		--disable-libssp \
		--with-dwarf2

stage1-build: stage1-configure
	@echo  "Building stage1"
	make -j9

stage1-install: stage1-build
	@echo "Installing stage1"
	make install-strip


stage1: stage1-install

# --enable-clocale=gnu 
# --with-newlib 
final-configure:
	echo "Configuring final"
	target_configargs="--disable-shared" \
		$(SRC)/configure \
			--prefix=$(INSTALL_DIR) \
			--host=$(HOST) \
			--target=avr \
			--enable-languages=c,c++ \
			--disable-nls \
			--disable-libssp \
			--with-dwarf2 \
			--enable-libstdcxx \
			--disable-sjlj-exceptions \
			--disable-install-libiberty \
			--disable-libstdcxx-pch \
			--disable-libunwind-exceptions \
			--enable-gnu-unique-object \
			--enable-gnu-indirect-function \
			--enable-cxx-flags='-fno-exceptions -fno-rtti' \
			--disable-libstdcxx-verbose \
			--disable-libstdcxx-time \
			--disable-libstdcxx-threads \
			--disable-threads \
			--disable-libstdcxx-filesystem-ts \
			--enable-static \
			--disable-shared

final-build: final-configure
	echo "Building final"
	make -j12

final-install: final-build
	echo "Installing final"
	make install-strip

final: final-install

env:
	@export