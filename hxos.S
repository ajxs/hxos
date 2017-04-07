.section .text

.global _kernel_init
.type _kernel_init, @function
_kernel_init:
	pushl $0x3F    #cyan/white
	call _tty_set_colors
	call _tty_clear

.Lhang:
	jmp .Lhang
