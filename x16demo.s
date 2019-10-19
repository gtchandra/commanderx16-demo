z_R = $20

V_H=$9F20
V_M=$9F21
V_L=$9F22
V_D1=$9F23
VERA_CTRL=$9F25

;line of code 10 sys 2064
.byte   	$0b,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00,$00,$00
            lda  #%00000000
            sta VERA_CTRL
            lda #$14
            ldy #$00
            ldx #$40
            jsr SetVeraHML
            lda #%0000001
            sta V_D1
            lda #128
            sta V_D1
            lda #128
            sta V_D1
            ;configure mode char 256 colors
            lda #$14
            ldy #$00
            ldx #$00
            jsr SetVeraHML
            lda #$21
            sta V_D1
            ;setup vera for character ram address: $00000
            lda #$20
            ldy #$00
            ldx #$00
            jsr SetVeraHML
l1:         ;build a full page of characters ($E0 x $3b)
            lda #$e0
            sta V_D1
            lda V_M
            cmp #$3b
            beq endloop
            jmp l1
endloop:    
;color setup for color ram
redo:       lda #$20
            ldy #$00
            ldx #$01
            jsr SetVeraHML
            ldx z_R          
l2:         
            stx V_D1
            inx
            lda V_M
            cmp #$3b
            beq endloop2
            jmp l2
endloop2:
            jsr$ffe4    ;keyboard control
            inc z_R
            cmp #$20
            bne redo
            rts
SetVeraHML:
            sta V_H
            sty V_M
            stx V_L
            rts

  SetPalette:


