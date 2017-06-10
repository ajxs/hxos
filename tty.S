#include <tty.h>

.section .bss

tty_pos:
	.long $0

tty_col:
	.byte $0

.section .text

# void tty_clear();
.global tty_clear
.type tty_clear, @function
tty_clear:
	pushl %edi                          # preserve EDI
	movb $0, %al
	movb tty_col, %ah
	movl $FRAMEBUFFER_LENGTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
	rep stosw
	movw $0, tty_pos
	popl %edi
	ret

# void tty_set_colors(uint16_t c);
.global tty_set_colors
.type tty_set_colors, @function
tty_set_colors:
	pushl %ebp
	movl %esp, %ebp
	pushl %eax

	movb 0x8(%ebp), %ah
	mov %ah, tty_col

	popl %eax
	leave
	ret

# void tty_putchar(uint8_t c, uint8_t pos);
.global tty_putchar
.type tty_putchar, @function
tty_putchar:
	pushl %ebp
	movl %esp, %ebp
	pushl %edx

	movl 12(%ebp), %edx                  #pos
	addl %edx, %edx                      #double pos to take 16bit width into account
	addl $FRAMEBUFFER_ADDR, %edx

	movzbw 8(%ebp), %ax                  #move byte and zero remaining bits
	movsbw tty_col, %cx                  #create VGA entry from existing tty_col
	shlw $0x8, %cx
	orw %cx, %ax

	movw %ax, (%edx)

	popl %edx
	leave
	ret


# void tty_shift();
.type tty_shift, @function
tty_shift:
	pushl %ebp
	movl %esp, %ebp
	pushl %edi

	movl $FRAMEBUFFER_LENGTH-FRAMEBUFFER_WIDTH, %ecx
	movl $FRAMEBUFFER_ADDR, %edi
.tty_shift_loop:
	movl FRAMEBUFFER_WIDTH*2(%edi), %eax
	stosw
	loop .tty_shift_loop                 # copy framebuffer up one line

	popl %edi
	leave
	ret

# void tty_newline();
.type tty_newline, @function
tty_newline:
	pushl %ebp
	movl %esp, %ebp
	pushl %edi
	pushl %ebx

	xorl %edx, %edx
	movw $FRAMEBUFFER_WIDTH, %bx
	movw tty_pos, %ax
	divw %bx                             # remainder in EDX

	subw %dx, %bx
	jmp .tty_newline_fill

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
	jne .tty_newline_exit
	call tty_shift                       # if equal, shift

.tty_newline_exit:
	popl %ebx
	popl %edi
	leave
	ret

# void tty_print(const char *c);
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

	incw tty_pos                         # increment tty_pos

	cmpw $FRAMEBUFFER_LENGTH, %dx        # check tty_pos against buffer length
	jne .tty_print_inc
	call tty_shift                       # if equal, shift

.tty_print_inc:
	incw -16(%ebp)                       # inc current string pos

.tty_print_check:
	movl -16(%ebp), %eax
	cmpl -12(%ebp), %eax
	jl .tty_print_loop

	leave
	ret


# int tty_strlen(const char *c);
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
