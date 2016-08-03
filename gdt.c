#include <stddef.h>
#include <stdint.h>
#include <gdt.h>
#include <boot.h>

gdt_descr_t gdt[GDT_TABLE_SIZE];
gdt_ptr_t gp;

void gdt_set_gate(uint8_t num, uint32_t base, uint32_t limit, uint8_t access, uint8_t flags) {
	gdt[num].limit_low = (limit & 0xFFFF);
	gdt[num].base_low = (base & 0xFFFF);
	gdt[num].base_middle = (base >> 16) & 0xFF;
	gdt[num].access = access;

	gdt[num].limit_high_flags = (flags >> 16) & 0xF;		// flags
	gdt[num].limit_high_flags |= (limit & 0xF0);		// limit high

	gdt[num].base_high = (base >> 24) & 0xFF;
};


void gdt_install(void) {
	gp.limit = (uint16_t)(sizeof(gdt_descr_t) * GDT_TABLE_SIZE) - 1;
	gp.base = ((uint32_t)&gdt) - KERNEL_VIRTUAL_BASE;

	gdt_set_gate(0, 0, 0, 0, 0);		// NULL descriptor
	gdt_set_gate(1, 0, 0xFFFFFFFF, GDT_ACCESS_CODE_PL0, GDT_FLAGS);
	gdt_set_gate(2, 0, 0xFFFFFFFF, GDT_ACCESS_DATA_PL0, GDT_FLAGS);
	gdt_set_gate(3, 0, 0xFFFFFFFF, GDT_ACCESS_CODE_PL3, GDT_FLAGS);
	gdt_set_gate(4, 0, 0xFFFFFFFF, GDT_ACCESS_DATA_PL3, GDT_FLAGS);
};
