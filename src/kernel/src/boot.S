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

.set MULTIBOOT_BOOTLOADER_MAGIC, 0x1BADB002
.set MULTIBOOT_HEADER_FLAGS,     0x3
.set MULTIBOOT_HEADER_CHECKSUM,  -(MULTIBOOT_BOOTLOADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

.section .multiboot
.align 4
	.long MULTIBOOT_BOOTLOADER_MAGIC
	.long MULTIBOOT_HEADER_FLAGS
	.long MULTIBOOT_HEADER_CHECKSUM

.section .bss, "aw", @nobits

# Reserve space for storing multiboot magic number and MBI pointer.
multiboot_magic:
	.space 4
multiboot_info_ptr:
	.space 4

multiboot_mmap_addr:
	.space 4
multiboot_mmap_length:
	.space 4

.section .rodata

.string_boot_init:
	.asciz "multiboot_init: Checking multiboot header...\n"
.string_boot_success:
	.asciz "multiboot_init: Header valid!...\n"
.string_boot_fail:
	.asciz "multiboot_init: Header invalid!...\n"
.string_start_success:
	.asciz "_start: boot successful!...\n"

.section .text

#####################################################################
# Multiboot init
#####################################################################
.type multiboot_init, @function
multiboot_init:
	push %ebp
	movl %esp, %ebp

	pushl $0x0F                              # Set VGA colour to black/white
	call vga_text_set_colours
	call vga_text_clear
	addl $4, %esp

	pushl $.string_boot_init
	call vga_text_print
	addl $4, %esp

	movl $multiboot_magic, %eax              # Load multiboot magic address into EAX.
	cmpl $0x2BADB002, (%eax)                 # Compare against expected value.
	jne .multiboot_init_invalid_identity

	pushl $.string_boot_success
	call vga_text_print
	addl $4, %esp

	leave
	ret

.multiboot_init_invalid_identity:
	pushl $0x4F                              # Set VGA colours to red/white.
	call vga_text_set_colours
	popl %edx

	pushl $.string_boot_fail
	call vga_text_print
	popl %edx

	# Hang here if this fails.
	jmp kernel_hang


#####################################################################
# Copy Multiboot Data
#####################################################################
.global _start
.type copy_multiboot_data, @function
copy_multiboot_data:

# Copy the mmap to a reserved area of memory in bss.
.copy_multiboot_mmap:
	movl $KERNEL_VMA_OFFSET, %edx            # Store higher-half offset in EDX.
	movl $multiboot_info_ptr, %esi
	subl %edx, %esi                          # Subtract higher-half offset.

	movl (%esi), %esi                        # Copy pointer address into ESI.
	addl $44, %esi                           # Add offset to the mmap length.

	movl $multiboot_mmap_length, %edi        # Store length var address in EDI.
	movl (%esi), %eax                        # Copy length into reserved var.
	movl %eax, (%edi)                        # Copy length to address in EDI.

	movl %eax, %ecx                          # Copy length into ECX.
	movl $multiboot_reserved_start, %edi     # Move the reserved memory addr to EDI.

	addl $4, %esi                            # Increment ESI to point to mmap addr.
	movl (%esi), %eax                        # Move value contained at ESI to EAX.

	movl %eax, %esi                          # Move value back to ESI.

	movl $multiboot_mmap_addr, %eax          # Copy mmap target to EAX.
	movl %edi, (%eax)                        # Copy memory address to global var.

	rep movsb                                # Copy from ESI to EDI


.end_copy_multiboot_data:
	ret


#####################################################################
# Boot Entry point.
#####################################################################
.global _start
.type _start, @function
_start:
	cli

	# Store multiboot variables.
	movl $KERNEL_VMA_OFFSET, %edx            # Store higher-half offset in EDX.
	movl $multiboot_magic, %edi              # Store destination in EDI.
	subl %edx, %edi                          # Subtract higher-half offset.
	movl %eax, (%edi)                        # Copy multiboot magic number.

	movl $multiboot_info_ptr, %edi
	subl %edx, %edi
	movl %ebx, (%edi)

	# Setup initial kernel stack.
	# This will be moved to the final virtually mapped address after the boot paging
	# structures have been initialised and the higher-half jump has been performed.
	movl $kernel_stack_top, %eax
	subl %edx, %eax                          # Subtract higher-half offset.
	movl %eax, %esp                          # Move stack pointer to kernel stack top.

	call init_boot_page_directory

	# Load address of the page directory into CR3.
	movl $KERNEL_VMA_OFFSET, %ebx
	movl $boot_page_directory, %eax
	subl %ebx, %eax                          # Subtract higher-half offset.
	movl %eax, %cr3                          # Load page dir.

	# Enable paging and write-protect flag.
	movl %cr0, %ecx
	orl $0x80010000, %ecx
	movl %ecx, %cr0

	# Absolute jump to higher half.
	# The indirect call is necessary because by default the compiler will produce a
	# PC relative jump call.
	lea .higher_half_jump, %ecx
	jmp *%ecx

.higher_half_jump:
	# Setup stack now we're in the higher half.
	movl $0xFF404000, %esp

	# Validate multiboot info.
	call multiboot_init

	pushl $0x5F                              # Set VGA colours to purple/white
	call vga_text_set_colours
	addl $4, %esp

	pushl $.string_start_success
	call vga_text_print
	addl $4, %esp

	call copy_multiboot_data

	# Remove the lower-half indentity mapping.
	call remove_identity_mapping

	jmp kernel_init
