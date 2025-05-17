BOOTSRC = boot/mbr.asm
BOOTOBJ = img

all: run

${BOOTOBJ}: ${BOOTSRC}
	nasm -fbin $^ -o $@

run: ${BOOTOBJ}
	qemu-system-x86_64 -hda $^

clean:
	rm ${BOOTOBJ}