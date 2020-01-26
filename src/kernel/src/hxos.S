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

.section .rodata

.string_kernel_init:
	.asciz "kernel_init: beginning Kernel init...\n"
.string_main_init:
	.asciz "kernel_main: Kernel init successful!...\n"
.string_main_next:
	.asciz "kernel_main: Halted awaiting useful instructions!...\n"


.section .text

#####################################################################
# Kernel Init
#####################################################################
.global kernel_init
.type kernel_init, @function
kernel_init:
	push %ebp
	movl %esp, %ebp

	pushl $0x0F                              # Set VGA colours to black/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $.string_kernel_init
	call vga_text_print
	addl $4, %esp


	call gdt_init
	call protected_mode_init

	# Initialise the kernel memory map.
	call mmap_init

	# Parse Multiboot memory map provided by bootloader.
	call multiboot_mmap_init

	call kernel_main

	# cleanup state here
	leave
	jmp kernel_hang


#####################################################################
# Kernel Hang
#####################################################################
.global kernel_hang
kernel_hang:
	cli
	hlt
	jmp kernel_hang


#####################################################################
# Kernel Main
#####################################################################
.global kernel_main
.type kernel_main, @function
kernel_main:
	pushl $0x5F                # purple/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $.string_main_init
	call vga_text_print
	addl $4, %esp

	pushl $0x6E                # brown/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $.string_main_next
	call vga_text_print
	addl $4, %esp

	ret
