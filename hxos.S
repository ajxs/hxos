.section .data

test_str:
	.asciz "Test Line 1."

test_str2:
	.asciz "Test Line 2.\nSplit 2\n"

test_str3:
	.asciz "Test Line 3.\nSplit 3\nSplit 3\nSplit 3\n"

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

	pushl $0x4E    #cyan/white
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str3
	call tty_print
	popl %edx

	pushl $0x5E    #purple/yellow
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str3
	call tty_print
	popl %edx

	pushl $0x6D    #brown/pink
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str3
	call tty_print
	popl %edx

	pushl $0x4D    #brown/pink
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str3
	call tty_print
	popl %edx

	pushl $0x2E    #green
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

	pushl $test_str3
	call tty_print
	popl %edx

	pushl $0x5E    #purple/yellow
	call tty_set_colors
	popl %edx

	pushl $test_str
	call tty_print
	popl %edx

.Lhang:
	jmp .Lhang
