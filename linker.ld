ENTRY(_start)
SECTIONS {
	. = 0x00100000;

	.text BLOCK(4K) : ALIGN(4K) {
		*(.multiboot)
		*(.text)
	}

	.bss BLOCK(4K) : ALIGN(4K) {
		*(COMMON)
		*(.bss)
	}

}
