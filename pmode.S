.section .data

string_pmode_init:
	.asciz "protected_mode_init: beginning pmode init...\n"
string_pmode_success:
	.asciz "protected_mode_init: pmode successfully initialised...\n"

.section .text

.global protected_mode_init
.type protected_mode_init, @function
protected_mode_init:
	push %ebp
	movl %esp, %ebp

	pushl $string_pmode_init
	call tty_print
	popl %edx

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

	pushl $string_pmode_success
	call tty_print
	popl %edx

	leave
	ret
