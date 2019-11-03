VERA_base = $9f20
VERA_ADDR_LO   = VERA_base+2
VERA_ADDR_MID  = VERA_base+1
VERA_ADDR_HI  = VERA_base
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

;VERA_LOAD_PALETTE (address, size )
.macro VERA_LOAD_PALETTE paddr, psize 
            ldy #$00
  			;configure palette
            lda #<paddr
            sta z_l
            lda #>paddr
            sta z_h
.if psize > $FF
            nop
            nop
 			lda #>psize
            sta imgcounter
vpl0:		ldx #$FF
vpl1:       lda (z_l),y     
            sta VERA_data
            inc z_l
            bne vpl2
            inc z_h
vpl2:       dex 
			bne vpl1
			dec imgcounter
            lda imgcounter
            cmp #$00
            bne vpl0
.endif 
           	ldx #<psize
			cpx #$00
			beq vpl5
vpl3:       lda (z_l),y     
            sta VERA_data
            inc z_l
            bne vpl4
            inc z_h
vpl4:       dex 
			bne vpl3
vpl5:
.endmacro


;generalizzare la load palette con una load data che aggiunge parametri di line e skip
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
            bne vlc3
            ldx #$00
            lda VERA_ADDR_LO
            adc padamount
            sta VERA_ADDR_LO
            bcs vlc2
vlc2:       inc VERA_ADDR_MID
vlc3:  
            cpx #$00 ;line finished
            bne vlc1
            iny
            cpy #$3c	;liness
            bne vlc1
.endmacro

.macro VERA_WRITE v0 
	lda v0
	sta VERA_data
.endmacro

