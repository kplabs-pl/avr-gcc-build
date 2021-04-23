SHELL := /bin/bash

SRC_DIR=$(abspath ./src)

BUILD_DIR=$(abspath ./build)
BUILD_LINUX_DIR=$(abspath ./build/linux)
BUILD_WIN64_DIR=$(abspath ./build/win64)

INSTALL_DIR=$(abspath ./install)
INSTALL_LINUX_DIR=$(abspath ./install/linux)
INSTALL_WIN64_DIR=$(abspath ./install/win64)

BINUTILS_SRC=$(SRC_DIR)/binutils-2.36
BINUTILS_BUILD_LINUX=$(BUILD_LINUX_DIR)/binutils
BINUTILS_BUILD_WIN64=$(BUILD_WIN64_DIR)/binutils
BINUTILS_INSTALL_LINUX=$(INSTALL_LINUX_DIR)/binutils
BINUTILS_INSTALL_WIN64=$(INSTALL_WIN64_DIR)/binutils

GCC_SRC=$(SRC_DIR)/gcc-10.3.0
GCC_STAGE1_BUILD_LINUX=$(BUILD_LINUX_DIR)/gcc-stage1
GCC_STAGE1_INSTALL_LINUX=$(INSTALL_LINUX_DIR)/gcc-stage1

GCC_FINAL_BUILD_LINUX=$(BUILD_LINUX_DIR)/gcc-final
GCC_FINAL_BUILD_WIN64=$(BUILD_WIN64_DIR)/gcc-final
GCC_FINAL_INSTALL_LINUX=$(INSTALL_LINUX_DIR)/gcc-final
GCC_FINAL_INSTALL_WIN64=$(INSTALL_WIN64_DIR)/gcc-final

AVR_LIBC_SRC=$(SRC_DIR)/avr-libc-2.0.0
AVR_LIBC_BUILD=$(BUILD_DIR)/avr-libc
AVR_LIBC_INSTALL=$(INSTALL_DIR)/avr-libc

INSTALL_LINUX=$(INSTALL_LINUX_DIR)/combined
INSTALL_WIN64=$(INSTALL_WIN64_DIR)/combined

STAGE1_TOOLCHAIN=$(INSTALL_DIR)/stage1

HOST_LINUX=x86_64-pc-linux-gnu
HOST_WIN64=x86_64-w64-mingw32

WIN64_LIBS=/usr/x86_64-w64-mingw32/bin

help:
	@echo avr-gcc build script

info:
	@echo "Sources:"
	@echo "    Binutils: $(BINUTILS_SRC)"
	@echo "    GCC:      $(GCC_SRC)"
	@echo "    avr-libc: $(AVR_LIBC_SRC)"
	@echo "Build dirs:"
	@echo "    avr-libc:     $(AVR_LIBC_BUILD)"
	@echo "Build dirs (Linux):"
	@echo "    binutils:     $(BINUTILS_BUILD_LINUX)"
	@echo "    gcc (stage1): $(GCC_STAGE1_BUILD_LINUX)"
	@echo "    gcc (final):  $(GCC_FINAL_BUILD_LINUX)"
	@echo "Build dirs (Win64):"
	@echo "    binutils:     $(BINUTILS_BUILD_WIN64)"
	@echo "    gcc (final):  $(GCC_FINAL_BUILD_WIN64)"
	@echo "Install dirs:"
	@echo "    avr-libc:     $(AVR_LIBC_INSTALL)"
	@echo "Install dirs (Linux)"
	@echo "    binutils:     $(BINUTILS_INSTALL_LINUX)"
	@echo "    gcc (stage1): $(GCC_STAGE1_INSTALL_LINUX)"
	@echo "    gcc (final):  $(GCC_FINAL_INSTALL_LINUX)"
	@echo "    Combined:     $(INSTALL_LINUX)"
	@echo "Install dirs (Win64)"
	@echo "    binutils:     $(BINUTILS_INSTALL_WIN64)"
	@echo "    gcc (final):  $(GCC_FINAL_INSTALL_WIN64)"
	@echo "    Combined:     $(INSTALL_WIN64)"

binutils-linux:
	@echo "Building binutils (Linux)"
	@mkdir -p $(BINUTILS_BUILD_LINUX)
	
	@echo "SRC=$(BINUTILS_SRC)" 				  >  $(BINUTILS_BUILD_LINUX)/_script.Makefile
	@echo "INSTALL_DIR=$(BINUTILS_INSTALL_LINUX)" >> $(BINUTILS_BUILD_LINUX)/_script.Makefile
	@echo "HOST=$(HOST_LINUX)" 					  >> $(BINUTILS_BUILD_LINUX)/_script.Makefile
	@cat ./makes/binutils.Makefile 				  >> $(BINUTILS_BUILD_LINUX)/_script.Makefile
	
	@make -C $(BINUTILS_BUILD_LINUX) -f _script.Makefile

binutils-win64:
	@echo "Building binutils (Win64)"
	@mkdir -p $(BINUTILS_BUILD_WIN64)

	@echo "SRC=$(BINUTILS_SRC)" 				  >  $(BINUTILS_BUILD_WIN64)/_script.Makefile
	@echo "INSTALL_DIR=$(BINUTILS_INSTALL_WIN64)" >> $(BINUTILS_BUILD_WIN64)/_script.Makefile
	@echo "HOST=$(HOST_WIN64)" 					  >> $(BINUTILS_BUILD_WIN64)/_script.Makefile
	@cat ./makes/binutils.Makefile 				  >> $(BINUTILS_BUILD_WIN64)/_script.Makefile

	@make -C $(BINUTILS_BUILD_WIN64) -f _script.Makefile

gcc-stage1-linux:
	@echo "Building GCC stage 1 (Linux)"
	@mkdir -p $(GCC_STAGE1_BUILD_LINUX)

	@echo "export PATH=$(BINUTILS_INSTALL_LINUX)/bin:$(PATH)"	>  $(GCC_STAGE1_BUILD_LINUX)/_script.Makefile
	@echo "SRC=$(GCC_SRC)"										>> $(GCC_STAGE1_BUILD_LINUX)/_script.Makefile
	@echo "INSTALL_DIR=$(GCC_STAGE1_INSTALL_LINUX)"				>> $(GCC_STAGE1_BUILD_LINUX)/_script.Makefile
	@cat ./makes/gcc.Makefile 									>> $(GCC_STAGE1_BUILD_LINUX)/_script.Makefile

	make -C $(GCC_STAGE1_BUILD_LINUX) -f _script.Makefile  stage1

avr-libc:
	@echo "Creating stage 1 toolchain"
	@mkdir -p $(STAGE1_TOOLCHAIN)
	cp -R $(BINUTILS_INSTALL_LINUX)/* $(STAGE1_TOOLCHAIN)
	cp -R $(GCC_STAGE1_INSTALL_LINUX)/* $(STAGE1_TOOLCHAIN)
	
	@echo "Building AVR-LibC"
	@mkdir -p $(AVR_LIBC_BUILD)

	@echo "export PATH=$(STAGE1_TOOLCHAIN)/bin:$(PATH)"  	> $(AVR_LIBC_BUILD)/_script.Makefile
	@echo "SRC=$(AVR_LIBC_SRC)"									>> $(AVR_LIBC_BUILD)/_script.Makefile
	@echo "INSTALL_DIR=$(AVR_LIBC_INSTALL)"						>> $(AVR_LIBC_BUILD)/_script.Makefile
	@cat ./makes/avr-libc.Makefile 								>> $(AVR_LIBC_BUILD)/_script.Makefile
	
	make -C $(AVR_LIBC_BUILD) -f _script.Makefile

gcc-linux:
	@echo "Creating stage 1 toolchain"
	@mkdir -p $(STAGE1_TOOLCHAIN)
	cp -R $(BINUTILS_INSTALL_LINUX)/* $(STAGE1_TOOLCHAIN)
	cp -R $(GCC_STAGE1_INSTALL_LINUX)/* $(STAGE1_TOOLCHAIN)
	
	@echo "Building GCC final (Linux)"
	@mkdir -p $(GCC_FINAL_BUILD_LINUX)
	@mkdir -p $(GCC_FINAL_INSTALL_LINUX)
	@cp -R $(AVR_LIBC_INSTALL)/* $(GCC_FINAL_INSTALL_LINUX)

	@echo "export PATH=$(STAGE1_TOOLCHAIN)/bin:$(PATH)"  >  $(GCC_FINAL_BUILD_LINUX)/_script.Makefile
	@echo "SRC=$(GCC_SRC)"                               >> $(GCC_FINAL_BUILD_LINUX)/_script.Makefile
	@echo "INSTALL_DIR=$(GCC_FINAL_INSTALL_LINUX)"       >> $(GCC_FINAL_BUILD_LINUX)/_script.Makefile
	@echo "HOST=$(HOST_LINUX)"                           >> $(GCC_FINAL_BUILD_LINUX)/_script.Makefile
	@cat ./makes/gcc.Makefile                            >> $(GCC_FINAL_BUILD_LINUX)/_script.Makefile

	make -C $(GCC_FINAL_BUILD_LINUX) -f _script.Makefile final


gcc-win64:
	@echo "Creating stage 1 toolchain"
	@mkdir -p $(STAGE1_TOOLCHAIN)
	cp -R $(BINUTILS_INSTALL_LINUX)/* $(STAGE1_TOOLCHAIN)
	cp -R $(GCC_STAGE1_INSTALL_LINUX)/* $(STAGE1_TOOLCHAIN)

	@echo "Building GCC final (Windows)"
	@mkdir -p $(GCC_FINAL_BUILD_WIN64)
	@mkdir -p $(GCC_FINAL_INSTALL_WIN64)
	@cp -R $(AVR_LIBC_INSTALL)/* $(GCC_FINAL_INSTALL_WIN64)
	
	@echo "export PATH=$(STAGE1_TOOLCHAIN)/bin:$(PATH)"  >  $(GCC_FINAL_BUILD_WIN64)/_script.Makefile
	@echo "SRC=$(GCC_SRC)"                               >> $(GCC_FINAL_BUILD_WIN64)/_script.Makefile
	@echo "INSTALL_DIR=$(GCC_FINAL_INSTALL_WIN64)"       >> $(GCC_FINAL_BUILD_WIN64)/_script.Makefile
	@echo "HOST=$(HOST_WIN64)"                           >> $(GCC_FINAL_BUILD_WIN64)/_script.Makefile
	@cat ./makes/gcc.Makefile                            >> $(GCC_FINAL_BUILD_WIN64)/_script.Makefile
	
	make -C $(GCC_FINAL_BUILD_WIN64) -f _script.Makefile final-gcc-only

toolchain-linux:
	@echo "Creating final Linux toolchain"
	@mkdir -p $(INSTALL_LINUX)
	@rm -rf $(INSTALL_LINUX)/*
	cp -R $(GCC_FINAL_INSTALL_LINUX)/* $(INSTALL_LINUX)
	cp -R $(AVR_LIBC_INSTALL)/* $(INSTALL_LINUX)
	cp -R $(BINUTILS_INSTALL_LINUX)/* $(INSTALL_LINUX)

toolchain-win64:
	@echo "Creating final Win64 toolchain"
	@mkdir -p $(INSTALL_WIN64)
	@rm -rf $(INSTALL_WIN64)/*
	cp -R $(GCC_FINAL_INSTALL_WIN64)/* $(INSTALL_WIN64)
	cp -R $(AVR_LIBC_INSTALL)/* $(INSTALL_WIN64)
	cp -R $(BINUTILS_INSTALL_WIN64)/* $(INSTALL_WIN64)
	
	cp -R $(GCC_FINAL_INSTALL_LINUX)/lib/* $(INSTALL_WIN64)/lib/
	cp -R $(GCC_FINAL_INSTALL_LINUX)/avr/* $(INSTALL_WIN64)/avr/

# lib, include, include/c++, lib/gcc/avr
	
	@cp -v $(WIN64_LIBS)/libgcc_s_seh-1.dll $(INSTALL_WIN64)/libexec/gcc/avr/10.3.0
	@cp -v $(WIN64_LIBS)/libgmp-10.dll $(INSTALL_WIN64)/libexec/gcc/avr/10.3.0
	@cp -v $(WIN64_LIBS)/libmpc-3.dll $(INSTALL_WIN64)/libexec/gcc/avr/10.3.0
	@cp -v $(WIN64_LIBS)/libmpfr-6.dll $(INSTALL_WIN64)/libexec/gcc/avr/10.3.0
	@cp -v $(WIN64_LIBS)/libssp-0.dll $(INSTALL_WIN64)/libexec/gcc/avr/10.3.0
	@cp -v $(WIN64_LIBS)/libwinpthread-1.dll $(INSTALL_WIN64)/libexec/gcc/avr/10.3.0
	@cp -v $(WIN64_LIBS)/libwinpthread-1.dll $(INSTALL_WIN64)/bin
	@cp -v $(WIN64_LIBS)/libstdc++-6.dll $(INSTALL_WIN64)/bin
	tar cjf $(INSTALL_WIN64_DIR)/avr-gcc-10-win64.tar.gz -C $(INSTALL_WIN64) .

# Generowaie Makefile z wartościami
# Build combined toolchain (linux)
# Build combined toolchain (Windows)
# 	Win64 - kopiowanie .dllek