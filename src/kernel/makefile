CC := i686-elf-gcc

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
	-T src/linker.ld

LIBS := -lgcc

AS_SOURCES :=               \
	src/boot.S                \
	src/gdt.S                 \
	src/hxos.S                \
	src/pmode.S               \
	src/vga.S

OBJECTS := ${AS_SOURCES:.S=.o}

BUILD_DIR     := build
KERNEL_BINARY := ${BUILD_DIR}/hxos.elf

.POSIX:
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