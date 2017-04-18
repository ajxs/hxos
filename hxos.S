.section .data

test_str:
	.asciz "Testing Framebuffer."

test_str2:
	.asciz "And another thing.\n"

test_str3:
	.asciz "Mid split.\nNewline.\n"

.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	pushl $0x3F    #cyan/white
	call tty_set_colors
	popl %edx

	call tty_clear

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str2
	call tty_print
	popl %edx

	pushl $0x3E    #cyan/white
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str3
	call tty_print
	popl %edx

.Lhang:
	jmp .Lhang
