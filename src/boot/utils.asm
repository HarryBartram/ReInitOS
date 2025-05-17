; Print basic string
printStr:
    mov ah, 0x0E
.testChar
    ; Test character isn't null, if it is return, if it isnt print then increment si.
    mov al, [si]
    cmp al, 0x00
    jne .printChar
    ret
.printChar
    int 0x10
    inc si
    jmp .testChar

; Load data from disk
load:
    mov si, DAPACK
    mov ah, 0x42
    int 0x13
    ret

; Hang, for ending execution
hang:
    cli
    hlt