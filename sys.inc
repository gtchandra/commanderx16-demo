.macro SYS_COPY src, dst, size 
    lda #<src ;.src to $FC $FB
    sta $FB
    lda #>src
    sta $FC
    lda #<dst ;.dst to $FE $FD
    sta $FD
    lda #>dst
    sta $FE
    .if size > $FF 
                    ; If we have at least 1 full page to copy, then include the
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #>size ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop
xx:       lda ($FB),Y ; indirect index source memory address
        sta ($FD),Y ; indirect index dest memory address
        iny
        bne xx       ; loop until our dest goes over 255

        inc $FC     ; increment high order source memory address
        inc $FE     ; increment high order dest memory address

        dec $FF     ; decrement number of pages remaining
        bne xx       ; If we still have at least 1 page to copy, go back and copy it
    .endif
    .if <size > 0 
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #<size

yy:     lda ($FB),Y
        sta ($FD),Y
        iny
        dex
        bne yy
    .endif
.endmacro

.macro SYS_SET_IRQ address 
    lda $0314
    sta irq_redirect
    lda $0315
    sta irq_redirect+1
    lda #<address
    sta $0314
    lda #>address
    sta $0315
.endmacro

.macro SYS_END_IRQ  
    jmp (irq_redirect)
.endmacro