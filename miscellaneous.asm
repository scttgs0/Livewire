
;======================================
; Flash Object When Dead
;======================================
Flash           .proc
                ldy FLASHY              ; get y pos.
                lda #0                  ; get ready to
                ldx #14                 ; clear old flash
_clrFlash       ;!!sta PL1,Y               ; zero out each
                iny                     ; byte of flash
                dex                     ; done yet?
                bne _clrFlash           ;   no, loop.

                lda SAVEX               ; get object's
                clc                     ; x pos. and
                adc #61                 ; add 61 for
                sta SPR(sprite_t.X, 1)  ; flash horiz.

                lda SAVEY               ; get y pos and
                clc                     ; add 26 for
                adc #26                 ; flash vert.
                tay                     ; position
                sty FLASHY              ; and save

                ldx #13                 ; flash = 14 bytes
_setFlash       lda FLBYTE,X            ; get image
                ;!!sta PL1,Y               ; put in player 1
                iny                     ; next p/m byte

                dex                     ; next image byte
                bpl _setFlash

                lda #1                  ; set flash
                sta FlashTimer          ; duration

                rts
                .endproc


;======================================
; Time Delay
;======================================
WAIT            .proc
                sta DelayTimer          ; set timer

_wait1          lda DelayTimer          ; timer = 0?
                bne _wait1              ;   nope!

                rts                     ; timer finished!
                .endproc


;======================================
; Turn Sounds Off
;======================================
SoundOff        .proc
                lda #0                  ; zero out:
                sta FIRSOU              ; fire sound
                sta OBDSOU              ; obj death sound
                sta MOVSOU              ; plyr move sound

                ldx #$1C                ; zero all:
_next1          sta SID1_FREQ1,X        ; audio registers

                dex
                bpl _next1

                rts
                .endproc
