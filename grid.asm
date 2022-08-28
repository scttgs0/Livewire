;======================================
; Draw Grid
;======================================
DrawGrid        .proc
                lda #1                  ; tell interrupt
                sta INTRFG              ; it's intro
                jsr SNDOFF              ; turn off sound

                lda #$20                ; turn off top
                sta DMAC1               ; of screen by
                lda #0                  ; shutting off
                sta GRAC1               ; DMA & graphics

                ldx #3                  ; turn off shorts
_clrShorts      sta SHORTF,X
                dex
                bpl _clrShorts

                ldx #7                  ; turn off all projectiles
_clrPrjct       sta PROJAC,X
                dex
                bpl _clrPrjct

                jsr PMCLR               ; clear p/m area

                sta OFFSET              ; zero offset
                lda #6                  ; set 6 project.
                sta PAVAIL              ; available
                lda GRIDIX              ; get grid #
                lsr A                   ; divide
                lsr A                   ; by
                lsr A                   ; 8
                tax                     ; load appropriate

                ;lda C0TBL,X            ; grid color
                ;sta COLPF0
                ;lda C1TBL,X            ; object color 1
                ;sta COLPF1
                ;lda C2TBL,X            ; object color 2
                ;sta COLPF2

                lda OBSTBL,X            ; object speed
                sta OBJSPD
                lda GRIDIX              ; get grid
                and #7                  ; shape index
                tax                     ; load:
                lda OBCNT0,X            ; type 0
                sta NUMOBJ              ; object count
                lda OBCNT1,X            ; type 1
                sta NUMOBJ+1            ; object count
                lda OBCNT2,X            ; type 2
                sta NUMOBJ+2            ; object count
                lda OBCNT3,X            ; type 3
                sta NUMOBJ+3            ; object count
                lda OBCNT4,X            ; type 4
                sta NUMOBJ+4            ; object count
                ldx #4                  ; adjust all
DIFFAD          lda NUMOBJ,X            ; object counts
                clc                     ; by adding
                adc DIFF                ; difficulty
                sta NUMOBJ,X            ; and save
                dex
                bpl DIFFAD

                lda GRDNUM              ; get grid #
                asl A                   ; multiply
                asl A                   ; by 16
                asl A
                asl A
                sta GRDADJ              ; save
                sta GRDWK               ; save
                tax                     ; set x index
                lda #16                 ; load 16 bytes
                sta GRDWK2
GRDLIN          lda CX,X                ; get close x
                sta PLOTX
                lda CY,X                ; get close y
                sta PLOTY
                lda FX,X                ; get far x
                sta DRAWX
                lda FY,X                ; get far y
                sta DRAWY

                ;lda COLPF0              ; invisible?
                ;beq NOGRD1              ;  yes, don't draw

                jsr PLOTCL              ; plot close point
                jsr DRAW                ; draw to far

NOGRD1          dec GRDWK2              ; continue drawing
                beq GRDBO1              ; until all 16

                inc GRDWK               ; lines are done
                ldx GRDWK
                jmp GRDLIN

GRDBO1          ldx GRDADJ              ; now draw 15
                stx GRDWK               ; close grid
                lda #15                 ; border lines
                sta GRDWK2
GRDBL1          lda CX,X                ; get close x
                sta PLOTX
                lda CY,X                ; get close y
                sta PLOTY
                lda CX+1,X              ; next close x
                sta DRAWX
                clc                     ; find point
                adc PLOTX               ; between them
                ror A
                sta XWORK               ; and save it!
                lda CY+1,X              ; next close y
                sta DRAWY
                clc                     ; find point
                adc PLOTY               ; between them
                ror A
                sta YWORK               ; and save it!
                lda #15                 ; set up a work
                sec                     ; area to hold
                sbc GRDWK2              ; the points
                sta GRID                ; between lines
                jsr GridCoordSave       ; and save them

                ;lda COLPF0             ; invisible grid?
                ;beq NOGRD2             ;   yes, don't draw

                jsr PLOTCL              ; plot close point1
                jsr DRAW                ; draw to point 2

NOGRD2          dec GRDWK2              ; more lines?
                beq GRDBO2              ;   no!

                inc GRDWK               ; increment to
                ldx GRDWK               ; next line
                jmp GRDBL1              ; and loop

GRDBO2          ldx GRDADJ              ; now draw 15
                stx GRDWK               ; far grid
                lda #15                 ; border lines
                sta GRDWK2
                sta OFFSET              ; and set offset
GRDBL2          lda FX,X                ; get far x
                sta PLOTX
                lda FY,X                ; get far y
                sta PLOTY
                lda FX+1,X              ; next far x
                sta DRAWX
                clc                     ; and find
                adc PLOTX               ; midpoint
                ror A                   ; between them
                sta XWORK               ; and save it!
                lda FY+1,X              ; next far y
                sta DRAWY
                clc                     ; and find
                adc PLOTY               ; midpoint
                ror A                   ; between them
                sta YWORK               ; and save it!
                lda #15                 ; use the same
                sec                     ; work area
                sbc GRDWK2              ; to hold the
                sta GRID                ; midpoints
                jsr GridCoordSave       ; and save them

                ;lda COLPF0             ; invisible grid?
                ;beq NOGRD3             ;   yes, don't draw

                jsr PLOTCL              ; plot far point 1
                jsr DRAW                ; draw to point 2

NOGRD3          dec GRDWK2              ; more lines?
                beq GenCoordTbl         ;   no!

                inc GRDWK               ; increment to
                ldx GRDWK               ; next line
                jmp GRDBL2              ; and loop

                .endproc


;======================================
; Generate Coordinate Table
;--------------------------------------
; This section builds the SEGX, SEGY,
; RIMX and RIMY tables. The SEGX/Y
; tables are points up and down the
; grid for projectiles and objects.
; The RIMX/Y tables are for the
; positioning of shorts.
;======================================
GenCoordTbl     .proc
                lda #0
                sta GRIDNO
DIVCTL          tax
                lda SEGX,X              ; set up segwk
                sta SEGWK               ; with end
                lda SEGX+15,X           ; coordinates
                sta SEGWK+16
                jsr DivideSEGWK         ; divide segwk

                ldx GRIDNO
                ldy #0
COPY1           lda SEGWK,Y             ; copy segwk table to segx
                sta SEGX,X
                inx
                iny
                cpy #16
                bne COPY1

; NOW THE Y COORDS
                ldx GRIDNO
                lda SEGY,X              ; set up segwk
                sta SEGWK               ; with end
                lda SEGY+15,X           ; coordinates
                sta SEGWK+16
                jsr DivideSEGWK         ; divide segwk

                ldx GRIDNO
                ldy #0
COPY2           lda SEGWK,Y             ; copy segwk table to segy
                sta SEGY,X
                inx
                iny
                cpy #16
                bne COPY2


; ----------------------------
; NOW GENERATE RIM COORDINATES
; ----------------------------

                ldx GRIDNO
                lda RIMX,X              ; set up segwk
                sta SEGWK               ; with end
                lda RIMX+15,X           ; coordinates
                sta SEGWK+16
                jsr DivideSEGWK         ; divide segwk

                ldx GRIDNO
                ldy #0
COPY3           lda SEGWK,Y             ; copy segwk table to rimx
                sta RIMX,X
                inx
                iny
                cpy #16
                bne COPY3

; NOW THE RIM Y COORDS
                ldx GRIDNO
                lda RIMY,X              ; set up segwk
                sta SEGWK               ; with end
                lda RIMY+15,X           ; coordinates
                sta SEGWK+16
                jsr DivideSEGWK         ; divide segwk

                ldx GRIDNO
                ldy #0
COPY4           lda SEGWK,Y             ; copy segwk table to rimy
                sta RIMY,X
                inx
                iny
                cpy #16
                bne COPY4

                lda GRIDNO              ; do all 15 grid lines
                clc
                adc #16
                sta GRIDNO
                cmp #240                ; all done?
                beq ENDDVC              ;   you bet!

                jmp DIVCTL              ;   loop back!

ENDDVC          ;lda #$3D               ; restart the display
                ;sta DMAC1              ; after grid is drawn
                ;lda #$03
                ;sta GRAC1

                lda #0                  ; no more intro status
                sta INTRFG
                rts
                .endproc


;======================================
; Divide SEGWK Table
;--------------------------------------
; This routine examines the first
; and last bytes in the SEGWK
; table and fills the bytes in
; between with an even transition
; from one endpoint to the other
;======================================
DivideSEGWK     .proc
                lda #16
                sta STEP
                sta NEXT
                lsr A
                sta DEST
DIVLP2          lda #0
                sta LAST
DIVLP1          ldx LAST
                lda SEGWK,X
                ldx NEXT
                clc
                adc SEGWK,X
                ror A
                ldx DEST
                sta SEGWK,X
                lda LAST
                clc
                adc STEP
                sta LAST
                adc STEP
                cmp #17
                bcs NOSTEP

                sta NEXT
                lda DEST
                clc
                adc STEP
                sta DEST
                jmp DIVLP1

NOSTEP          lda STEP
                lsr A
                sta STEP
                sta NEXT
                lsr A
                beq ENDDIV

                sta DEST
                jmp DIVLP2

ENDDIV          rts
                .endproc


;======================================
; Grid Coordinates Save
;======================================
GridCoordSave   .proc
                lda GRID
                asl A                   ; *16
                asl A
                asl A
                asl A
                clc                     ; add the offset value
                adc OFFSET
                tax                     ; save in index

                lda XWORK               ; get x work and save
                sta SEGX,X
                lda YWORK               ; get y work and save
                sta SEGY,X

                lda OFFSET              ; don't continue if offset >0
                bne _XIT

                lda PLOTX               ; get plotx and save
                sta RIMX,X
                lda PLOTY               ; get ploty and save
                sta RIMY,X
                lda DRAWX               ; get drawx and save
                sta RIMX+15,X
                lda DRAWY               ; get drawy and save
                sta RIMY+15,X
_XIT            rts
                .endproc
