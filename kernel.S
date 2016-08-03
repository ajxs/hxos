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

.section .text


.global _color
.type _color, @function
_color:
	push %ebp				# Preamble: save the old %ebp.
	movl %esp, %ebp			# Point %ebp to the saved %ebp and the new stack frame.

	subl $0x4, %esp			# Reserve space for local variables.

	movl 0x8(%ebp), %eax
	movl %eax, -0x4(%ebp)	# Move argument into local variable.

	movl $0xB8000, %ebx
	movl $2000, %ecx
	.colorOutput:
		movb $0, (%ebx)
		movb %al, 1(%ebx)
		add $2, %ebx
	loop .colorOutput

	addl $0x4, %esp			# Reclaim space used by local variables.
	pop %ebp				# Epilogue: restore the old %ebp

	ret


.global _gdt_flush
.type _gdt_flush, @function
_gdt_flush:
	#lgdt (gp - KERNEL_VIRTUAL_BASE)
	ljmp $0x8, $(_gdt_complete_flush - KERNEL_VIRTUAL_BASE)
_gdt_complete_flush:
	mov $0x10, %eax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
	ret


.global _start
.type _start, @function
_start:
	cli

	movl $0x2BADB002, %ecx
	cmpl %eax, %ecx
	jne _multiboot_fail

	movl $(stack_top - KERNEL_VIRTUAL_BASE), %esp

	pushl $0x2F
	call _color

	# protected mode
	movl %cr0, %eax
	orl $1, %eax
	movl %eax, %cr0

	pushl $0x3F
	call _color

	call gdt_install
	call _gdt_flush

	pushl $0x5F
	call _color

	cli
	hlt
.Lhang:
	jmp .Lhang

.size _start, . - _start		# Set size of the _start symbol to the current location '.' minus its start.


.global _higher_half_start
.type _higher_half_start, @function
_higher_half_start:
	cli
	hlt


.global _multiboot_fail
.type _multiboot_fail, @function
_multiboot_fail:
	pushl $0x4F
	call _color

	cli
	hlt
