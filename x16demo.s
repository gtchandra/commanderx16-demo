z_l=$30
z_h=z_l+1
data_pointer_l=$30
data_pointer_h=data_pointer_l+1
size_l=$32
size_h=size_l+1
data_pointer_c_l=$36
data_pointer_c_h=data_pointer_c_l+1

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
            ;setup VERA END
            VERA_SET_ADDR $40200,1  ;palette loading
            lda #<palette_data
            sta data_pointer_l
            lda #>palette_data
            sta data_pointer_h
            lda #$02
            sta size_h
            lda #$02
            sta size_l
            jsr vera_load
            ;setup vera for character ram address: $00000
            VERA_SET_ADDR $00000, 2
            VERA_LOAD_CHAR #$50, #$60, #$e0

;fill the color ram with image data
            VERA_SET_ADDR $00001, 2
            lda #<image_data
            sta data_pointer_l
            lda #>image_data
            sta data_pointer_h
            lda #0
            sta size_h
            lda #$00
            sta imgcounter
l0:         lda #$50
            sta size_l
            jsr vera_load      
            ;skipping padding data in VERA 
            lda VERA_ADDR_LO
            adc #$5f
            sta VERA_ADDR_LO
            bcc xs1
            inc VERA_ADDR_MID
xs1:        
            inc imgcounter
            lda imgcounter
            cmp #$3f    ;count these number of lines
            bne l0
theend:     
            VERA_SET_ADDR $00001, 0
            VERA_LOOP_CHAR_COLOR #$50, #$60
            
            jmp theend

            jsr $ffe4    ;keyboard control
xxxx:       cmp #$20
            bne xxxx 
            jmp theend


            ;palette loop area
pl00:       lda #$02
            sta size_l
            lda #$02
            sta size_h
            VERA_SET_ADDR $40200,0 ;no auto increment for palette loop
            lda VERA_data
            ;pha
            jsr vera_inc
            lda VERA_data
            ;pha
            VERA_SET_ADDR $40200,0 
            ;di sicuro il ciclo deve chiudersi 4 locazioni prima da eliminare a size
            ;poi sarà necessario anche assicurarsi che non avvenga sfasamento di byte che genera colori sbagliati 
pl01:       ;jsr print
            jsr vera_inc
            jsr vera_inc
            ldx VERA_data
            jsr vera_inc
            ldy VERA_data
            jsr vera_dec
            jsr vera_dec
            jsr vera_dec
            stx VERA_data
            jsr vera_inc
            sty VERA_data
            jsr vera_inc
            dec size_l
            dec size_l
            bne pl01
            lda size_h
            beq px0
            dec size_h
            jmp pl01
px0:        
         
            jsr $ffe4    ;keyboard control
            cmp #$20
            bne px0     ;no key pressed go to loop
            jmp pl00
            rts
            pla 
            sta VERA_data
            jsr vera_inc
            pla
            sta VERA_data
            ;jsr $ffe4    ;keyboard control
            ;cmp #$20
            ;bne pl00     ;no key pressed go to loop
            rts

vera_inc:   VERA_INC_POINTER  
vera_dec:   VERA_DEC_POINTER          
vera_load:  VERA_LOAD_DATA    
print: 
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

palette_data:
.incbin "palette.dat"    
.asciiz "end palette"
image_data:
.incbin "image.dat"
bop:    .asciiz "end image"