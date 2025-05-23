[BITS 32]

; esi contains string, null terminated
printStrPM:
    mov eax, 0xB8000    ; Ensure we have right value for particular monitor
.printChar:
    mov bh, [esi]
    cmp bh, 0x00
    je .printFinished
    cmp bh, 0x0D
    je .printCR
    cmp bh, 0x0A
    je .printLF
    mov [eax], bh
    jmp .incPrintBuffers
.printCR:
    ; TODO: Increase buffer to next line
.printLF:
    ; TODO: Reset buffer to start of current line
.incPrintBuffers:
    inc esi
    add eax, 2
    jmp .printChar
.printFinished:
    ret

