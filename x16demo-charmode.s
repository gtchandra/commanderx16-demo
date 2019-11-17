
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
            jsr vera_load      ;transfer lines of data
            ;skipping data is needed in VERA char mode
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
            jsr $ffe4    ;keyboard control
            cmp #$20
            bne theend 


vera_inc:   VERA_INC_POINTER  
vera_dec:   VERA_DEC_POINTER          
vera_load:  VERA_LOAD_DATA    

palette_data:
.incbin "palette.dat"    
.asciiz "endpalette"
image_data:
.incbin "image.dat"
bop:    .asciiz "endimage"