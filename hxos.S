.section .text

.global kernel_init
.type kernel_init, @function
kernel_init:
	pushl $0x3F    #cyan/white
	call tty_set_colors
	call tty_clear

.Lhang:
	jmp .Lhang
