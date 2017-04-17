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

	movzbw 8(%ebp), %ax                    #move byte and zero remaining bits
	movsbw tty_col, %cx                    #create VGA entry from existing tty_col
	shlw $0x8, %cx
	orw %cx, %ax

	movw %ax, (%edx)
	popl %ebp
	ret


.global tty_print
.type tty_print, @function
tty_print:
	pushl %ebp
	movl %esp, %ebp
	subl $40, %esp

	movl $0, -16(%ebp)     # current string pos

	movl 8(%ebp), %eax     # string pointer
	movl %eax, (%esp)
	call tty_strlen
	movl %eax, -12(%ebp)   # save strlen at -12(%ebp)

	jmp	.tty_print_check

.tty_print_loop:
	movl 8(%ebp), %eax   # load string
	movl -16(%ebp), %ecx   # increment string counter
	addl %ecx, %eax
	movzbl (%eax), %eax

	movzwl tty_pos, %edx

	movl %edx, 4(%esp)   # tty_pos
	movl %eax, (%esp)    # char
	call tty_putchar

	movl tty_pos, %eax   # increment tty_pos
	leal 1(%eax), %edx
	movw %dx, tty_pos

	movl -16(%ebp), %eax    # inc current string pos
	leal 1(%eax), %ecx
	movl %ecx, -16(%ebp)

.tty_print_check:
	movl -16(%ebp), %eax
	cmpl -12(%ebp), %eax
	jl .tty_print_loop

	movl %ebp, %esp
	popl %ebp
	ret

.global	tty_strlen    #int strlen(const char *string);
tty_strlen:
	push %edi
	sub %ecx, %ecx
	mov 0x8(%esp), %edi
	not %ecx
	sub %al, %al
	cld
	repne scasb        #rep not equal scan strng byte
	not %ecx
	pop %edi
	leal -1(%ecx), %eax
	ret
