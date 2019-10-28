z_l=$30
z_h=z_l+1


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
            VERA_SET_ADDR $40200,1
            ldx #$00
pl:         lda palette_data,x     
            sta VERA_data
            inx
            cpx #$80    ;loading $40 = 64 palette values in 2 byte steps GB + R
            bne pl
            ldy #$00
            ldx #$00
            ;setup vera for character ram address: $00000
            VERA_SET_ADDR $00000, 2
l1:         ;build a full page of characters (PETSCII $E0 is the rvs on square)
            VERA_WRITE #$e0
            inx
            cpx #$50    ;lines  of 80 columns
            bne l1
            iny
            cpy #$3c
            beq endloop
            ldx #$00
            lda VERA_ADDR_LO
            adc #$60
            sta VERA_ADDR_LO
            bcs s1
            jmp l1
s1:         inc VERA_ADDR_MID
            jmp l1
endloop:  

;setup for color ram 

            lda #<image_data
            sta z_l
            lda #>image_data
            sta z_h
            VERA_SET_ADDR $00001, 2
            ldy #$00
            ldx #$00
 l2:        lda (z_l),y          
            cmp #$ff
            beq theend
            sta VERA_data
            inx
            jsr checkpad            
            inc z_l
            bne l2
            inc z_h
            jmp l2
theend:     

x0:         VERA_SET_ADDR $00001, 2
            ldx #$00
            ldy #$00
x1:         
            lda VERA_data
            dec VERA_ADDR_LO
            dec VERA_ADDR_LO
            dec
            cmp #$ff
            bne con
            lda #$40
con:        sta VERA_data
            inx
            jsr checkpad     
            cpx #$00
            bne x1
            iny
            cpy #$3c
            bne x1

            jsr$ffe4    ;keyboard control
            cmp #$20
            bne x0      ;no key pressed go to loop
            rts
checkpad:   ;lines are padded, so after 80 positions you need to skip $5f positions x is the counter in this sr
            cpx #$50
            bne exitcheck
            ldx #$00
            lda VERA_ADDR_LO
            adc #$5f
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
