#include <boot.h>
#define STACK_SIZE 0x4000

.align 4096
.section .multiboot
.long MULTIBOOT_HEADER_MAGIC
.long MULTIBOOT_HEADER_FLAGS
.long MULTIBOOT_HEADER_CHECKSUM

.align 4096
.section .bss, "aw", @nobits
stack_bottom:
	.skip STACK_SIZE
stack_top:

_page_directory:
	.skip 1024*4

.section .text

.type _multiboot_fail, @function
_multiboot_fail:
	pushl $0x4F
	call _color
	cli
	hlt

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
	rep stosw		#STOre String Word - Rep %cx times, mov %eax -> (%di, inc %di by 2.

	addl $0x4, %esp			# Reclaim space used by local variables.
	pop %ebp				# End: restore the old %ebp

	ret

.global _start
.type _start, @function
_start:
	cli

	movl $0x2BADB002, %ecx
	cmpl %eax, %ecx
	jne _multiboot_fail

	movl $stack_top, %esp

	pushl $0x2F		#green
	call _color

.Lhang:
	jmp .Lhang
