ENTRY(_start)
KERNEL_BOOT_BASE = 0x00100000;
KERNEL_VIRTUAL_BASE = 0xC0000000;
SECTIONS {
	. = 0xC0100000;

	.text ALIGN(4K) : AT(ADDR(.text) - 0xC0000000) {
		_section_text = .;
		*(.multiboot)
		*(.text)
	}

	.data ALIGN(4K) : AT(ADDR(.data) - 0xC0000000) {
		_section_data = .;
		*.(.data)
	}

	.bss ALIGN(4K) : AT(ADDR(.bss) - 0xC0000000) {
		*(COMMON)
		*(.bss)
		kernel_end = .;
	}
}
