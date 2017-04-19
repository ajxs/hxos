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

	movl 12(%ebp), %edx                  #pos
	addl %edx, %edx                      #double pos to take 16bit width into account
	addl $FRAMEBUFFER_ADDR, %edx

	movzbw 8(%ebp), %ax                  #move byte and zero remaining bits
	movsbw tty_col, %cx                  #create VGA entry from existing tty_col
	shlw $0x8, %cx
	orw %cx, %ax

	movw %ax, (%edx)
	popl %ebp
	ret

.type tty_newline, @function
tty_newline:
	pushl %ebp
	movl %esp, %ebp

	xorl %edx, %edx
	movw $FRAMEBUFFER_WIDTH, %bx
	movw tty_pos, %ax
	divw %bx                             # remainder in EDX

	subw %dx, %bx
	jmp .tty_newline_fill

.tty_newline_reset:                    # reset tty_pos to 0
	movw $0, tty_pos
	jmp .tty_newline_exit

.tty_newline_fill:
	movb $0, %al
	movb tty_col, %ah

	movw %bx, %cx

	movl $FRAMEBUFFER_ADDR, %edi
	addw tty_pos, %di                    # ∵ tty_pos != byte pos
	addw tty_pos, %di

	rep stosw                            # clear remainder of line

	addw tty_pos, %bx
	movw %bx, tty_pos

	cmpw $FRAMEBUFFER_LENGTH, %bx        # check tty_pos against 0
	je .tty_newline_reset

.tty_newline_exit:
	movl %ebp, %esp
	popl %ebp
	ret


.global tty_print
.type tty_print, @function
tty_print:
	pushl %ebp
	movl %esp, %ebp
	subl $40, %esp

	movl $0, -16(%ebp)                   # current string pos

	movl 8(%ebp), %eax                   # string ptr
	movl %eax, (%esp)
	call tty_strlen
	movl %eax, -12(%ebp)                 # save strlen at -12(%ebp)

	jmp .tty_print_check

.tty_print_reset:
	movw $0, tty_pos
	jmp .tty_print_inc

.tty_print_loop:
	movl 8(%ebp), %eax                   # load ptr to start of string ( arg )
	movl -16(%ebp), %ecx                 # increment string counter
	addl %ecx, %eax
	movzbl (%eax), %eax

	cmpl $0xA, %eax                      # check for newline
	jne .tty_print_putchar

.tty_print_newline:
	call tty_newline
	jmp .tty_print_inc                   # If \n don't increment tty_pos

.tty_print_putchar:
	movzwl tty_pos, %edx
	movl %edx, 4(%esp)                   # tty_pos
	movl %eax, (%esp)                    # char
	call tty_putchar

	incw tty_pos

	cmpw $FRAMEBUFFER_LENGTH, %dx        # check tty_pos against 0
	je .tty_print_reset

.tty_print_inc:
	incw -16(%ebp)                       # inc current string pos

.tty_print_check:
	movl -16(%ebp), %eax
	cmpl -12(%ebp), %eax
	jl .tty_print_loop

	movl %ebp, %esp
	popl %ebp
	ret

.global tty_strlen                    #int strlen(const char *string);
tty_strlen:
	push %edi
	sub %ecx, %ecx
	mov 0x8(%esp), %edi
	not %ecx
	sub %al, %al
	cld
	repne scasb                         #rep not equal scan strng byte
	not %ecx
	pop %edi
	leal -1(%ecx), %eax
	ret
