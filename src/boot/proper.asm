[BITS 32]

pmEntry:
    mov ax, DATASEG             ; Ensure segment registers hold data segment
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov ss, ax

    ; TODO: We should implement detection for monochrome vs multicoloured monitors
    mov esi, protectedModeSetupStr
    call printStrPM

    jmp hang

%include "boot/properUtils.asm"

stage2LoadedStr:
    db "Bootloader loaded!", 0x0D, 0x0A, 0x00
protectedModeSetupStr:
    db "Setup protected mode!", 0x00

; Global Descriptor Table
GDT:
    dq 0x00000000
codeDesc:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
dataDesc:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
GDTR:
    dw GDTR-GDT-1
    dd GDT