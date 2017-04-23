CC=i686-elf-gcc

INCLUDES=include
INCLUDE_PARAMS=$(foreach d, $(INCLUDES), -I$d)

CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS=-ffreestanding -O2 -nostdlib

LIBS=-lgcc

AS_SOURCES=hxos.S tty.S boot.S pmode.S gdt.S
OBJECTS+=$(AS_SOURCES:.S=.o)

BINARY=hxos.bin

.PHONY: all clean

all: $(BINARY)

$(BINARY): $(OBJECTS)
	$(CC) -g3 -T linker.ld -o $(BINARY) $(LDFLAGS) $(OBJECTS) $(LIBS)

%.o: %.c
	$(CC) $(INCLUDE_PARAMS) -g -c $< -o $@ $(CFLAGS)

%.o: %.S
	$(CC) $(INCLUDE_PARAMS) -g -c $< -o $@ $(CFLAGS)

clean:
	rm -rf *.o *.bin;
