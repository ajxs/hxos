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
.global stack_bottom
stack_bottom:
	.skip 0x4000
.global stack_top
stack_top:

multiboot_magic:
	.space 4
multiboot_info_ptr:
	.space 4

# Preallocate pages used for paging. Don't hard-code addresses and assume they
# are available, as the bootloader might have loaded its multiboot structures or
# modules there. This lets the bootloader know it must avoid the addresses.
.section .bss, "aw", @nobits
	.align 4096
boot_page_directory:
	.skip 4096
boot_page_table1:
	.skip 4096
# Further page tables may be required if the kernel grows beyond 3 MiB.


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
 * init_boot_page_directory
 */
.type init_boot_page_directory, @function
init_boot_page_directory:
	# Physical address of boot_page_table1.
	# TODO: I recall seeing some assembly that used a macro to do the
	#       conversions to and from physical. Maybe this should be done in this
	#       code as well?
	movl $(boot_page_table1 - 0xC0000000), %edi
	# First address to map is address 0.
	# TODO: Start at the first kernel page instead. Alternatively map the first
	#       1 MiB as it can be generally useful, and there's no need to
	#       specially map the VGA buffer.
	movl $0, %esi
	# Map 1023 pages. The 1024th will be the VGA text buffer.
	movl $1023, %ecx

1:
	# Only map the kernel.
	cmpl $(_kernel_start - 0xC0000000), %esi
	jl 2f
	cmpl $(_kernel_end - 0xC0000000), %esi
	jge 3f

	# Map physical address as "present, writable". Note that this maps
	# .text and .rodata as writable. Mind security and map them as non-writable.
	movl %esi, %edx
	orl $0x003, %edx
	movl %edx, (%edi)

2:
	# Size of page is 4096 bytes.
	addl $4096, %esi
	# Size of entries in boot_page_table1 is 4 bytes.
	addl $4, %edi
	# Loop to the next entry if we haven't finished.
	loop 1b

3:
	# Map VGA video memory to 0xC03FF000 as "present, writable".
	movl $(0x000B8000 | 0x003), boot_page_table1 - 0xC0000000 + 1023 * 4

	# The page table is used at both page directory entry 0 (virtually from 0x0
	# to 0x3FFFFF) (thus identity mapping the kernel) and page directory entry
	# 768 (virtually from 0xC0000000 to 0xC03FFFFF) (thus mapping it in the
	# higher half). The kernel is identity mapped because enabling paging does
	# not change the next instruction, which continues to be physical. The CPU
	# would instead page fault if there was no identity mapping.

	# Map the page table to both virtual addresses 0x00000000 and 0xC0000000.
	movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 0
	movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 768 * 4

ret

/*
 * load_boot_page_directory
 */
.type load_boot_page_directory, @function
load_boot_page_directory:
	ret

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

	cmpl $MULTIBOOT_BOOTLOADER_MAGIC, %eax
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
 * _start
 */
.global _start
.type _start, @function
_start:
	cli

	call init_boot_page_directory

	# Set cr3 to the address of the boot_page_directory.
	movl $(boot_page_directory - 0xC0000000), %ecx
	movl %ecx, %cr3

	# Enable paging and the write-protect bit.
	movl %cr0, %ecx
	orl $0x80010000, %ecx
	movl %ecx, %cr0

	# Jump to higher half with an absolute jump.
	lea Lhigher_half_jump, %ecx
	jmp *%ecx

Lhigher_half_jump:

	# Setup stack.
	movl $stack_top, %esp

	# push multiboot vars onto stack.
	pushl %ebx
	pushl %eax

	pushl $0x0F                # black/white
	call vga_text_set_colours
	call vga_text_clear
	addl $4, %esp

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
