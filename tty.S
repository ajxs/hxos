#include <tty.h>

.section .bss

tty_pos:
	.long $0

tty_col:
	.byte $0

.section .text

.global _tty_clear_color
.type _tty_clear_color, @function
_tty_clear_color:
	push %ebp                # Save the old %ebp.
	movl %esp, %ebp          # Point %ebp to the new stack frame.

	movl 0x8(%ebp), %ebx     # Move argument into local variable.

	movb $0, %al
	movb %bl, %ah
	movl $FRAMEBUFFER_LENGTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
	rep stosw                #STOre String Word - Rep %cx times, mov %eax -> %edi, inc %edi by 2.

	pop %ebp                 # Restore the old %ebp
	ret


.global _tty_clear
.type _tty_clear, @function
_tty_clear:
	movb $0, %al
	movb tty_col, %ah
	movl $FRAMEBUFFER_LENGTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
	rep stosw
	ret

.global _tty_set_colors
.type _tty_set_colors, @function
_tty_set_colors:
	push %ebp
	movl %esp, %ebp

	movb 0x8(%ebp), %ah
	mov %ah, tty_col

	pop %ebp
	ret

.type _tty_putchar, @function
_tty_putchar:
	push %ebp
	movl %esp, %ebp

	pop %ebp
	ret

.global _tty_print
.type _tty_print, @function
_tty_print:
	push %ebp                # Save the old %ebp.
	movl %esp, %ebp          # Point %ebp to the new stack frame.

	pop %ebp
	ret
