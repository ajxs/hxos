#include <tty.h>

.section .bss

tty_pos:
	.long $0

tty_col:
	.byte $0

.section .text

.global tty_clear
.type tty_clear, @function
tty_clear:
	movb $0, %al
	movb tty_col, %ah
	movl $FRAMEBUFFER_LENGTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
	rep stosw
	ret

.global tty_set_colors
.type tty_set_colors, @function
tty_set_colors:
	push %ebp
	movl %esp, %ebp

	movb 0x8(%ebp), %ah
	mov %ah, tty_col

	pop %ebp
	ret

.type tty_putchar, @function
tty_putchar:
	push %ebp
	movl %esp, %ebp

	pop %ebp
	ret

.global tty_print
.type tty_print, @function
tty_print:
	push %ebp                # Save the old %ebp.
	movl %esp, %ebp          # Point %ebp to the new stack frame.

	pop %ebp
	ret


global	strlen    #int strlen(const char *string);
strlen:
	push %edi
	sub %ecx, %ecx
	mov 0x8(%esp)
	not %ecx
	sub %al, %al
	cld
repne scasb
	not %ecx
	pop %edi
	leal -1(%ecx), %eax
	ret
