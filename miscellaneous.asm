;======================================
; FLASH OBJECT WHEN DEAD
;======================================
FLASH           .proc
                ldy FLASHY              ; get y pos.
                lda #0                  ; get ready to
                ldx #14                 ; clear old flash
CLFLSH          ;sta PL1,Y               ; zero out each
                iny                     ; byte of flash
                dex                     ; done yet?
                bne CLFLSH              ;   no, loop.

                lda SAVEX               ; get object's
                clc                     ; x pos. and
                adc #61                 ; add 61 for
                sta SP01_X_POS          ; flash horiz.
                lda SAVEY               ; get y pos and
                clc                     ; add 26 for
                adc #26                 ; flash vert.
                tay                     ; position
                sty FLASHY              ; and save

                ldx #13                 ; flash = 14 bytes
SEFLSH          lda FLBYTE,X            ; get image
                ;sta PL1,Y               ; put in player 1
                iny                     ; next p/m byte
                dex                     ; next image byte
                bpl SEFLSH              ; loop.

                lda #1                  ; set flash
                sta FLTIME              ; duration
                rts
                .endproc


;======================================
; TIME DELAY
;======================================
WAIT            .proc
                sta TIMER               ; set timer
WAITLP          lda TIMER               ; timer = 0?
                bne WAITLP              ;   nope!

                rts                     ; timer finished!
                .endproc


;======================================
; TURN SOUNDS OFF
;======================================
SNDOFF          .proc
                lda #0                  ; zero out:
                sta FIRSOU              ; fire sound
                sta OBDSOU              ; obj death sound
                sta MOVSOU              ; plyr move sound
                ldx #7                  ; zero all:
_next1          ;sta AUDF1,X            ; audio registers
                dex
                bpl _next1

                rts
                .endproc
