BOOTSRC = ${wildcard boot/*.asm}
BOOTOBJ = img

all: run

${BOOTOBJ}: ${BOOTSRC}
	nasm -fbin boot/mbr.asm -o $@

run: ${BOOTOBJ}
	qemu-system-x86_64 -hda $^

clean:
	rm ${BOOTOBJ}