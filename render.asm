;======================================
; Clear Sprites
;======================================
ClearSprites    .proc
                .m16

                lda #0
                sta SP00_X_POS          ; player
                sta SP00_Y_POS

                sta SP12_X_POS          ; projectiles
                sta SP12_Y_POS
                sta SP13_X_POS
                sta SP13_Y_POS
                sta SP14_X_POS
                sta SP14_Y_POS
                sta SP15_X_POS
                sta SP15_Y_POS
                sta SP16_X_POS
                sta SP16_Y_POS
                sta SP17_X_POS
                sta SP17_Y_POS
                sta SP18_X_POS
                sta SP18_Y_POS
                sta SP19_X_POS
                sta SP19_Y_POS

                .m8
                rts
                .endproc


;======================================
; Clear Screen
;======================================
ClearPlayfield  .proc
                lda #>Playfield         ; initial display address work area
                sta HI
                lda #<Playfield
                sta LO

                ldx #20                 ; clear 20 groups of 256 bytes (5120 bytes)
_next1          ldy #0                  ; note: playfield is 32-bytes * 160 lines = 5120 bytes
                tya
_next2          sta (LO),Y
                dey
                bne _next2

                dex
                bne _1

                lda #TRUE
                sta isDirtyPlayfield
                rts

_1              inc HI
                bra _next1

                .endproc


;======================================
; GR. 14 PLOTTER ROUTINE
;--------------------------------------
; (SEE A.N.A.L.O.G. #11)
;======================================
PlotPoint       .proc
                lda PLOTY               ; mult. y by 32:
                asl A
                sta LO

                lda #0
                rol A
                sta HI                  ; *2

                asl LO
                rol HI                  ; *4

                asl LO
                rol HI                  ; *8

                asl LO
                rol HI                  ; *16

                asl LO
                rol HI                  ; *32

                lda #<Playfield         ; add the display address to get the actual
                clc                     ; address of the byte that will be altered for
                adc LO                  ; the plot.
                sta LO
                lda #>Playfield
                adc HI
                sta HI

                lda PLOTX               ; mask plotx for plot index, place in x
                and #3
                tax

                lda PLOTX               ; get plotx and divide by 4 (4 pixels/byte)
                lsr A                   ; /4
                lsr A
                sta YOFSET

                tay
                lda (LO),Y
                and BMASK2,X            ; isolate the 2-bits (4-color pixel)
                cmp COLR1,X             ; skip if already color 1
                beq _XIT

                ldy COLOR               ; get color
                lda BMASK2,X            ; mask off pixel position
                and COLORS,Y
                sta HOLD                ; save it

                lda BMASK1,X            ; mask off pixel of the address to be altered
                ldy YOFSET
                and (LO),Y              ; set the plot bits
                ora HOLD
                sta (LO),Y              ; and store!

_XIT            rts
                .endproc

;--------------------------------------

; ----------------
; PLOT MASK TABLES
; ----------------

COLORS          .byte $00,$55,$AA,$FF
BMASK1          .byte $3F,$CF,$F3,$FC
BMASK2          .byte $C0,$30,$0C,$03
COLR1           .byte $40,$10,$04,$01


;======================================
; Draw Line
;======================================
DrawLine        .proc
                lda DRAWY
                cmp PLOTY               ; is drawy>=ploty?
                bcc _yMinus             ;   no!

;   DRAWY >= PLOTY... calculate delta-Y
                sec                     ; subtract
                sbc PLOTY               ; ploty from drawy
                sta DELTAY              ; and save difference

;   we will draw from top toward bottom
                lda #1                  ; y increment = 1 (down)
                sta INCY
                bra _xVec

;   DRAWY < PLOTY... calculate delta-Y
_yMinus         lda PLOTY
                sec                     ; subtract
                sbc DRAWY               ; drawy from ploty
                sta DELTAY              ; and save difference

;   we will draw from bottom toward top
                lda #255                ; y increment = -1 (up)
                sta INCY

_xVec           lda DRAWX
                cmp PLOTX               ; is drawx > plotx?
                bcc _xMinus             ;   no!

;   DRAWX >= PLOTX... calculate delta-X
                sec                     ; subtract
                sbc PLOTX               ; plotx from drawx
                sta DELTAX              ; and save difference

;   we will draw from left toward right
                lda #1                  ; x increment = 1 (right)
                sta INCX
                bra _setVec

; DRAWX < PLOTX... calculate detla-Y
_xMinus         lda PLOTX
                sec                     ; subtract
                sbc DRAWX               ; drawx from plotx
                sta DELTAX              ; and save difference

;   we will draw from right toward left
                lda #255                ; x increment = -1 (left)
                sta INCX

_setVec         lda #0                  ; zero out:
                sta ACCY                ; y accumulator
                sta ACCX                ; x accumulator

                lda DELTAX
                cmp DELTAY              ; is deltax >= deltay?
                bcc _yBigger            ;   no!

;   delta-x is bigger
                sta COUNTR              ; save deltax in counter
                sta ENDPT               ; and endpoint

                lsr A                   ; /2
                sta ACCY                ; store in y accum.
                bra _doDraw             ; start draw

;   delta-y is bigger
_yBigger        lda DELTAY
                sta COUNTR              ; store it in counter
                sta ENDPT               ; and endpoint

                lsr A                   ; /2
                sta ACCX                ; store in x accum.

; ----------------------------------------
; Now we start the actual DRAWTO function!
; ----------------------------------------

_doDraw         lda COUNTR              ; if countr=0...
                beq _XIT                ;   no draw!

_next1          lda ACCY                ; add deltay
                clc                     ; to y accumulator
                adc DELTAY
                sta ACCY
                cmp ENDPT               ; at endpoint yet?
                bcc _doX                ;   no, go do x.

                lda ACCY                ; subtract endpt
                sec                     ; from y accumulator
                sbc ENDPT
                sta ACCY

                lda PLOTY               ; and increment
                clc                     ; the y position!
                adc INCY
                sta PLOTY

_doX            lda ACCX                ; add deltax to
                clc                     ; x accumulator
                adc DELTAX
                sta ACCX
                cmp ENDPT               ; at endpoint yet?
                bcc _plotIt             ;   no, go plot.

                lda ACCX                ; subtract endpt
                sec                     ; from x accumulator
                sbc ENDPT
                sta ACCX

                lda PLOTX               ; and increment
                clc                     ; plot x
                adc INCX
                sta PLOTX

_plotIt         jsr PlotPoint           ; plot the point!

                dec COUNTR              ; more to draw?
                bne _next1              ;   yes!

                lda #TRUE
                sta isDirtyPlayfield

_XIT            rts
                .endproc
