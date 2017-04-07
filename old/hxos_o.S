#include <boot.h>

.align 4096
.section .multiboot
.long MULTIBOOT_HEADER_MAGIC
.long MULTIBOOT_HEADER_FLAGS
.long MULTIBOOT_HEADER_CHECKSUM


.align 4096
.section .bss, "aw", @nobits		#section contains no data, unallocated space
stack_bottom:
.skip STACK_SIZE
stack_top:

.global _page_directory
_page_directory:
	.skip 1024*4

.global _pte_low
_pte_low:
	.skip 1024*4

.global _page_tables
_page_tables:
	.skip 1024*4*4



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
	# address %di and increase %di by 2.

	addl $0x4, %esp			# Reclaim space used by local variables.
	pop %ebp				# Epilogue: restore the old %ebp

	ret


.global _pde_init
.type _pde_init, @function
_pde_init:
	movl $1024, %ecx
	movl $6, %eax				# flags 0b110
	leal _page_directory, %edi
#	subl $KERNEL_VIRTUAL_BASE, %edi
	rep stosl

#	leal (_page_directory - KERNEL_VIRTUAL_BASE), %eax
#	leal (_pte_low - KERNEL_VIRTUAL_BASE), %ebx
	leal _page_directory, %eax
#	leal _pte_low, %ebx
	leal _page_tables, %ebx
	mov $0x4, %ecx

	._pde_init_loop:
		orl $0x7, %ebx					# set flags 0b111
		movl %ebx, (%eax)

		addl $4, %eax
		addl $4096, %ebx

		loop ._pde_init_loop



	ret


.global _pte_init
.type _pte_init, @function
_pte_init:
#	leal (_pte_low - KERNEL_VIRTUAL_BASE), %ebx
#	leal _pte_low, %ebx

#	movl $0, %eax
#	movl $1024, %ecx
#	._pte_low_init_loop:
#		orl $0x7, %eax			#set flags: 0b111
#		movl %eax, (%ebx)
#
#		addl $4096, %eax
#		addl $4, %ebx
#		loop ._pte_low_init_loop

	leal _page_tables, %ebx
	movl $0, %eax
	movl $4096, %ecx
	._pte_init_loop:
		orl $0x7, %eax			#set flags: 0b111
		movl %eax, (%ebx)

		addl $4096, %eax
		addl $4, %ebx
		loop ._pte_init_loop


	ret




.global _paging_enable
.type _paging_enable, @function
_paging_enable:
	movl %esp, %ebp


#	leal (_page_directory - KERNEL_VIRTUAL_BASE), %eax
	leal _page_directory, %eax
	movl %eax, %cr3

	movl %cr0, %eax
	orl $0x80000000, %eax
	movl %eax, %cr0

	pushl $0xFF				# white
	call _color
	hlt

	movl %ebp, %esp		#restore stack pointer

	ret


.global _start
.type _start, @function
_start:
	cli

	movl $0x2BADB002, %ecx
	cmpl %eax, %ecx
	jne _multiboot_fail

	movl $stack_top, %esp
#	subl $KERNEL_VIRTUAL_BASE, %esp

	pushl $0x2F		#green
	call _color

	call _protected_mode_init

	#	leal (_higher_half_start - KERNEL_VIRTUAL_BASE), %ecx
	#	#leal _higher_half_start, %ecx
	#	jmp %ecx


.Lhang:
	jmp .Lhang

.size _start, . - _start		# Set size of the _start symbol to the current location '.' minus its start.


.global _protected_mode_init
.type _protected_mode_init, @function
_protected_mode_init:
	movl %cr0, %eax
	orl $0x1, %eax
	movl %eax, %cr0
	ljmp $0x0008, $.PModeMain

.PModeMain:
	sti

	mov $0x10, %eax		# reload segment registers
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

#	movl $(stack_top - KERNEL_VIRTUAL_BASE), %esp
	movl $stack_top, %esp

	pushl $0x5F		# pink
	call _color


	call _pte_init
	call _pde_init
	call _paging_enable

	pushl $0x3F		# turquoise
	call _color


	cli
	hlt

	jmp .Lhang

_higher_half_start:
	pushl $0x1F				# dark blue
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
