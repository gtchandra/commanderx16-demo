.segment "ZEROPAGE"
z_regs: .res 1
z_l:    .res 1

.segment "CODE"
            lda  #$47
            sta z_regs
            sta z_l
            rts