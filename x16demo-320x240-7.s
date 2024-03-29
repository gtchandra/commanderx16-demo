
data_pointer_l=$30
data_pointer_h=data_pointer_l+1
size_l=$32
size_h=size_l+1
data_pointer_c_l=$36
data_pointer_c_h=data_pointer_c_l+1

;APPUNTI: essendo 320x200@8bpp 64K è necessario gestire questi contenuti nella BANKED RAM, e non nei 40K di RAM contigua del codice
;questo motivo forza l'uso di un caricamento del file esterno in modo da dinamicamente posizionarlo nella banked ram, non c'è un modo altrimenti via assembler
;questo forza l'introduzione di KERNAL Routines per caricare byte da un file sulla memoria Banked A000-->BFFF blocchi da 8KB, il ram bank è definto da VIA IO chip VIA#1 PA0-7 ($9F61)

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
            ;next set vera display composer register (former 40040)
            VERA_SET_ADDR $F0000, 1
            VERA_WRITE #%0000001
            VERA_WRITE #64 ;set vertical scale
            VERA_WRITE #64 ;set horizontal scale
            
            ;turn off layer 1 register
            VERA_SET_ADDR $F3000, 1
            VERA_WRITE #$00

            ;configure mode 7 :: 8bpp BITMAP on layer 0 register
            VERA_SET_ADDR $F2000, 1
            VERA_WRITE #$E1;mode7 enable
            VERA_SET_ADDR $F2004, 1
            VERA_WRITE #$00; configure 320x200
            VERA_WRITE #$00

            ;setup VERA END
            VERA_SET_ADDR $F1000,1  ;palette loading in VERA
           
            lda #<palette_data
            sta data_pointer_l
            lda #>palette_data
            sta data_pointer_h
            lda #$01+1
            sta size_h
            lda #$ff
            sta size_l
            jsr vera_load
            
            ;set the file name index to 0 (image0.dat)
            lda #$30
            sta filname+5

            lda #<filname
            sta FILENAME_L
            lda #>filname
            sta FILENAME_H
            lda #end_filname-filname
            sta FILENAMELENGTH
            lda #<image_data
            sta LOADADDR_L
            lda #>image_data
            sta LOADADDR_H
            VERA_SET_ADDR $00000, 1            
loadloop: 
            LOAD
            ;fill the color ram with image data

            lda #<image_data
            sta data_pointer_l
            lda #>image_data
            sta data_pointer_h
            lda #$1f+1
            sta size_h
            lda #$3f
            sta size_l
            jsr vera_load    


            inc filname+5
            lda filname+5
            cmp #$3A
            bne loadloop      

wait:      jsr $ffe4    ;keyboard control
            cmp #$20
            bne wait
            VERA_SET_ADDR $00000, 1
            ldx #$01+1
            ldy #$3f+1
lx:         VERA_WRITE #$FF
            dey
            bne lx
            dex 
            bne lx
            rts

vera_inc:   VERA_INC_POINTER  
vera_dec:   VERA_DEC_POINTER          
vera_load:  VERA_LOAD_DATA2    

.segment "DATA"

filname:    
.asciiz "image0.dat"
end_filname:
.byte "paletteloadshere"
palette_data:
.incbin "palette.dat"
.byte $00
.byte "imagedata"
image_data:
