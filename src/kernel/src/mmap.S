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

.string_mmap_init:
	.asciz "mmap_init: Initialising memory map...\n"
.string_mmap_init_end:
	.asciz "mmap_init: Finished initialising memory map!\n"

.section .bss

#####################################################################
# Memory map bitmap
#
# Raw bitmap of memory map frames.
#####################################################################
.mmap_bitmap:
	.skip 0x20000

.section .text

#####################################################################
# Initialise Memory map
#
# Initialises the kernel memory map. Initially all entries are marked
# as being non-available.
#####################################################################
.global mmap_init
.type mmap_init, @function
mmap_init:
	pushl $.string_mmap_init
	call vga_text_print
	addl $4, %esp

	movl $.mmap_bitmap, %edi                 # Store mmap pointer in EDI.
	movl $0x8000, %ecx                       # Number of DWORDs in mmap.

.set_frame_group:
	movl $0, (%edi)                          # Move value to mmap frame ptr.
	addl $4, %edi                            # Increment frame pointer.
	loop .set_frame_group

.end_mmap_init:
	pushl $.string_mmap_init_end
	call vga_text_print
	addl $4, %esp

	ret
