.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	pushl $0x3F    #cyan/white
	call tty_set_colors
	call tty_clear
	popl %edx

	pushl $0x4
	pushl $0x53
	call tty_putchar
	popl %edx
	popl %edx
	
	pushl $0x5
	pushl $0x53
	call tty_putchar
	popl %edx
	popl %edx

.Lhang:
	jmp .Lhang
