# HXOS
Experiments in x86 Kernel dev, using only ASM.

## Build
HXOS is currently only configured to be built under Linux.
You'll need a cross compiler capable of creating a binary for i686-elf, you can download a prebuilt one for Linux-x86_64 to i686-elf here: http://newos.org/toolchains/i686-elf-4.9.1-Linux-x86_64.tar.xz
If you were attempting to cross-compile under Windows, you'd have to find your own solution, but building a gcc cross compiler from source in Cygwin should suffice.

hxOS is written entirely in x86 ASM, AT&T/GAS Syntax. HXOS utilizes GCC macros, as such, compiling with GCC is ideal.

The 'run.sh' script in the base dir builds the Kernel image and launches the raw kernel binary in 'qemu-system-i386'. 'cdemu.sh' does the same, but creates an .iso ROM before launching.
