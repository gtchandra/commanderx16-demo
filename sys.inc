FILENAME=$05
FILENAME_L=$05
FILENAME_H=FILENAME_L+1
FILENAMELENGTH=$07
LOADADDR_L=$08
LOADADDR_H=LOADADDR_L+1

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
;debug macro still TBC
.macro PRINT
            lda size_h
            and #%00001111
            ora #%00110000
            jsr $ffd2
            lda size_l
            lsr
            lsr
            lsr
            lsr
            ora #%00110000
            jsr $ffd2
            lda size_l
            and #%00001111
            ora #%00110000
            jsr $ffd2
            lda #$20
            jsr $ffd2
            rts
.endmacro
.macro LOAD 
            lda FILENAMELENGTH
            ldx FILENAME_L
            ldy FILENAME_H
            jsr $FFBD   ;call SETNAM
            lda #$02
            ldx #$01
            ldy #$00    ;load at mem addr defined 
            jsr $FFBA   ;call SETLFS
            lda #$00
            ldx LOADADDR_L
            ldy LOADADDR_H
            jsr $FFD5   ;call LOAD
            ;bcs no exception handling here
.endmacro

.macro VLOAD bank, addrlo,addrhi
            lda FILENAMELENGTH
            ldx FILENAME_L
            ldy FILENAME_H
            jsr $FFBD   ;call SETNAM
            lda #$02
            ldx #$01
            ldy #$00    ;load at mem addr defined 
            jsr $FFBA   ;call SETLFS
            lda #bank+2 ;it's really like that (former meaning A: 0 = Load, 1-255 = Verify)
            ldx addrlo  
            ldy addrhi  
            jsr $FFD5   ;call LOAD
            ;bcs no exception handling here
.endmacro