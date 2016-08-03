CC=i686-elf-gcc

INCLUDES=./
INCLUDE_PARAMS=$(foreach d, $(INCLUDES), -I$d)

CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS=-ffreestanding -O2 -nostdlib

LIBS=-lgcc

C_SOURCES=gdt.c
AS_SOURCES=kernel.S

SOURCES=$(C_SOURCES)
SOURCES+=$(AS_SOURCES)

OBJECTS=
OBJECTS+=$(C_SOURCES:.c=.o)
OBJECTS+=$(AS_SOURCES:.S=.o)

BINARY=hxos.bin

.PHONY: all clean

all: $(BINARY)

$(BINARY): $(OBJECTS)
	$(CC) -g -T linker.ld -o $(BINARY) $(LDFLAGS) $(OBJECTS) $(LIBS)

%.o: %.c
	$(CC) $(INCLUDE_PARAMS) -g -c $< -o $@ $(CFLAGS)

%.o: %.S
	$(CC) $(INCLUDE_PARAMS) -g -c $< -o $@ $(CFLAGS)

clean:
	rm -rf *.o *.bin;
