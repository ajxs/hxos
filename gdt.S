#include <gdt.h>

.align 4096
.section .data

.global gdt_table
gdt_table:
gdt_null:
	.long 0
	.long 0
gdt_code:
	.word 0xFFFF
	.word 0
	.byte 0
	.byte GDT_ACCESS_CODE_PL0
	.byte GDT_FLAG_LIMIT_BYTE
	.byte 0
gdt_data:
	.word 0xFFFF
	.word 0
	.byte 0
	.byte GDT_ACCESS_DATA_PL0
	.byte GDT_FLAG_LIMIT_BYTE
	.byte 0
gdt_misc:
	.word 0xFFFF
	.word 0
	.byte 0
	.byte GDT_ACCESS_CODE_PL3
	.byte GDT_FLAG_LIMIT_BYTE
	.byte 0
gdt_misc2:
	.word 0xFFFF
	.word 0
	.byte 0
	.byte GDT_ACCESS_DATA_PL3
	.byte GDT_FLAG_LIMIT_BYTE
	.byte 0
gdt_end:

gdt_ptr:
	.word gdt_table - gdt_end
	.long gdt_table

.section .text

.global gdt_init
gdt_init:
	pushl	%ebp
	movl	%esp, %ebp

	pushl $0x3F    #cyan/white
	call tty_set_colors
	call tty_clear
	popl %edx

	lgdt gdt_ptr
	ljmp $0x8, $gdt_init_flush
gdt_init_flush:
	mov $0x10, %eax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	movl %ebp, %esp
	popl %ebp
	ret
