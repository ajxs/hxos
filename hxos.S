.section .data

test_str:
	.asciz "Testing Framebuffer."

test_char:
	.byte 0x53

.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	pushl $0x3F    #cyan/white
	call tty_set_colors
	call tty_clear
	popl %edx

	#pushl $0
	#pushl test_char
	#call tty_putchar
	#popl %edx
	#popl %edx

	pushl test_str
	call tty_print
	popl %edx

.Lhang:
	jmp .Lhang
