VERA_base = $9f20
VERA_ADDR_LO   = VERA_base
VERA_ADDR_MID  = VERA_base+1
VERA_ADDR_HI  = VERA_base+2
VERA_data       = VERA_base+3
VERA_data2      = VERA_base+4
VERA_ctrl       = VERA_base+5
VERA_irq_ctrl   = VERA_base+6
VERA_irq        = VERA_base+7

VRAM_composer = $F0000
VRAM_palette  = $F1000
VRAM_layer1   = $F2000
VRAM_layer2   = $F3000
VRAM_sprinfo  = $F4000
VRAM_sprdata  = $F5000

VROM_petscii = $1F000

;=================================================
; VERA_SELECT_ADDR
;   Select which address channel to configure (VERA_data vs. VERA_data2)
;-------------------------------------------------
; INPUTS:   .addr	0 for VERA_data
;					1 for VERA_data2
;
;-------------------------------------------------
; MODIFIES: A
;
.macro VERA_SELECT_ADDR addr 
	lda #addr
	sta VERA_ctrl
.endmacro


;=================================================
; VERA_SET_ADDR (multiple)
;   Set the current address channel's address
;-------------------------------------------------
; INPUTS:   .addr			VRAM address to set to
;			[.stride = 1]	Address stride/auto-increment
;								value: 	increment
;									0: 	disabled
;									1: 	1 byte
;									2: 	2 byte
;									3: 	4 byte
;									4: 	8 byte
;									5: 	16 byte
;									6: 	32 byte
;									7: 	64 byte
;									8: 	128 byte
;									9: 	256 byte
;								   10: 	512 byte
;								   11: 	1024 byte
;								   12: 	2048 byte
;								   13: 	4096 byte
;								   14: 	8192 byte
;								   15: 	16384 byte
;
;-------------------------------------------------
; MODIFIES: A
;
.macro VERA_SET_ADDR addr, stride 
	lda #<(addr)
	sta VERA_ADDR_LO
	lda #<(addr >> 8)
	sta VERA_ADDR_MID
	lda #<(addr >> 16) | (stride << 4)
	sta VERA_ADDR_HI
.endmacro

;VERA_LOAD_DATA (address, size)
.macro VERA_LOAD_DATA2 
            ldy #$00
vld20:      lda (data_pointer_l),y
            sta VERA_data
            inc data_pointer_l
            beq vld21
vld22:      dec size_l
            bne vld20
            dec size_h
            bne vld20
            ;write the last pending byte
            lda (data_pointer_l),y
            sta VERA_data
            rts
vld21:
            inc data_pointer_h
            jmp vld22            
.endmacro

;VERA_LOAD_DATA (address, size, linesize, skip )
.macro VERA_LOAD_DATA 
            ldy #$00
            ;configure palette
            lda size_h
            beq vld6
vld0:       ldx #$FF
vld1:       lda (data_pointer_l),y     
            sta VERA_data
            inc data_pointer_l
            bne vld2
            inc data_pointer_h
vld2:       dex 
            bne vld1
            dec size_h
            lda size_h
            cmp #$00
            bne vld0
vld6:       ldx size_l
            cpx #$00
            beq vld5
vld3:       lda (data_pointer_l),y     
            sta VERA_data
            inc data_pointer_l
            bne vld4
            inc data_pointer_h
vld4:       dex 
            bne vld3
vld5:       rts
.endmacro

.macro VERA_LOAD_CHAR vlclinesize, vlcpad, vlcchar   
            ;setup padamount and length
            lda vlclinesize
            sta length
            lda vlcpad
            sta padamount
            ldy #$00
            ldx #$00
vlc1:       
            VERA_WRITE vlcchar
            inx
 			cpx length
            bne vlc1
            ldx #$00
            lda VERA_ADDR_LO
            clc
            adc padamount
            sta VERA_ADDR_LO
            bcc vlc2
            inc VERA_ADDR_MID
vlc2:       iny
            cpy #$3c	;#liness
            bne vlc1
.endmacro

.macro VERA_LOOP_CHAR_COLOR vlcclinesize, vlccpad   ;no no sbagliato questo cambia il valore dei caratteri
            ;setup padamount and length
            lda vlcclinesize
            sta length
            lda vlccpad
            sta padamount
            ldy #$00
            ldx #$00
vlcc1:       
            ;unless I can do inc vera_data!!!
            lda VERA_data
            sec
            sbc #$02
            sta VERA_data
            clc
            lda VERA_ADDR_LO
            adc #$02
            sta VERA_ADDR_LO
            bcc vlcc4
            inc VERA_ADDR_MID
vlcc4:      inx
 			cpx length
            bne vlcc1
            ldx #$00
            lda VERA_ADDR_LO
            clc
            adc padamount
            sta VERA_ADDR_LO
            bcc vlcc3
            inc VERA_ADDR_MID
vlcc3:  
            iny
            cpy #$3c	;liness
            bne vlcc1
.endmacro

.macro VERA_INC_POINTER
            inc VERA_ADDR_LO
            bne vip1
            inc VERA_ADDR_MID
vip1:       rts
.endmacro
.macro VERA_DEC_POINTER
            lda VERA_ADDR_LO
            beq vdp1
            dec VERA_ADDR_LO
            rts
vdp1:       dec VERA_ADDR_LO
            dec VERA_ADDR_MID
            rts
.endmacro

.macro VERA_WRITE v0 
	lda v0
	sta VERA_data
.endmacro

