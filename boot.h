/*
*	Bootloader specific header:
*	Included in bootloader
*/

#ifndef BOOT_H
#define BOOT_H 1

#define MULTIBOOT_HEADER_FLAGS 0x00000003

#define MULTIBOOT_SEARCH 8192		/* How many bytes from the start of the file we search for the header. */
#define MULTIBOOT_HEADER_MAGIC 0x1BADB002		/* The magic field should contain this. */
#define MULTIBOOT_BOOTLOADER_MAGIC 0x2BADB002		/* This should be in %eax. */
#define MULTIBOOT_UNSUPPORTED 0x0000fffc		/* The bits in the required part of flags field we don't support. */
#define MULTIBOOT_MOD_ALIGN 0x00001000		/* Alignment of multiboot modules. */
#define MULTIBOOT_INFO_ALIGN 0x00000004		/* Alignment of the multiboot info structure. */

#define MULTIBOOT_HEADER_CHECKSUM -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

#define KERNEL_VIRTUAL_BASE 0xC0000000
#define STACK_SIZE 0x4000

#endif
