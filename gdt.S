#include <gdt.h>

.align 4096
.section .data

string_gdt_init:
	.asciz "gdt_init: Loading GDT...\n"
string_gdt_reload:
	.asciz "gdt_init: Reloading segment registers...\n"

.global gdt_table                 # Hardcode GDT table
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
	.word gdt_table - gdt_end        # table size
	.long gdt_table                  # table offset

.section .text

.global gdt_init
gdt_init:
	pushl %ebp
	movl %esp, %ebp

	pushl $string_gdt_init
	call tty_print
	popl %edx

	lgdt gdt_ptr
	ljmp $0x8, $gdt_init_reload_cs
gdt_init_reload_cs:

	pushl $string_gdt_reload
	call tty_print
	popl %edx

	mov $0x10, %eax
	mov %ax, %ds                    # reload code segment registers
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	leave
	ret
