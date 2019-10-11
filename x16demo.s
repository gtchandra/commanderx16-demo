
;line of code 10 sys 2064
.byte   	$0b,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00,$00,$00
            lda  #$47
            sta z_regs
            rts
; ZEROPAGE
z_regs=$20  