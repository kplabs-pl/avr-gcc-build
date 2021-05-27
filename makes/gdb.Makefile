all: install

configure: 
	@echo "Configuring"
	$(SRC)/configure \
		--prefix=$(INSTALL_DIR) \
		--host=$(HOST) \
		--target=avr \
		--disable-nls \
		--enable-lto \
		--disable-sim

build: configure
	@echo "Building"
	make -j20

install: build
	@echo "Installing"
	make install-strip

