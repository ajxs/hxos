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

# void tty_putchar(uint8_t c, uint8_t pos);
# @TODO: improve this - even though it matches gcc -S output... investigate
.global tty_putchar
.type tty_putchar, @function
tty_putchar:
	pushl %ebp
	movl %esp, %ebp

	movl 12(%ebp), %edx                    #pos
	addl %edx, %edx                        #double pos to take 16bit width into account
	addl $FRAMEBUFFER_ADDR, %edx

	movzbw 8(%ebp), %ax
	movsbw tty_col, %cx                    #create VGA entry from existing tty_col
	shlw $0x8, %cx
	orw %cx, %ax

	movw %ax, (%edx)
	popl %ebp
	ret


.global tty_print
.type tty_print, @function
tty_print:
	pushl %ebp                # Save the old %ebp.
	movl %esp, %ebp          # Point %ebp to the new stack frame.

	movl 8(%ebp), %eax
	#movl $0x53, %eax
	#movzbl 12(%eax), %ebx
	#movl (%eax), %ebx
	pushl $0
	pushl %eax
	call tty_putchar
	popl %edx
	popl %edx

	pop %ebp
	ret


.global	tty_strlen    #int strlen(const char *string);
tty_strlen:
	push %edi
	sub %ecx, %ecx
	mov 0x8(%esp), %edi
	not %ecx
	sub %al, %al
	cld
repne scasb
	not %ecx
	pop %edi
	leal -1(%ecx), %eax
	ret
