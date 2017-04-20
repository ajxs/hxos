.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	push %ebp
	movl %esp, %ebp

	call protected_mode_init
	call kernel_main

	movl %ebp, %esp
	popl %ebp

	cli
	hlt
