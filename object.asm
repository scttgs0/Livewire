;======================================
; OBJECT HANDLER
;======================================
ObjectHandler   .proc
                lda OBJNUM              ; increment
                clc                     ; object #
                adc #1
                cmp #6                  ; done?
                bne _storeNum           ;   no, continue.

                lda #$FF                ; reset
                sta OBJNUM              ; object #
                rts

_storeNum       sta OBJNUM              ; save obj #
                ldx OBJNUM              ; get obj #
                lda OBJPRS,X            ; obj present?
                beq ObjectHandler       ;   no!

                lda OBJSEG,X            ; within 2 units
                cmp #2                  ; of rim?
                bcc _noObjFI            ;   yes, don't fire

                .randomByte             ; random chance
                and #$0F                ; of shooting
                bne _noObjFI            ; don't shoot

                lda PROJAC              ; proj. 0 active?
                bne _tryProj1           ;   yes, ignore!

                ldy #0                  ; force branch
                beq _storeObjFI         ; to store it

_tryProj1       lda PROJAC+1            ; proj. 1 active?
                bne _noObjFI            ;    yes, no fire

                ldy #1                  ; set index
_storeObjFI     lda OBJSEG,X            ; initialize
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
_noObjFI        lda #0                  ; set color 0
                sta COLOR               ; to erase object
                jsr DrawObject          ; and erase it

                ldx OBJNUM
                lda OBDED2,X            ; obj dead?
                beq _noObjKill          ;   yes! start

                jsr Flash               ; death flash

                ldx OBJNUM
                ldy OBJTYP,X            ; get object type
                lda POINT1,Y            ; get points
                sta SCOADD+1            ; and ready
                lda POINT2,Y            ; the score
                sta SCOADD+2            ; add value
                jsr AddToScore          ; add to score!

                ldx OBJNUM
                jmp _killObj            ; then kill obj.

_noObjKill      lda OBJSEG,X            ; increment
                sec                     ; object's
                sbc OBJINC,X            ; segment
                sta OBJSEG,X            ; position
                bmi _killObj            ; past rim!

                cmp #30                 ; type 3 past end?
                bne _notType3           ;   nope!

                inc NUMOBJ+2            ; start type 2
                bne _killObj            ; force branch

_notType3       cmp #10                 ; at type 3 turn?
                bne _1                  ;   no!

                lda OBJTYP,X            ; is it type 3?
                cmp #3
                bne _1                  ;   no!

                lda #$FF                ; reverse object
                sta OBJINC,X            ; increment
_1              lda OBJTYP,X            ; is object type 2?
                cmp #2
                bne _setHue             ;   no, set color

                .randomByte             ; get random
                and #1                  ; direction
                tay                     ; for type 2
                lda OBJGRD,X            ; and
                clc
                adc AddOrSub1,Y         ; add or subtract 1
                cmp #15                 ; past limit?
                bcs _setHue             ;   yes!

                sta OBJGRD,X            ; save new pos.
_setHue         lda OBJTYP,X            ; get obj. type
                tax                     ; and get
                lda OBJHUE,X            ; color #
                sta COLOR               ; save it
                jsr DrawObject          ; and draw object!

                jmp ObjectHandler       ; do next one

_killObj        lda #0                  ; object is no
                sta OBJPRS,X            ; longer alive
                lda #21                 ; set up
                sta OBDSOU              ; death sound
                lda OBJSEG,X            ; check
                bpl _doitagain          ; for a

                lda OBJGRD,X            ; collision with player?
                cmp PlyrGridPos
                bne _chkShort           ;   no hit

                lda #TRUE               ;   hit, kill player!
                sta isPlayerDead
                bra _doitagain          ; next object

_chkShort       lda OBJTYP,X            ; object
                cmp #1                  ; type 1?
                bne _doitagain          ;   nope!

                ldy #3                  ; try short:
_tryShort       lda SHORTF,Y            ; short available?
                beq _initShort          ; yup!

                dey                     ; keep...
                bpl _tryShort           ; trying!

                bmi _doitagain          ; no short avail!

_initShort      lda OBJGRD,X            ; multiply the
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
_doitagain      jmp ObjectHandler       ; next object

                .endproc


;======================================
; DRAW OBJECT
;======================================
DrawObject      .proc
                ldx OBJNUM              ; get object #
                lda OBJGRD,X            ; get sub-grid #
                asl A                   ; multiply
                asl A                   ; by 16...
                asl A
                asl A
                sta HLDGRD              ; and save.
                lda OBJSEG,X            ; divide
                lsr A                   ; segment by 2
                bcs _oddSeg             ; process odd #

                clc                     ; it's even, add
                adc HLDGRD              ; grid index
                tay                     ; put in y reg.
                lda SEGX,Y              ; get object's
                sta PLOTX               ; x position
                sta SAVEX               ; and save
                lda SEGY,Y              ; get object's
                sta PLOTY               ; y position
                sta SAVEY               ; and save
                jmp _oddSkip            ; skip odd routine

_oddSeg         clc                     ; it's odd, add
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

_oddSkip        lda #30                 ; now calculate
                sec                     ; the object's
                sbc OBJSEG,X            ; size based on
                lsr A                   ; its position
                and #$FE                ; on the grid
                asl A
                asl A
                tay                     ; put index in y
                ldx #0                  ; now copy part
_next1          lda SIZTBL,Y            ; of the size
                sta SIZEWK,X            ; table to a
                iny                     ; size work area
                inx                     ; this table holds
                cpx #8                  ; 8 size values
                bne _next1              ; based on dist.

                ldx OBJNUM              ; get object #
                lda OBJTYP,X            ; and its type
                asl A                   ; and multiply
                asl A                   ; by 8 for an
                asl A                   ; index into
                sta SHAPIX              ; the shape table
                lda #8                  ; max 8 lines in
                sta SHAPCT              ; each object
_next2          ldx SHAPIX              ; get line#
                lda OBJDIR,X            ; & its direction
                tay                     ; a negative #
                bmi _XIT                ; indicates end

                lda PXINC,Y             ; get x increment
                sta XI                  ; of line,
                lda PYINC,Y             ; y increment
                sta YI                  ; of line,
                lda OBJLEN,X            ; absolute length
                tay                     ; of line then
                lda SIZEWK,Y            ; scaled length
                sta LENGTH              ; and store!
_next3          lda PLOTX               ; this section
                clc                     ; adjusts the
                adc XI                  ; x and y plot
                sta PLOTX               ; values...
                lda PLOTY
                clc
                adc YI
                sta PLOTY
                lda SHAPIX              ; don't plot
                beq _noPlot1            ; first line!

                jsr PlotPoint           ; plot point

_noPlot1        lda PLOTY               ; increment y
                clc                     ; again to adjust
                adc YI                  ; for gr. 7+
                sta PLOTY               ; aspect ratio
                lda SHAPIX              ; don't plot
                beq _noPlot2            ; first line

                jsr PlotPoint           ; plot point

_noPlot2        dec LENGTH              ; end of line?
                bpl _next3              ;   nope!

                inc SHAPIX              ; next line
                dec SHAPCT              ; last line?
                bne _next2              ;   not yet!

_XIT            rts
                .endproc


;======================================
; SHORT HANDLER
;======================================
ShortHandler    .proc
                ldx #3                  ; max. 4 shorts
_next1          lda SHORTF,X            ; short alive?
                beq _nextShort          ;   no, do next

                ldy SHORTD,X            ; get short dir.
                lda SHORTX,X            ; get x pos.
                clc                     ; and adjust
                adc AddOrSub2,Y         ; position
                cmp #240                ; on grid?
                bcs _resetShort         ;   no! don't move

                sta SHORTX,X            ; ok, save pos.
                dec SHORTT,X            ; direction change?
                bpl _nextShort          ;   no!

_resetShort     .randomByte             ; get a random
                and #$3F                ; direction time
                sta SHORTT,X            ; 0-63 & save
                and #1                  ; random direction
                sta SHORTD,X            ; 0-1 & save
_nextShort      dex                     ; more shorts?
                bpl _next1              ; yup!

                rts
                .endproc
