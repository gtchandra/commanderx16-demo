z_l=$30
z_h=z_l+1
padamount=$33
length=$34
imgcounter=$35

.include "sys.inc"
.include "vera.inc"
;line of code 10 sys 2064
.byte   	$0b,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00,$00,$00
            ;setup zeropage with beginning of image data
            nop
            ;setup VERA
            lda  #%00000000
            sta VERA_ctrl
            VERA_SET_ADDR $40040, 1
            VERA_WRITE #%0000001
            VERA_WRITE #128 ;set vertical scale
            VERA_WRITE #128 ;set horizontal scale
            ;configure mode 1 :: char 256 colors
            VERA_SET_ADDR $40000, 1
            VERA_WRITE #$21
           
            ;configure palette
            lda #<palette_data
            sta z_l
            lda #>palette_data
            sta z_h
            lda #$00
            sta imgcounter
            VERA_SET_ADDR $40200,1
            ldx #$00
            ldy #$00
pl:         lda (z_l),y     
            sta VERA_data
            inc z_l
            bne p2
            inc z_h
p2:         inx
            ;loading a 256 palette in 2 cycles of 256 elements (GB+R)
            bne pl
            inc imgcounter
            lda imgcounter
            cmp #$02
            bne pl

            ;setup padamount and length
            lda #$50
            sta length
            lda #$5f
            sta padamount
            ldy #$00
            ldx #$00
            ;setup vera for character ram address: $00000
            VERA_SET_ADDR $00000, 2
l1:         ;build a full page of characters (PETSCII $E0 is the rvs on square)
            VERA_WRITE #$e0
            inx
            jsr checkpad
            cpx #$00 ;line finished
            bne l1
            iny
            cpy #$3c
            bne l1
  
;fill the color ram with image data
;load zp variables padamount and length
            lda #$50
            sta length
            lda #$5f
            sta padamount
;load zp registers image
            lda #<image_data
            sta z_l
            lda #>image_data
            sta z_h
            lda #$00
            sta imgcounter
            VERA_SET_ADDR $00001, 2
            ldy #$00
            ldx #$00
 l2:        lda (z_l),y           
            sta VERA_data
            inx
            jsr checkpad  
            cpx #$00
            bne f1
            inc imgcounter
            lda imgcounter
            cmp #$3f
            beq theend       
f1:         inc z_l
            bne l2
            inc z_h
            jmp l2
theend:     
            
;palette loop
x0:         VERA_SET_ADDR $00001, 0 ;no auto increment for palette loop
            ldx #$00
            ldy #$00
x1:         
            lda VERA_data           
            inc
con:        sta VERA_data
            inc VERA_ADDR_LO
            inc VERA_ADDR_LO
            bne next
            inc VERA_ADDR_MID
next:       inx
            jsr checkpad     
            cpx #$00
            bne x1
            iny
            cpy #$3c
            bne x1
            jsr $ffe4    ;keyboard control
            cmp #$20
            bne x0      ;no key pressed go to loop
            rts
checkpad:   ;lines are padded, so after 80 positions you need to skip $5f positions x is the counter in this sr
            cpx length
            bne exitcheck
            ldx #$00
            lda VERA_ADDR_LO
            adc padamount
            sta VERA_ADDR_LO
            bcs xs1
            rts
xs1:        inc VERA_ADDR_MID
exitcheck:  
            rts          
palette_data:
.incbin "palette.dat"
image_data:
.incbin "image.dat"
.byte   $ff,$ff  ;end marker
bop:    .asciiz "ciao!"