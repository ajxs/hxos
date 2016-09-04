#include <boot.h>

.align 4
.section .multiboot
.long MULTIBOOT_HEADER_MAGIC
.long MULTIBOOT_HEADER_FLAGS
.long MULTIBOOT_HEADER_CHECKSUM


.align 4
.section .bss, "aw", @nobits
stack_bottom:
.skip STACK_SIZE
stack_top:

.global _page_directory
_page_directory:
	.skip 1024*4

.global _page_table_lower
_page_table_lower:
	.skip 1024*4

.section .text


.global _color
.type _color, @function
_color:
	push %ebp				# Preamble: save the old %ebp.
	movl %esp, %ebp			# Point %ebp to the saved %ebp and the new stack frame.

	subl $0x4, %esp			# Reserve space for local variables. move esp back 4

	movl 0x8(%ebp), %ebx
	movl %ebx, -0x4(%ebp)	# Move argument into local variable.

	movb $0, %al
	movb %bl, %ah
	movl $2000, %ecx
	movl $0xB8000, %edi
	rep stosw
	#STOre String Word
	# Repeat %cx times, store %eax at
	# address %di and increase %di by 4.

	addl $0x4, %esp			# Reclaim space used by local variables.
	pop %ebp				# Epilogue: restore the old %ebp

	ret

.global _gdt_flush
.type _gdt_flush, @function
_gdt_flush:
	movl (gp), %eax
	subl $KERNEL_VIRTUAL_BASE, %eax
	lgdt (%eax)

	pushl $0x6F		#brown
	call _color

	ljmp $0x8, $(_gdt_complete_flush - KERNEL_VIRTUAL_BASE)
_gdt_complete_flush:

	pushl $0x8F		#brown
	call _color
	hlt

	mov $0x10, %eax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
	ret


.global _paging_enable
.type _paging_enable, @function
_paging_enable:
	movl %esp, %ebp
	movl %cr0, %eax
	orl $0x80000000, %eax
	movl %eax, %cr0
	movl %ebp, %esp		#restore stack pointer
	ret

.global _paging_init
.type _paging_init, @function
_paging_init:
	movl %esp, %ebp
	movl $(_page_directory - KERNEL_VIRTUAL_BASE), %eax		# Store address of page directory in eax, move to CR3
	movl %eax, %cr3
	movl %ebp, %esp
	ret

.global _paging_init_lowest_table
.type _paging_init_lowest_table, @function
_paging_init_lowest_table:

	movl $0, %eax
	movl $(_page_table_lower - KERNEL_VIRTUAL_BASE), %ebx
	movl $1024, %ecx
	.page_table_lower_loop:
		addl $0x7, %eax			#0b111
		addl $4096, %eax
		movl %eax, (%ebx)
		addl $4, %ebx
		loop .page_table_lower_loop

	movl $(_page_directory - KERNEL_VIRTUAL_BASE), %eax		# add low table to dir
	movl $(_page_table_lower - KERNEL_VIRTUAL_BASE), %ebx
	movl %ebx, (%eax)

	movl $(_page_directory - KERNEL_VIRTUAL_BASE), %ebx
	movl $1024, %ecx
	.page_directory_loop:
		movl $0, (%ebx)
		addl $4, %ebx
		loop .page_directory_loop

	movl $(_page_directory - KERNEL_VIRTUAL_BASE), %ebx
	movl $3, (%ebx)

	ret

.global _test_page_fault
.type _test_page_fault, @function
_test_page_fault:
	andb $0xFE, (_page_table_lower)
	movb $0, 0
	ret

.global _start
.type _start, @function
_start:
	cli

	movl $0x2BADB002, %ecx
	cmpl %eax, %ecx
	jne _multiboot_fail

	movl $(stack_top), %esp
	subl $KERNEL_VIRTUAL_BASE, %esp

	pushl $0x2F		#green
	call _color

	#call gdt_install
	#call _gdt_flush

	call _paging_init_lowest_table
	call _paging_init

	pushl $0x3F
	call _color

	call _protected_mode_init

.Lhang:
	jmp .Lhang

.size _start, . - _start		# Set size of the _start symbol to the current location '.' minus its start.


.global _protected_mode_init
.type _protected_mode_init, @function
_protected_mode_init:
	movl %cr0, %eax
	orl $0x1, %eax
	movl %eax, %cr0
	ljmp $0x0008, $(.PModeMain - KERNEL_VIRTUAL_BASE)

.PModeMain:
	sti

	mov $0x10, %eax		# reload segment registers
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
	movl $(stack_top - KERNEL_VIRTUAL_BASE), %esp

	pushl $0x5F
	call _color

	leal (_higher_half_start - KERNEL_VIRTUAL_BASE), %ecx
	jmp %ecx

	cli
	hlt

	jmp .Lhang

_higher_half_start:
	pushl $0x9F				# blue
	call _color
	cli
	hlt


.global _multiboot_fail
.type _multiboot_fail, @function
_multiboot_fail:
	pushl $0x4F
	call _color

	cli
	hlt
