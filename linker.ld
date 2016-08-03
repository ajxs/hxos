ENTRY(_start)
SECTIONS {
	. = 0xC0100000;		/* 1MB begin section. */

	.text ALIGN(4K) : AT(ADDR(.text) - 0xC0000000) {
		*(.multiboot)
		*(.text)
	}

	.bss ALIGN(4K) : AT(ADDR(.bss) - 0xC0000000) {
		*(COMMON)
		*(.bss)
		kernel_end = .;
		page_tables_start = .;
		*(.page_tables)
	}
}
