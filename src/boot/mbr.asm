[BITS 16]
[ORG 0x7C00]

BOOTLOADER_LOADPOINT            equ 0x7E00
BOOTLOADER_ADDRESS              equ 0x01

CODESEG                         equ codeDesc-GDT
DATASEG                         equ dataDesc-GDT

KbdControllerDataPort           equ 0x60
KbdControllerCommandPort        equ 0x64
KbdControllerDisableKbd         equ 0xAD
KbdControllerEnableKbd          equ 0xAE
KbdControllerReadCtrlOutPort    equ 0xD0
KbdControllerWriteCtrlOutPort   equ 0xD1

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

    ; Load our kernel

    ; Enter protected mode
    jmp enterProtectedMode

enterProtectedMode:
    cli
    call enableA20Line                      ; TODO: Should test if already enabled
    lgdt [GDTR]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODESEG:pmEntry


enableA20Line:
    call .waitInput                         ; Disable the keyboard
    mov al, KbdControllerDisableKbd
    out KbdControllerCommandPort, al

    call .waitInput                         ; Read control output port
    mov al, KbdControllerReadCtrlOutPort
    out KbdControllerCommandPort, al

    call .waitOutput
    in al, KbdControllerDataPort
    push eax

    call .waitInput                         ; Write control output port
    mov al, KbdControllerWriteCtrlOutPort
    out KbdControllerCommandPort, al

    call .waitInput
    pop eax
    or al, 2
    out KbdControllerDataPort, al

    call .waitInput                         ; Re-enable the keyboard
    mov al, KbdControllerEnableKbd
    out KbdControllerCommandPort, al

    call .waitInput
    ret
.waitInput:
    in al, KbdControllerCommandPort
    test al, 2
    jnz .waitInput
    ret
.waitOutput:
    in al, KbdControllerCommandPort
    test al, 1
    jz .waitOutput
    ret

; Including our utility function (print, load, hang, etc)
%include "boot/mbrUtils.asm"

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

times 510-($-$$) db 0x00        ; Fill remainder of MBR with zeros
dw 0xAA55                       ; Magic boot number

%include "boot/proper.asm"