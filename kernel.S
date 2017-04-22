#include <hxos.h>

.section .data

test_str:
	.asciz "Test Line 1."

test_str2:
	.asciz "Test Line 2.\nSplit 2\n"

test_str3:
	.asciz "Test Line 3.\nSplit 3\nSplit 3\nSplit 3\n"

.section .text

.global protected_mode_init
.type protected_mode_init, @function
protected_mode_init:
	push %ebp
	movl %esp, %ebp

	movl %cr0, %eax
	orl $0x1, %eax
	movl %eax, %cr0
	ljmp $0x8, $.protected_mode_init_reload

.protected_mode_init_reload:
	sti

	mov $0x10, %eax              # reload segment registers
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	movl $stack_top, %esp

	movl %ebp, %esp
	popl %ebp
	ret


.global kernel_main
.type kernel_main, @function
kernel_main:
	push %ebp
	movl %esp, %ebp

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

	movl %ebp, %esp
	popl %ebp
	ret
