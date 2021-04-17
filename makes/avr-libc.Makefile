all: install

configure: 
	@echo "Configuring"
	$(SRC)/configure \
		--prefix=$(INSTALL_DIR) \
		--host=avr

build: configure
	@echo "Building"
	make -j5

install: build
	@echo "Installing"
	make install

