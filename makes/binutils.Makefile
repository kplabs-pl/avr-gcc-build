all: install

configure: 
	@echo "Configuring"
	$(SRC)/configure \
		--prefix=$(INSTALL_DIR) \
		--host=$(HOST) \
		--target=avr \
		--disable-nls \
		--enable-lto \
		--enable-ld=default \
		--enable-gold \
		--enable-plugins \
		--enable-threads \
		--with-pic \
		--disable-werror \
		--disable-multilib

build: configure
	@echo "Building"
	make -j20

install: build
	@echo "Installing"
	make install-strip

