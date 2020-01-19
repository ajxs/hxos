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

.section .bss

.align 4096
global_descriptor_table:
.segment_null:
	.skip 8
.segment_supervisor_code:
	.skip 8
.segment_supervisor_data:
	.skip 8
.segment_user_code:
	.skip 8
.segment_user_data:
	.skip 8
.global_descriptor_table_end:


.section .rodata

.string_gdt_init:
	.asciz "gdt_init: Populating GDT...\n"
.string_gdt_load:
	.asciz "gdt_init: Loading GDT...\n"
.string_gdt_loaded:
	.asciz "gdt_init: GDT loaded\n"


#####################################################################
# GDT pointer structure.
# Contains the table size and offset. This is used to instruct the CPU
# as to the location of the GDT.
#####################################################################
global_descriptor_table_ptr:
	.word global_descriptor_table - .global_descriptor_table_end
	.long global_descriptor_table


.section .text

#####################################################################
# GDT Initialisation
#####################################################################
.global gdt_init
gdt_init:
	pushl $.string_gdt_init
	call vga_text_print
	addl $4, %esp

	# Address of GDT is stored in EBX
	movl $global_descriptor_table, %ebx

	leal 8(%ebx), %eax                       # Load supervisor code segment addr into EAX.
	movl $0xFFFF, (%eax)
	addl $4, %eax
	movl $0xCF9A00, (%eax)

	leal 16(%ebx), %eax                      # Load supervisor data segment addr into EAX.
	movl $0xFFFF, (%eax)                     # Lower bytes of the descriptor structure.
	addl $4, %eax                            # Increment ptr address.
	movl $0xCF9300, (%eax)                   # Higher bytes of the descriptor structure.

	leal 24(%ebx), %eax                      # Load address of user code segment into EAX.
	movl $0xFFFF, (%eax)
	addl $4, %eax
	movl $0xCFFA00, (%eax)

	leal 32(%ebx), %eax                      # Load address of user data segment into EAX.
	movl $0xFFFF, (%eax)
	addl $4, %eax
	movl $0xCFF200, (%eax)

	pushl $.string_gdt_load
	call vga_text_print
	addl $4, %esp

	# Load the GDT pointer.
	lgdt global_descriptor_table_ptr

	pushl $.string_gdt_loaded
	call vga_text_print
	addl $4, %esp

	ret
