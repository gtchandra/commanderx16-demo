z_Regs = $20
z_HL = z_Regs
z_L = z_Regs
z_H = z_Regs+1
z_DE = z_Regs+4
z_E = z_Regs+4
z_D = z_Regs+5
z_As = z_Regs+6

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
            ;configure end
            lda #$20
            ldy #$00
            ldx #$00
            jsr SetVeraHML
l1:         
;            lda #$e0
;            sta V_D1

            lda #$07
            sta V_D1
            lda #$01
            sta V_D1
            lda #$02
            sta V_D1
            lda #$20
            sta V_D1
            lda #$20
            sta V_D1
            lda V_M
            cmp #$3b
            beq endloop
            jmp l1
endloop:    
;color fill
            lda #$20
            ldy #$00
            ldx #$01
            jsr SetVeraHML
redo:       ldx z_Regs            
l2:         
;            lda #$02
;            sta V_D1
            stx V_D1
            inx
            lda V_M
            cmp #$3b
            beq endloop2
            jmp l2
endloop2:
;            inc z_Regs
;            jmp redo
            rts

            ;palette
            lda #$14
            ldy #$02
            ldx #$00
            jsr SetVeraHML

            ldx #2
            ldy #0
            lda #<palette
            sta z_L
            lda #>palette
            sta z_H
Paletteloop:
            lda (z_HL),y
            sta V_D1
            iny
            bne Paletteloop
            inc z_H
            dex
            bne Paletteloop
            rts
SetVeraHML:
            sta V_H
            sty V_M
            stx V_L
            rts
palette:
    .word  $0008
    .word  $0FF0
    .word  $00FF
    .word  $0F00
    .word  $0001
    .word  $0008
    .word  $0FF0
    .word  $00FF
    .word  $0F00
    .word  $0001
  

