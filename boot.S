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

.section .data

string_boot_init:
	.asciz "multiboot_init: Checking multiboot header...\n"
string_boot_success:
	.asciz "multiboot_init: Header valid!...\n"
string_boot_fail:
	.asciz "multiboot_init: Header invalid!...\n"
string_start_success:
	.asciz "_start: boot successful!...\n"

.section .text

.type multiboot_init, @function
multiboot_init:
	push %ebp
	movl %esp, %ebp

	pushl $string_boot_init
	call tty_print
	popl %edx

	movl 0x8(%ebp), %eax        # Multiboot magic var
	movl 0x12(%ebp), %ebx       # pointer to MBI.

	cmpl $MULTIBOOT_BOOTLOADER_MAGIC, %eax
	jne multiboot_fail

	pushl $string_boot_success
	call tty_print
	popl %edx

	leave
	ret

.type multiboot_fail, @function
multiboot_fail:
	pushl $0x4F    #red/white
	call tty_set_colors
	popl %edx

	pushl $string_boot_fail
	call tty_print
	popl %edx

	cli
	hlt

.global _start
.type _start, @function
_start:
	cli
	movl $stack_top, %esp

	pushl %ebx                  # push multiboot vars onto stack FIRST
	pushl %eax

	pushl $0x0F                # black/white
	call tty_set_colors
	call tty_clear
	popl %edx

	call multiboot_init
	popl %edx
	popl %edx
	
	call gdt_init

	pushl $0x5F                # purple/white
	call tty_set_colors
	popl %edx

	pushl $string_start_success
	call tty_print
	popl %edx

	pushl $0x0F                # black/white
	call tty_set_colors
	popl %edx

	jmp kernel_init
