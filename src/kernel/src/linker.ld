ENTRY (_start)

SECTIONS
{
	KERNEL_VMA_START = 0xC0000000;
	. = 0xC0100000;

	kernel_start = .;
	.text ALIGN (4K) : AT (ADDR (.text) - KERNEL_VMA_START)
	{
		*(.multiboot)
		*(.text)
	}

	.rodata ALIGN (4K) : AT (ADDR (.rodata) - KERNEL_VMA_START)
	{
		*(.rodata)
	}

	.data ALIGN (4K) : AT (ADDR (.data) - KERNEL_VMA_START)
	{
		*(.data)
	}

	.bss ALIGN (4K) : AT (ADDR (.bss) - KERNEL_VMA_START)
	{
		*(COMMON)
		*(.bss)
	}
	kernel_end = .;
}

