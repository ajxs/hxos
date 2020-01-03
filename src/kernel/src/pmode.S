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

string_pmode_init:
	.asciz "protected_mode_init: beginning pmode init...\n"
string_pmode_success:
	.asciz "protected_mode_init: pmode successfully initialised...\n"

.section .text

#####################################################################
# Protected Mode Init
#
# Loads the processor into protected mode and reloads the segment
# registers. Ideally, the processor will already be placed in pmode
# by GRUB, but this is done to ensure a predictable processor state.
#####################################################################
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
	# As per section 9.9 of the Intel SDM Vol.3A: Execute the far jump immediately
	# after updating the value of CR0 to avoid random failures.
	ljmp $0x8, $.protected_mode_init_reload

.protected_mode_init_reload:
	sti

	# reload segment registers.
	# Section 9.9 of the Intel SDM Vol. 3A advises to either manually reload the
	# segment registers as is done here, or use a CALL instruction.
	mov $0x10, %eax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	pushl $string_pmode_success
	call vga_text_print
	addl $4, %esp

	leave
	ret
