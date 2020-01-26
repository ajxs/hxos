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

.string_multiboot_mmap_init:
	.asciz "multiboot_mmap_init: Parsing multiboot memory map...\n"
.string_multiboot_mmap_end:
	.asciz "multiboot_mmap_init: Finished parsing multiboot memory map...\n"

.section .text

#####################################################################
# Parse Multiboot Memory Map
#
# Parses the Multiboot memory map provided by the bootloader.
#####################################################################
.global multiboot_mmap_init
.type multiboot_mmap_init, @function
multiboot_mmap_init:
	pushl $0x0F                              # black/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $.string_multiboot_mmap_init
	call vga_text_print
	addl $4, %esp

.end_multiboot_mmap_init:
	pushl $0x5F                              # purple/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $.string_multiboot_mmap_end
	call vga_text_print
	addl $4, %esp

	ret
