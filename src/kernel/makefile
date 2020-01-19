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

ARCH := i686
CC   := ${ARCH}-elf-gcc

INCLUDE_DIRS := src/include
INCLUDE_FLAG := ${foreach d, ${INCLUDE_DIRS}, -I$d}

CFLAGS :=                   \
	-fno-stack-protector      \
	-ffreestanding            \
	-ggdb                     \
	${INCLUDE_FLAG}           \
	-std=gnu99                \
	-Wall                     \
	-Wextra

LDFLAGS :=            \
	-ffreestanding      \
	-nostdlib           \
	-T src/kernel.ld

LIBS := -lgcc

AS_SOURCES :=               \
	src/boot.S                \
	src/boot-paging.S         \
	src/gdt.S                 \
	src/hxos.S                \
	src/mmap.S                \
	src/pmode.S               \
	src/vga.S

OBJECTS := ${AS_SOURCES:.S=.o}

BUILD_DIR     := build
KERNEL_BINARY := ${BUILD_DIR}/hxos.elf

.PHONY: all clean

all: ${KERNEL_BINARY}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

clean:
	rm -f ${OBJECTS}
	rm -rf ${BUILD_DIR}

${KERNEL_BINARY}: ${OBJECTS} ${BUILD_DIR}
	${CC} ${LDFLAGS} ${OBJECTS} -o ${KERNEL_BINARY} ${LIBS}

%.o: %.S
	${CC} ${CFLAGS} -c $< -o $@
