;======================================
; OBJECT HANDLER
;======================================
OBJHAN          .proc
                lda OBJNUM              ; increment
                clc                     ; object #
                adc #1
                cmp #6                  ; done?
                bne STONUM              ; no, continue.

                lda #$FF                ; reset
                sta OBJNUM              ; object #
                rts                     ; and exit.

STONUM          sta OBJNUM              ; save obj #
OBHLP1          ldx OBJNUM              ; get obj #
                lda OBJPRS,X            ; obj present?
                beq OBJHAN              ; no!

OBLIVE          lda OBJSEG,X            ; within 2 units
                cmp #2                  ; of rim?
                bcc NOOBFI              ; yes, don't fire

                .randomByte             ; random chance
                and #$0F                ; of shooting
                bne NOOBFI              ; don't shoot

                lda PROJAC              ; proj. 0 active?
                bne TRYPR1              ; yes, ignore!

                ldy #0                  ; force branch
                beq STOBFI              ; to store it

TRYPR1          lda PROJAC+1            ; proj. 1 active?
                bne NOOBFI              ; yes, no fire

                ldy #1                  ; set index
STOBFI          lda OBJSEG,X            ; initialize
                lsr A                   ; projectile
                sta PROJSG,Y            ; segment #
                lda OBJGRD,X            ; and
                sta PROGRD,Y            ; sub-grid #
                asl A                   ; multiply
                asl A                   ; by
                asl A                   ; 16
                asl A                   ; and
                sta PROJGN,Y            ; save index!
                lda #$FF                ; set increment
                sta PROINC,Y            ; (toward rim)
                lda #21                 ; start the
                sta FIRSOU              ; fire sound
                lda #1                  ; and
                sta PROJAC,Y            ; projectile
NOOBFI          lda #0                  ; set color 0
                sta COLOR               ; to erase object
                jsr DRWOBJ              ; and erase it

                ldx OBJNUM
                lda OBDED2,X            ; obj dead?
                beq NOOKIL              ; yes! start

                jsr FLASH               ; death flash

                ldx OBJNUM
                ldy OBJTYP,X            ; get object type
                lda POINT1,Y            ; get points
                sta SCOADD+1            ; and ready
                lda POINT2,Y            ; the score
                sta SCOADD+2            ; add value
                jsr AddToScore          ; add to score!

                ldx OBJNUM
                jmp KILOBJ              ; then kill obj.

NOOKIL          lda OBJSEG,X            ; increment
                sec                     ; object's
                sbc OBJINC,X            ; segment
                sta OBJSEG,X            ; position
                bmi KILOBJ              ; past rim!

                cmp #30                 ; type 3 past end?
                bne NOTOT3              ; nope!

                inc NUMOBJ+2            ; start type 2
                bne KILOBJ              ; force branch

NOTOT3          cmp #10                 ; at type 3 turn?
                bne OBHLP2              ; no!

                lda OBJTYP,X            ; is it
                cmp #3                  ; type 3?
                bne OBHLP2              ; no!

                lda #$FF                ; reverse object
                sta OBJINC,X            ; increment
OBHLP2          lda OBJTYP,X            ; is object
                cmp #2                  ; type 2?
                bne SETHUE              ; no, set color

                .randomByte             ; get random
                and #1                  ; direction
                tay                     ; for type 2
                lda OBJGRD,X            ; and
                clc                     ; add or
                adc ADDSB1,Y            ; subtract 1
                cmp #15                 ; past limit?
                bcs SETHUE              ; yes!

                sta OBJGRD,X            ; save new pos.
SETHUE          lda OBJTYP,X            ; get obj. type
                tax                     ; and get
                lda OBJHUE,X            ; color #
                sta COLOR               ; save it
                jsr DRWOBJ              ; and draw object!

                jmp OBJHAN              ; do next one

KILOBJ          lda #0                  ; object is no
                sta OBJPRS,X            ; longer alive
                lda #21                 ; set up
                sta OBDSOU              ; death sound
                lda OBJSEG,X            ; check
                bpl JOBHAN              ; for a

                lda OBJGRD,X            ; collision
                cmp PLRGRD              ; with player
                bne CKSHOR              ; no hit

                lda #1                  ; hit,
                sta KILPLR              ; kill player!
                bne JOBHAN              ; next object

CKSHOR          lda OBJTYP,X            ; object
                cmp #1                  ; type 1?
                bne JOBHAN              ; nope!

                ldy #3                  ; try short:
TRYSHO          lda SHORTF,Y            ; short available?
                beq INISHO              ; yup!

                dey                     ; keep...
                bpl TRYSHO              ; trying!

                bmi JOBHAN              ; no short avail!

INISHO          lda OBJGRD,X            ; multiply the
                asl A                   ; object's
                asl A                   ; sub-grid #
                asl A                   ; by 16...
                asl A
                clc
                adc #8                  ; and add 8 for
                sta SHORTX,Y            ; the short index
                lda #1                  ; short is
                sta SHORTF,Y            ; alive!
                .randomByte             ; randomize...
                and #1                  ; short...
                sta SHORTD,Y            ; direction
                .randomByte             ; and that...
                and #$3F                ; direction's...
                sta SHORTT,Y            ; time!
JOBHAN          jmp OBJHAN              ; next object

                .endproc


;======================================
; DRAW OBJECT
;======================================
DRWOBJ          .proc
                ldx OBJNUM              ; get object #
                lda OBJGRD,X            ; get sub-grid #
                asl A                   ; multiply
                asl A                   ; by 16...
                asl A
                asl A
                sta HLDGRD              ; and save.
                lda OBJSEG,X            ; divide
                lsr A                   ; segment by 2
                bcs ODDSEG              ; process odd #

                clc                     ; it's even, add
                adc HLDGRD              ; grid index
                tay                     ; put in y reg.
                lda SEGX,Y              ; get object's
                sta PLOTX               ; x position
                sta SAVEX               ; and save
                lda SEGY,Y              ; get object's
                sta PLOTY               ; y position
                sta SAVEY               ; and save
                jmp ODDSKP              ; skip odd routine

ODDSEG          clc                     ; it's odd, add
                adc HLDGRD              ; grid index
                tay                     ; put in y reg.
                lda SEGX,Y              ; get object's
                clc                     ; x pos, add
                adc SEGX+1,Y            ; next x pos.
                ror A                   ; get average
                sta PLOTX               ; put in plot x
                sta SAVEX               ; and save
                lda SEGY,Y              ; get object's
                clc                     ; y pos, add
                adc SEGY+1,Y            ; next y pos.
                ror A                   ; get average
                sta PLOTY               ; put in plot y
                sta SAVEY               ; and save
ODDSKP          lda #30                 ; now calculate
                sec                     ; the object's
                sbc OBJSEG,X            ; size based on
                lsr A                   ; its position
                and #$FE                ; on the grid
                asl A
                asl A
                tay                     ; put index in y
                ldx #0                  ; now copy part
COPYSZ          lda SIZTBL,Y            ; of the size
                sta SIZEWK,X            ; table to a
                iny                     ; size work area
                inx                     ; this table holds
                cpx #8                  ; 8 size values
                bne COPYSZ              ; based on dist.

                ldx OBJNUM              ; get object #
                lda OBJTYP,X            ; and its type
                asl A                   ; and multiply
                asl A                   ; by 8 for an
                asl A                   ; index into
                sta SHAPIX              ; the shape table
                lda #8                  ; max 8 lines in
                sta SHAPCT              ; each object
DOBLP           ldx SHAPIX              ; get line#
                lda OBJDIR,X            ; & its direction
                tay                     ; a negative #
                bmi ENDOBJ              ; indicates end

                lda PXINC,Y             ; get x increment
                sta XI                  ; of line,
                lda PYINC,Y             ; y increment
                sta YI                  ; of line,
                lda OBJLEN,X            ; absolute length
                tay                     ; of line then
                lda SIZEWK,Y            ; scaled length
                sta LENGTH              ; and store!
PLOTOB          lda PLOTX               ; this section
                clc                     ; adjusts the
                adc XI                  ; x and y plot
                sta PLOTX               ; values...
                lda PLOTY
                clc
                adc YI
                sta PLOTY
                lda SHAPIX              ; don't plot
                beq NOPLT1              ; first line!

                jsr PLOTCL              ; plot point

NOPLT1          lda PLOTY               ; increment y
                clc                     ; again to adjust
                adc YI                  ; for gr. 7+
                sta PLOTY               ; aspect ratio
                lda SHAPIX              ; don't plot
                beq NOPLT2              ; first line

                jsr PLOTCL              ; plot point

NOPLT2          dec LENGTH              ; end of line?
                bpl PLOTOB              ; nope!

                inc SHAPIX              ; next line
                dec SHAPCT              ; last line?
                bne DOBLP               ; not yet!

ENDOBJ          rts                     ; all done!
                .endproc


;======================================
; SHORT HANDLER
;======================================
SHOHAN          .proc
                ldx #3                  ; max. 4 shorts
SHHANL          lda SHORTF,X            ; short alive?
                beq HANNXS              ; no, do next

                ldy SHORTD,X            ; get short dir.
                lda SHORTX,X            ; get x pos.
                clc                     ; and adjust
                adc ADDSUB,Y            ; position
                cmp #240                ; on grid?
                bcs RESSHD              ; no! don't move

                sta SHORTX,X            ; ok, save pos.
                dec SHORTT,X            ; direction change?
                bpl HANNXS              ; no!

RESSHD          .randomByte             ; get a random
                and #$3F                ; direction time
                sta SHORTT,X            ; 0-63 & save
                and #1                  ; random direction
                sta SHORTD,X            ; 0-1 & save
HANNXS          dex                     ; more shorts?
                bpl SHHANL              ; yup!

                rts                     ; all done!
                .endproc
