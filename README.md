# HXOS
Experiments in baremetal x86 Kernel dev, written entirely in GNU ASM.

## Build
In order to build this you'll need a cross compiler capable of creating a binary for i686-elf, you can download a prebuilt one for Linux-x86_64 to i686-elf here: http://newos.org/toolchains/i686-elf-4.9.1-Linux-x86_64.tar.xz Since hxOS is written entirely in x86 ASM, using AT&T/GAS Syntax and utilizes GCC macros, compiling with GCC is probably ideal.

The 'run.sh' script in the base dir builds the Kernel image and launches the raw kernel binary in 'qemu-system-i386'. This assumes you're using the above cross-compiler.
