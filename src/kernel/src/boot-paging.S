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

.global init_boot_page_directory
.type init_boot_page_directory, @function
init_boot_page_directory:
	movl $(boot_page_tables - 0xC0000000), %edi
	movl $0, %esi
	# Map 1023 pages. The 1024th will be the VGA text buffer.
	movl $1023, %ecx

map_kernel_pages:
	# If we're below the start of the kernel, increment the frame address
	# without mapping that frame.
	cmpl $(kernel_start - 0xC0000000), %esi
	jl increment_frame_address
	# If the current frame address is above the end of the kernel, skip to mapping
	# the last frame to the VGA buffer.
	cmpl $(kernel_end - 0xC0000000), %esi
	jge map_vga_buffer

	# Map physical address as "present, writable". Note that this maps
	# .text and .rodata as writable. Mind security and map them as non-writable.
	movl %esi, %edx
	orl $0x003, %edx
	movl %edx, (%edi)

increment_frame_address:
	# Size of page is 4096 bytes.
	addl $0x1000, %esi
	# Size of entries in boot_page_tables is 4 bytes.
	addl $4, %edi
	# Loop to the next entry if we haven't finished.
	loop map_kernel_pages

map_vga_buffer:
	# Map VGA video memory to 0xC03FF000 as "present, writable".
	movl $(0xB8000 + 3), boot_page_tables - 0xC0000000 + (1023 * 4)

	# The page table is used at both page directory entry 0 (virtually from 0x0
	# to 0x3FFFFF) (thus identity mapping the kernel) and page directory entry
	# 768 (virtually from 0xC0000000 to 0xC03FFFFF) (thus mapping it in the
	# higher half). The kernel is identity mapped because enabling paging does
	# not change the next instruction, which continues to be physical. The CPU
	# would instead page fault if there was no identity mapping.

load_mapped_page_tables:
	# Map the kernel page table to both virtual addresses 0x00000000 and 0xC0000000.
	# This allows the code to keep executing after enabling paging, prior to the
	# absolute jump to the higher half.
	movl $((boot_page_tables - 0xC0000000) + 3), boot_page_directory - 0xC0000000
	movl $((boot_page_tables - 0xC0000000) + 3), boot_page_directory - 0xC0000000 + 768 * 4

	ret
