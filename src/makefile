#####################################################################
#  Copyright (c) 2019, HXOS.
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Authors:
#     Anthony <ajxs [at] panoptic.online>
#####################################################################

.POSIX:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ISO_DIR         := iso
ISO             := ${ISO_DIR}/build/hxos.img

KERNEL_DIR      := kernel
KERNEL_BINARY   := ${KERNEL_DIR}/build/hxos.elf

SERIAL_FILENAME := serial.log

QEMU_FLAGS :=                 \
	-accel tcg,thread=single    \
	-cpu core2duo               \
	-m 128                      \
	-no-reboot                  \
	-smp 1                      \
	-usb                        \
	-vga std

.POSIX:
.PHONY: all clean

all: ${ISO}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

${ISO}: ${KERNEL_BINARY} ${BUILD_DIR}
	make -C "${ISO_DIR}"

clean:
	make clean -C "${ISO_DIR}"
	make clean -C "${KERNEL_DIR}"
	rm -rf ${BUILD_DIR}

debug: ${ISO}
	qemu-system-i386                               \
		${QEMU_FLAGS}                                \
		-d cpu_reset,int,guest_errors                \
		-drive format=raw,media=cdrom,file=${ISO}    \
		-gdb tcp::1234                               \
		-S                                           \
		-serial file:${SERIAL_FILENAME}

emu: ${ISO}
	qemu-system-i386                               \
		${QEMU_FLAGS}                                \
		-drive format=raw,media=cdrom,file=${ISO}    \
		-serial stdio

iso: ${ISO}

${KERNEL_BINARY}: ${BUILD_DIR}
	make -C "${KERNEL_DIR}"
