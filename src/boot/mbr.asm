[BITS 16]
[ORG 0x7C00]

BOOTLOADER_LOADPOINT    equ 0x7E00
BOOTLOADER_ADDRESS      equ 0x01

; Entry point for our bootloader
entry:
    ; This will fully load our bootloader (not just the first 512 bytes), DAPACK is already filled out
    call load
    jnc .loadSuccess
    ; If load fails
    mov si, loadFailureStr
    call printStr
    jmp hang
.loadSuccess
    ; Prove that the second stage has been loaded
    mov si, stage2LoadedStr
    call printStr

    ; Infinite loop
    jmp $

; Including our utility function (print, load, hang, etc)
%include "boot/utils.asm"

; Strings
loadFailureStr:
    db "Failed to load bootloader!", 0x0D, 0x0A, 0x00

; Disk address packet structure (for int 0x13)
DAPACK:
    db 0x10
    db 0x00
blkcnt:
    dw 0x01                     ; This is reset to the number of blocks actually read
db_add:
    dw BOOTLOADER_LOADPOINT     ; Destination address (default is load point for stage 2)
    dw 0x00                     ; Memory page number
db_lba:
    dd BOOTLOADER_ADDRESS       ; Source address, in LBA (default is location of stage 2)
    dd 0x00 

times 510-($-$$) db 0x00
dw 0xAA55

stage2LoadedStr:
    db "Bootloader loaded!", 0x0D, 0x0A, 0x00