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

#include <vga.h>

.section .bss

vga_text_pos:
	.skip 4

vga_text_col:
	.skip 1

.section .text

#####################################################################
# void vga_text_clear();
#####################################################################
.global vga_text_clear
.type vga_text_clear, @function
vga_text_clear:
	pushl %edi                               # preserve EDI
	movb $0, %al
	movb vga_text_col, %ah
	movl $FRAMEBUFFER_LENGTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
	rep stosw
	movw $0, vga_text_pos
	popl %edi
	ret


#####################################################################
# void vga_text_set_colours(uint16_t c);
#####################################################################
.global vga_text_set_colours
.type vga_text_set_colours, @function
vga_text_set_colours:
	pushl %ebp
	movl %esp, %ebp

	movb 0x8(%ebp), %ah
	mov %ah, vga_text_col

	leave
	ret


#####################################################################
# void vga_text_putchar(uint8_t c, uint8_t pos);
#####################################################################
.global vga_text_putchar
.type vga_text_putchar, @function
vga_text_putchar:
	pushl %ebp
	movl %esp, %ebp
	pushl %edx

	movl 12(%ebp), %edx                      # pos
	addl %edx, %edx                          # Double pos for 16-bit char width.
	addl $FRAMEBUFFER_ADDR, %edx

	movzbw 8(%ebp), %ax                      # Move byte and zero remaining bits.
	movsbw vga_text_col, %cx                 # Create VGA entry from vga_text_col.
	shlw $0x8, %cx
	orw %cx, %ax

	movw %ax, (%edx)

	popl %edx
	leave
	ret


#####################################################################
# void vga_text_shift();
#####################################################################
.type vga_text_shift, @function
vga_text_shift:
	pushl %edi

	movl $FRAMEBUFFER_LENGTH-FRAMEBUFFER_WIDTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
.vga_text_shift_loop:
	movl FRAMEBUFFER_WIDTH*2(%edi), %eax
	stosw
	loop .vga_text_shift_loop                # copy framebuffer up one line

	popl %edi
	ret


#####################################################################
# void vga_text_newline();
#####################################################################
.type vga_text_newline, @function
vga_text_newline:
	pushl %edi
	pushl %ebx

	xorl %edx, %edx
	movw $FRAMEBUFFER_WIDTH, %bx
	movw vga_text_pos, %ax
	divw %bx                                 # Remainder stored in EDX.

	subw %dx, %bx
	jmp .vga_text_newline_fill

.vga_text_newline_fill:
	movb $0, %al
	movb vga_text_col, %ah

	movw %bx, %cx

	movl $FRAMEBUFFER_ADDR, %edi
	addw vga_text_pos, %di                   # Therefore, vga_text_pos != byte pos.
	addw vga_text_pos, %di

	rep stosw                                # Clear remainder of line.

	addw vga_text_pos, %bx
	movw %bx, vga_text_pos

	cmpw $FRAMEBUFFER_LENGTH, %bx            # Check vga_text_pos against 0.
	jne .vga_text_newline_exit
	call vga_text_shift                      # If equal, shift.

.vga_text_newline_exit:
	popl %ebx
	popl %edi
	ret


#####################################################################
# void vga_text_print(const char *c);
#####################################################################
.global vga_text_print
.type vga_text_print, @function
vga_text_print:
	pushl %ebp
	movl %esp, %ebp

	subl $40, %esp

	movl $0, -16(%ebp)                       # current string pos

	movl 8(%ebp), %eax                       # string ptr
	movl %eax, (%esp)
	call vga_text_strlen
	movl %eax, -12(%ebp)                     # save strlen at -12(%ebp)

	jmp .vga_text_print_check

.vga_text_print_loop:
	movl 8(%ebp), %eax                       # load ptr to start of string ( arg )
	movl -16(%ebp), %ecx                     # increment string counter
	addl %ecx, %eax
	movzbl (%eax), %eax

	cmpl $0xA, %eax                          # check for newline
	jne .vga_text_print_putchar

.vga_text_print_newline:
	call vga_text_newline
	jmp .vga_text_print_inc                  # If \n don't increment vga_text_pos

.vga_text_print_putchar:
	movzwl vga_text_pos, %edx
	movl %edx, 4(%esp)                       # vga_text_pos
	movl %eax, (%esp)                        # char
	call vga_text_putchar

	incw vga_text_pos                        # increment vga_text_pos

	cmpw $FRAMEBUFFER_LENGTH, %dx            # check vga_text_pos against buffer length
	jne .vga_text_print_inc
	call vga_text_shift                      # if equal, shift

.vga_text_print_inc:
	incw -16(%ebp)                           # inc current string pos

.vga_text_print_check:
	movl -16(%ebp), %eax
	cmpl -12(%ebp), %eax
	jl .vga_text_print_loop

	addl $40, %esp
	leave
	ret


#####################################################################
# int vga_text_strlen(const char *c);
#####################################################################
.global vga_text_strlen                    # int strlen(const char *string);
vga_text_strlen:
	push %edi

	sub %ecx, %ecx
	mov 0x8(%esp), %edi
	not %ecx
	sub %al, %al
	cld
	repne scasb                              # rep not equal scan strng byte
	not %ecx

	pop %edi
	leal -1(%ecx), %eax
	ret
