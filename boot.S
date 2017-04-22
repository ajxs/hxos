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
.global stack_top
stack_top:

.section .text

.type multiboot_init, @function
multiboot_init:
	push %ebp
	movl %esp, %ebp

	movl 0x8(%ebp), %eax     # Multiboot magic var
	movl 0x12(%ebp), %ebx     # pointer to MBI.

	cmpl $MULTIBOOT_BOOTLOADER_MAGIC, %eax
	jne multiboot_fail

	movl %ebp, %esp
	pop %ebp
	ret

.type multiboot_fail, @function
multiboot_fail:
	pushl $0x4F    #red/white
	call tty_set_colors
	call tty_clear
	popl %edx
	cli
	hlt

.global _start
.type _start, @function
_start:
	cli
	movl $stack_top, %esp

	push %ebx
	push %eax
	call multiboot_init

	pushl $0x2F    #green/white
	call tty_set_colors
	call tty_clear
	popl %edx

	call gdt_init

	jmp kernel_init
