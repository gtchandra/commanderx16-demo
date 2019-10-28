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

.macro VERA_WRITE v0 
	lda v0
	sta VERA_data
.endmacro

