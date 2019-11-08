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

.set MULTIBOOT_BOOTLOADER_MAGIC, 0x1BADB002
.set MULTIBOOT_HEADER_FLAGS,     0x3
.set MULTIBOOT_HEADER_CHECKSUM,  -(MULTIBOOT_BOOTLOADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

.section .multiboot
.align 4
	.long MULTIBOOT_BOOTLOADER_MAGIC
	.long MULTIBOOT_HEADER_FLAGS
	.long MULTIBOOT_HEADER_CHECKSUM

.section .bss, "aw", @nobits
# Reserve space for stack.
.global stack_bottom
stack_bottom:
	.skip 0x4000
.global stack_top
stack_top:

# Reserve space for storing multiboot magic number and MBI pointer.
multiboot_magic:
	.space 4
multiboot_info_ptr:
	.space 4

# Reserve space for boot page directory and single kernel table.
.align 4096
boot_page_directory:
	.skip 4096
kernel_page_table:
	.skip 4096


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

/*
 * multiboot_init
 */
.type multiboot_init, @function
multiboot_init:
	push %ebp
	movl %esp, %ebp

	pushl $string_boot_init
	call vga_text_print
	addl $4, %esp

	movl 0x8(%ebp), %eax        # Multiboot magic var
	movl 0x12(%ebp), %ebx       # pointer to MBI.

	cmpl $0x2BADB002, %eax
	jne multiboot_fail

	pushl $string_boot_success
	call vga_text_print
	addl $4, %esp

	leave
	ret


/*
 * multiboot_fail
 */
.type multiboot_fail, @function
multiboot_fail:
	pushl $0x4F    #red/white
	call vga_text_set_colours
	popl %edx

	pushl $string_boot_fail
	call vga_text_print
	popl %edx

	# Hang here if this fails.
	jmp kernel_hang


/*
 * init_boot_page_directory
 */
.type init_boot_page_directory, @function
init_boot_page_directory:
	movl $(kernel_page_table - 0xC0000000), %edi
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
	# Size of entries in kernel_page_table is 4 bytes.
	addl $4, %edi
	# Loop to the next entry if we haven't finished.
	loop map_kernel_pages

map_vga_buffer:
	# Map VGA video memory to 0xC03FF000 as "present, writable".
	movl $(0xB8000 + 3), kernel_page_table - 0xC0000000 + (1023 * 4)

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
	movl $((kernel_page_table - 0xC0000000) + 3), boot_page_directory - 0xC0000000
	movl $((kernel_page_table - 0xC0000000) + 3), boot_page_directory - 0xC0000000 + 768 * 4

	ret


/*
 * _start
 */
.global _start
.type _start, @function
_start:
	cli

	# Save multiboot variables.
	movl %eax, (multiboot_magic - 0xC0000000)
	movl %ebx, (multiboot_info_ptr - 0xC0000000)

	call init_boot_page_directory

	# Load address of the page directory into CR3.
	movl $(boot_page_directory - 0xC0000000), %ecx
	movl %ecx, %cr3

	# Enable paging and write-protect flag.
	movl %cr0, %ecx
	orl $0x80010000, %ecx
	movl %ecx, %cr0

	# Absolute jump to higher half.
	lea higher_half_jump, %ecx
	jmp *%ecx

higher_half_jump:
	# Setup stack.
	movl $stack_top, %esp

	pushl $0x0F                # black/white
	call vga_text_set_colours
	call vga_text_clear
	addl $4, %esp

	# push multiboot vars onto stack.
	# Retrieve the magic number and boot info struct
	# address then push onto the stack as per the Multiboot spec.
	# See: https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Machine-state
	movl (multiboot_magic - 0xC0000000), %eax
	movl (multiboot_info_ptr - 0xC0000000), %ebx

	pushl %ebx
	pushl %eax
	call multiboot_init

	pushl $0x5F                # purple/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $string_start_success
	call vga_text_print
	addl $4, %esp

	pushl $0x0F                # black/white
	call vga_text_set_colours
	addl $4, %esp

	jmp kernel_init
