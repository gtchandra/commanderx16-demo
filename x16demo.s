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
redo:       lda #$20
            ldy #$00
            ldx #$01
            jsr SetVeraHML
            ldx z_Regs            
l2:         
            stx V_D1
            inx
            lda V_M
            cmp #$3b
            beq endloop2
            jmp l2
endloop2:
            inc z_Regs
            jmp redo
            rts

SetVeraHML:
            sta V_H
            sty V_M
            stx V_L
            rts

  

