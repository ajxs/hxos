.section .data

string_kernel_init:
	.asciz "kernel_init: beginning Kernel init...\n"

.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	push %ebp
	movl %esp, %ebp

	pushl $string_kernel_init
	call tty_print
	popl %edx

	call protected_mode_init
	call kernel_main

	movl %ebp, %esp
	popl %ebp

	cli
	hlt
