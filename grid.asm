;======================================
; DRAW GRID
;======================================
DRGRID          .proc
                lda #1                  ; tell interrupt
                sta INTRFG              ; it's intro
                jsr SNDOFF              ; turn off sound

                lda #$20                ; turn off top
                sta DMAC1               ; of screen by
                lda #0                  ; shutting off
                sta GRAC1               ; DMA & graphics
                ldx #3                  ; turn off shorts
CLSHRT          sta SHORTF,X
                dex
                bpl CLSHRT

                ldx #7                  ; turn off
CLPRJC          sta PROJAC,X            ; all projectiles
                dex
                bpl CLPRJC

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
                ;beq NOGRD1              ; yes, don't draw

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
                jsr GRIDSV              ; and save them

                ;lda COLPF0             ; invisible grid?
                ;beq NOGRD2             ; yes, don't draw

                jsr PLOTCL              ; plot close point1
                jsr DRAW                ; draw to point 2

NOGRD2          dec GRDWK2              ; more lines?
                beq GRDBO2              ; no!

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
                jsr GRIDSV              ; and save them

                ;lda COLPF0             ; invisible grid?
                ;beq NOGRD3             ; yes, don't draw

                jsr PLOTCL              ; plot far point 1
                jsr DRAW                ; draw to point 2

NOGRD3          dec GRDWK2              ; more lines?
                beq GENCOO              ; no!

                inc GRDWK               ; increment to
                ldx GRDWK               ; next line
                jmp GRDBL2              ; and loop

                .endproc


; -----------------------------
; NOW GENERATE COORDINATE TABLE
;
; THIS SECTION BUILDS THE SEGX,
; SEGY, RIMX AND RIMY TABLES.
; THE SEGX&Y TABLES ARE POINTS
; UP AND DOWN THE GRID FOR PRO-
; JECTILES AND OBJECTS.  THE
; RIMX&Y TABLES ARE FOR THE
; POSITIONING OF SHORTS.
; -----------------------------

GENCOO          .proc
                lda #0
                sta GRIDNO
DIVCTL          tax
                lda SEGX,X              ; set up segwk
                sta SEGWK               ; with end
                lda SEGX+15,X           ; coordinates
                sta SEGWK+16
                jsr DIVIDE              ; divide segwk

                ldx GRIDNO
                ldy #0
COPY1           lda SEGWK,Y             ; copy segwk
                sta SEGX,X              ; table to segx
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
                jsr DIVIDE              ; divide segwk

                ldx GRIDNO
                ldy #0
COPY2           lda SEGWK,Y             ; copy segwk
                sta SEGY,X              ; table to segy
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
                jsr DIVIDE              ; divide segwk

                ldx GRIDNO
                ldy #0
COPY3           lda SEGWK,Y             ; copy segwk
                sta RIMX,X              ; table to rimx
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
                jsr DIVIDE              ; divide segwk

                ldx GRIDNO
                ldy #0
COPY4           lda SEGWK,Y             ; copy segwk
                sta RIMY,X              ; table to rimy
                inx
                iny
                cpy #16
                bne COPY4

                lda GRIDNO              ; do all 15
                clc                     ; grid lines
                adc #16
                sta GRIDNO
                cmp #240                ; all done?
                beq ENDDVC              ; you bet!

                jmp DIVCTL              ; loop back!

ENDDVC          lda #$3D                ; restart
                sta DMAC1               ; the display
                lda #$03                ; after grid
                sta GRAC1               ; is drawn
                lda #0                  ; no more
                sta INTRFG              ; intro status
                rts                     ; finis!
                .endproc


;======================================
; DIVIDE SEGWK TABLE
;--------------------------------------
; This routine examines the first
; and last bytes in the SEGWK
; table and fills the bytes in
; between with an even transition
; from one endpoint to the other
;======================================
DIVIDE          .proc
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
; GRID COORDINATES SAVE
;======================================
GRIDSV          .proc
                lda GRID
                asl A                   ; *2
                asl A                   ; *4
                asl A                   ; *8
                asl A                   ; *16
                clc                     ; add the
                adc OFFSET              ; offset value
                tax                     ; save in index
                lda XWORK               ; get x work
                sta SEGX,X              ; and save
                lda YWORK               ; get y work
                sta SEGY,X              ; and save
                lda OFFSET              ; don't continue
                bne SAVEND              ; if offset >0

                lda PLOTX               ; get plotx
                sta RIMX,X              ; and save
                lda PLOTY               ; get ploty
                sta RIMY,X              ; and save
                lda DRAWX               ; get drawx
                sta RIMX+15,X           ; and save
                lda DRAWY               ; get drawy
                sta RIMY+15,X           ; and save
SAVEND          rts                     ; all done!
                .endproc
