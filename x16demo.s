z_R=$20

.include "sys.inc"
.include "vera.inc"
;line of code 10 sys 2064
.byte   	$0b,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00,$00,$00
            lda  #%00000000
            sta VERA_ctrl
            VERA_SET_ADDR $40040, 1
            VERA_WRITE #%0000001
            VERA_WRITE #128 ;set vertical scale
            VERA_WRITE #128 ;set horizontal scale
            ;configure mode char 256 colors
            VERA_SET_ADDR $40000, 1
            VERA_WRITE #$21
            ;setup vera for character ram address: $00000
            VERA_SET_ADDR $00000, 2
l1:         ;build a full page of characters ($E0 x $3b)
            VERA_WRITE #$e0
            lda VERA_ADDR_MID
            cmp #$3b
            beq endloop
            jmp l1
endloop:    
;color setup for color ram
redo:       
            VERA_SET_ADDR $00001, 2
            ldx z_R          
l2:         
            stx VERA_data
            inx
            lda VERA_ADDR_MID
            cmp #$3b
            beq endloop2
            jmp l2
endloop2:
            jsr$ffe4    ;keyboard control
            inc z_R
            cmp #$20
            bne redo
            rts



