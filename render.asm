;======================================
; CLEAR Player-MISSILES
;======================================
PMCLR           .proc
;                lda #0                  ; put 255
;                tax                     ; zeros in
;PMCLP           sta MISSLS,X            ; each p/m
;                sta PL0,X               ; area
;                sta PL1,X
;                sta PL2,X
;                sta PL3,X
;                dex
;                bne PMCLP

                rts
                .endproc


;======================================
; CLEAR SCREEN
;======================================
CLRSC           .proc
                lda #>Playfield         ; initial
                sta HI                  ; display
                lda #<Playfield         ; address
                sta LO                  ; work area
                ldx #20                 ; clear 20 groups
CLRSC2          ldy #0                  ; of 256 bytes
                tya                     ; (5120 bytes)
CLRSC3          sta (LO),Y
                dey
                bne CLRSC3

                dex
                bne CLRSC4

                lda #TRUE
                sta isDirtyPlayfield
                rts

CLRSC4          inc HI
                jmp CLRSC2

                .endproc


;======================================
; GR. 7+ PLOTTER ROUTINE
;--------------------------------------
; (SEE A.N.A.L.O.G. #11)
;======================================
PLOTCL          .proc
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
                lda #<Playfield         ; add the display
                clc                     ; address to get
                adc LO                  ; the actual
                sta LO                  ; address of the
                lda #>Playfield         ; byte that will
                adc HI                  ; be altered for
                sta HI                  ; the plot.
                lda PLOTX               ; mask plotx for
                and #3                  ; plot index,
                tax                     ; place in x.
                lda PLOTX               ; get plotx and
                lsr A                   ; divide
                lsr A                   ; by 4,
                sta YOFSET
                tay
                lda (LO),Y
                and BMASK2,X
                cmp COLR1,X
                beq PABORT

                ldy COLOR               ; get color
                lda BMASK2,X            ; and mask off
                and COLORS,Y            ; pixel position
                sta HOLD                ; save it,
                lda BMASK1,X            ; mask off pixel
                ldy YOFSET              ; of the address
                and (LO),Y              ; to be altered
                ora HOLD                ; set the plot
                sta (LO),Y              ; bits and store!

PABORT          lda #TRUE
                sta isDirtyPlayfield
                rts
                .endproc

;--------------------------------------

;
; PLOT MASK TABLES
;

COLORS          .byte $00,$55,$AA,$FF
BMASK1          .byte $3F,$CF,$F3,$FC
BMASK2          .byte $C0,$30,$0C,$03
COLR1           .byte $40,$10,$04,$01


;======================================
; DRAW HANDLER
;======================================
DRAW            .proc
                lda DRAWY
                cmp PLOTY               ; is drawy>ploty?
                bcc YMINUS              ;   no!

                sec                     ; subtract
                sbc PLOTY               ; ploty from drawy
                sta DELTAY              ; and save difference.
                lda #1                  ; y increment
                sta INCY                ; = 1 (down)
                bne XVEC                ; branch!

YMINUS          lda PLOTY               ; subtract
                sec                     ; drawy
                sbc DRAWY               ; from ploty
                sta DELTAY              ; and save difference.
                lda #255                ; y increment
                sta INCY                ; = -1 (up)
XVEC            lda DRAWX               ; is drawx
                cmp PLOTX               ; > plotx?
                bcc XMINUS              ;   no!

                sec                     ; subtract
                sbc PLOTX               ; plotx from drawx
                sta DELTAX              ; and save difference.
                lda #1                  ; x increment
                sta INCX                ; is 1 (right)
                bne VECSET              ; branch!

XMINUS          lda PLOTX               ; subtract
                sec                     ; drawx from
                sbc DRAWX               ; plotx
                sta DELTAX              ; and save difference.
                lda #255                ; x increment
                sta INCX                ; is -1 (left)
VECSET          lda #0                  ; zero out:
                sta ACCY                ; y accumulator
                sta ACCX                ; x accumulator
                lda DELTAX              ; is deltax>
                cmp DELTAY              ; deltay?
                bcc YMAX                ;   no!

                sta COUNTR              ; save deltax
                sta ENDPT               ; in countr, endpt.
                lsr A                   ; divide by 2 and
                sta ACCY                ; store in y accum.
                jmp DRAWGO              ; start draw

YMAX            lda DELTAY              ; deltay larger,
                sta COUNTR              ; store it in
                sta ENDPT               ; countr, endpt.
                lsr A                   ; divide by 2 and
                sta ACCX                ; store in x accum.

; -----------------------
; NOW WE START THE ACTUAL
; DRAWTO FUNCTION!
; -----------------------

DRAWGO          lda COUNTR              ; if countr=0...
                beq DRWEND              ; no draw!

BEGIN           lda ACCY                ; add deltay
                clc                     ; to y accumulator
                adc DELTAY
                sta ACCY
                cmp ENDPT               ; at endpoint yet?
                bcc BEGIN2              ;   no, go do x.

                lda ACCY                ; subtract endpt
                sec                     ; from y accumulator
                sbc ENDPT
                sta ACCY
                lda PLOTY               ; and increment
                clc                     ; the y position!
                adc INCY
                sta PLOTY
BEGIN2          lda ACCX                ; add deltax to
                clc                     ; x accumulator
                adc DELTAX
                sta ACCX
                cmp ENDPT               ; at endpoint yet?
                bcc PLOTIT              ;   no, go plot.

                lda ACCX                ; subtract endpt
                sec                     ; from x accumulator
                sbc ENDPT
                sta ACCX
                lda PLOTX               ; and increment
                clc                     ; plot x
                adc INCX
                sta PLOTX
PLOTIT          jsr PLOTCL              ; plot the point!

                dec COUNTR              ; more to draw?
                bne BEGIN               ;   yes!

DRWEND          rts
                .endproc
