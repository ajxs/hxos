BUILD_DIR := build
ISO       := ${BUILD_DIR}/hxos.img

KERNEL_DIR    := kernel
KERNEL_BINARY := ${KERNEL_DIR}/build/hxos.elf

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
	cp "${KERNEL_BINARY}" iso/boot
	grub-mkrescue -o ${ISO} iso

clean:
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

${KERNEL_BINARY}: ${BUILD_DIR}
	make -C "${KERNEL_DIR}"