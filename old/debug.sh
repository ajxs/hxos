make clean
make
objcopy --only-keep-debug hxos.bin hxos.sym
x-terminal-emulator -x qemu-system-i386 -s -S -kernel hxos.bin
gdb
