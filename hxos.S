.section .data

string_kernel_init:
	.asciz "kernel_init: beginning Kernel init...\n"
string_main_init:
	.asciz "kernel_main: Kernel init successful!...\n"
string_main_next:
	.asciz "kernel_main: Halted awaiting useful instructions!...\n"


.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	push %ebp
	movl %esp, %ebp

	pushl $string_kernel_init
	call vga_text_print
	popl %edx

	call protected_mode_init
	call kernel_main

	leave                      # cleanup state here
	cli
	hlt

.global kernel_hang
kernel_hang:
	jmp kernel_hang

.global kernel_main
.type kernel_main, @function
kernel_main:
	pushl $0x5F                # purple/white
	call vga_text_set_colours
	popl %edx

	pushl $string_main_init
	call vga_text_print
	popl %edx

	pushl $0x6E                # black/white
	call vga_text_set_colours
	popl %edx

	pushl $string_main_next
	call vga_text_print
	popl %edx

	ret
