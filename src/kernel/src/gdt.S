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

.section .bss

.align 4096
.global global_descriptor_table
global_descriptor_table:
Lsegment_null:
	.skip 8
Lsegment_supervisor_code:
	.skip 8
Lsegment_supervisor_data:
	.skip 8
Lsegment_user_code:
	.skip 8
Lsegment_user_data:
	.skip 8
Lglobal_descriptor_table_end:


.section .data

string_gdt_init:
	.asciz "gdt_init: Populating GDT...\n"
string_gdt_load:
	.asciz "gdt_init: Loading GDT...\n"
string_gdt_loaded:
	.asciz "gdt_init: GDT loaded\n"


/**
 * GDT pointer structure.
 * Contains the table size and offset. This is used to instruct the CPU
 * as to the location of the GDT.
 */
global_descriptor_table_ptr:
	.word global_descriptor_table - Lglobal_descriptor_table_end
	.long global_descriptor_table


.section .text

/**
 * gdt_init
 */
.global gdt_init
gdt_init:
	pushl $string_gdt_init
	call vga_text_print
	addl $4, %esp

	# Address of GDT is stored in EBX
	movl $global_descriptor_table, %ebx

	# Load address of supervisor code segment into EAX.
	leal 8(%ebx), %eax
	movl $0xFFFF, (%eax)
	addl $4, %eax
	movl $0xCF9A00, (%eax)

	# Load address of supervisor data segment into EAX.
	leal 16(%ebx), %eax
	# Load the lower bytes of the descriptor structure.
	movl $0xFFFF, (%eax)
	# Load the higher bytes of the descriptor structure.
	addl $4, %eax
	movl $0xCF9300, (%eax)

	# Load address of user code segment into EAX.
	leal 24(%ebx), %eax
	movl $0xFFFF, (%eax)
	addl $4, %eax
	movl $0xCFFA00, (%eax)

	# Load address of user data segment into EAX.
	leal 32(%ebx), %eax
	movl $0xFFFF, (%eax)
	addl $4, %eax
	movl $0xCFF200, (%eax)

	pushl $string_gdt_load
	call vga_text_print
	addl $4, %esp

	# Load the GDT pointer.
	lgdt global_descriptor_table_ptr

	pushl $string_gdt_loaded
	call vga_text_print
	addl $4, %esp

	ret
