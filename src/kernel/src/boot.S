/**
 *  Copyright (c) 2019, HXOS.
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Authors:
 *     Anthony <ajxs [at] panoptic.online>
 */

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
	call vga_text_print
	popl %edx

	movl 0x8(%ebp), %eax        # Multiboot magic var
	movl 0x12(%ebp), %ebx       # pointer to MBI.

	cmpl $MULTIBOOT_BOOTLOADER_MAGIC, %eax
	jne multiboot_fail

	pushl $string_boot_success
	call vga_text_print
	popl %edx

	leave
	ret


.type multiboot_fail, @function
multiboot_fail:
	pushl $0x4F    #red/white
	call vga_text_set_colours
	popl %edx

	pushl $string_boot_fail
	call vga_text_print
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
	call vga_text_set_colours
	call vga_text_clear
	popl %edx

	call multiboot_init
	call gdt_init

	pushl $0x5F                # purple/white
	call vga_text_set_colours
	popl %edx

	pushl $string_start_success
	call vga_text_print
	popl %edx

	pushl $0x0F                # black/white
	call vga_text_set_colours
	popl %edx

	jmp kernel_init
