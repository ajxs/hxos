.section .data

string_serial_init:
	.asciz "serial_init: beginning serial init...\n"
string_serial_init_success:
	.asciz "serial_putchar: successful serial init...\n"

serial_com1_base:
	.long $0x3F8
serial_com2_base:
	.long $0x2F8
serial_com3_base:
	.long $0x3E8
serial_com4_base:
	.long $0x2E8    # ?

.section .text

# void serial_init(void);
.global serial_init
.type serial_init, @function
serial_init:
ret


# void serial_init_port(uint8_t port);
.global serial_init_port
.type serial_init_port, @function
serial_init_port:
pushl %ebp
movl %esp, %ebp
pushl %eax
pushl %ebx

movzbl 0x8(%ebp), %eax
lea 1(%eax), %ebx    # store data port
outb $0, (%ebx)      # send 0 to data port 

popl %ebx
popl %eax
leave
ret


# void serial_putchar(uint8_t c);
.global serial_putchar
.type serial_putchar, @function
serial_putchar:
pushl %ebp
movl %esp, %ebp
pushl %eax

movb 0x8(%ebp), %ah
# mov %ah, tty_col

popl %eax
leave
ret
