#include <hxos.h>
#include <multiboot.h>

.align 4096
.section .multiboot
.long MULTIBOOT_HEADER_MAGIC
.long MULTIBOOT_HEADER_FLAGS
.long MULTIBOOT_HEADER_CHECKSUM

.align 4096
.section .bss, "aw", @nobits
stack_bottom:
	.skip STACK_SIZE
stack_top:

.section .text

.type _multiboot_init, @function
_multiboot_init:
	push %ebp
	movl %esp, %ebp

	movl 0x8(%ebp), %eax     # Multiboot magic var
	movl 0x12(%ebp), %ebx     # pointer to MBI.

	cmpl $MULTIBOOT_BOOTLOADER_MAGIC, %eax
	jne _multiboot_fail

	pop %ebp
	ret

.type _multiboot_fail, @function
_multiboot_fail:
	pushl $0x4F    #red
	call _tty_clear_color
	cli
	hlt

.global _start
.type _start, @function
_start:
	cli

	movl $stack_top, %esp

	push %ebx
	push %eax
	call _multiboot_init

	jmp _kernel_init
