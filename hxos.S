.section .bss

test_str:
	.asciz "Testing Framebuffer."

test_char:
	.byte 0x54

.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	pushl $0x3F    #cyan/white
	call tty_set_colors
	call tty_clear
	popl %edx

	pushl $0
	pushl $0x54
	call tty_putchar
	popl %edx
	popl %edx

.Lhang:
	jmp .Lhang
