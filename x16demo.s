.segment "ZEROPAGE"
z_regs=$20  
            lda  #$47
            sta z_regs
            rts
