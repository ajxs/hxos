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

.section .data

string_pmode_init:
	.asciz "protected_mode_init: beginning pmode init...\n"
string_pmode_success:
	.asciz "protected_mode_init: pmode successfully initialised...\n"

.section .text

/*
 * protected_mode_init
 */
.global protected_mode_init
.type protected_mode_init, @function
protected_mode_init:
	push %ebp
	movl %esp, %ebp

	pushl $string_pmode_init
	call vga_text_print
	addl $4, %esp

	movl %cr0, %eax
	orl $0x1, %eax
	movl %eax, %cr0
	ljmp $0x8, $.Lprotected_mode_init_reload

.Lprotected_mode_init_reload:
	sti

	# reload segment registers
	mov $0x10, %eax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	movl $stack_top, %esp

	pushl $string_pmode_success
	call vga_text_print
	popl %edx

	leave
	ret
