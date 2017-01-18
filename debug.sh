make clean
make
objcopy --only-keep-debug hxos.bin hxos.sym
#x-terminal-emulator -e kdbg -r localhost:1234 hxos.bin
x-terminal-emulator -e qemu-system-i386 -s -S -kernel hxos.bin
