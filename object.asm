
;======================================
; OBJECT HANDLER
;======================================
ObjectHandler   .proc
_repeat         lda OBJNUM              ; increment object #
                clc
                adc #1
                cmp #6                  ; done?
                bne _storeNum           ;   no, continue.

                lda #$FF                ; reset object #
                sta OBJNUM

                jsr BlitPlayfield
                rts

_storeNum       sta OBJNUM              ; save obj #
                ldx OBJNUM              ; get obj #
                lda isObjPresent,X      ; obj present?
                beq _repeat             ;   no!

                lda OBJSEG,X            ; within 2 units
                cmp #2                  ; of rim?
                bcc _noObjFire          ;   yes, don't fire

                .frsRandomByte          ; random chance of shooting
                and #$0F
                bne _noObjFire          ; don't shoot

                lda isProjActive        ; proj. 0 active?
                bne _tryProj1           ;   yes, ignore!

                ldy #0                  ; force branch to store it
                beq _storeObjFire

_tryProj1       lda isProjActive+1      ; proj. 1 active?
                bne _noObjFire          ;    yes, no fire

                ldy #1                  ; set index
_storeObjFire   lda OBJSEG,X            ; initialize projectile segment #
                lsr
                sta PROJSG,Y
                lda OBJGRD,X            ; and sub-grid #
                sta ProjGridPos,Y
                asl                     ; *16
                asl
                asl
                asl
                sta ProjGridIndex,Y     ; save index!

                lda #$FF                ; set increment
                sta ProjIncrement,Y     ; (toward rim)

                lda #21                 ; start the fire sound
                sta FIRSOU

                lda #TRUE               ; projectile is active
                sta isProjActive,Y

_noObjFire      lda #0                  ; set color 0
                sta COLOR               ; to erase object
                jsr DrawObject          ; and erase it

                ldx OBJNUM
                lda OBDED2,X            ; obj dead?
                beq _noObjKill          ;   no

                jsr Flash               ;   yes! start death flash

                ldx OBJNUM
                ldy ObjectType,X        ; get object type
                lda POINT1,Y            ; get points
                sta SCOADD+1            ; and ready
                lda POINT2,Y            ; the score
                sta SCOADD+2            ; add value
                jsr AddToScore          ; add to score!

                ldx OBJNUM
                jmp _killObj            ; then kill obj.

_noObjKill      lda OBJSEG,X            ; increment object's segment position
                sec
                sbc OBJINC,X
                sta OBJSEG,X
                bmi _killObj            ; beyond rim!

                cmp #30                 ; type 3 past end?
                bne _notType3           ;   nope!

                inc NUMOBJ+2            ; start type 2
                bra _killObj

_notType3       cmp #10                 ; at type 3 turn?
                bne _1                  ;   no!

                lda ObjectType,X        ; is object type 3 (surge)?
                cmp #3
                bne _1                  ;   no!

                lda #$FF                ; reverse object increment
                sta OBJINC,X

_1              lda ObjectType,X        ; is object type 2 (arc)?
                cmp #2
                bne _setHue             ;   no, set color

                .frsRandomByte          ; get random direction for type 2
                and #1
                tay
                lda OBJGRD,X
                clc
                adc AddOrSub1,Y         ; add or subtract 1
                cmp #15                 ; beyond limit?
                bcs _setHue             ;   yes!

                sta OBJGRD,X            ; save new pos.

_setHue         lda ObjectType,X        ; get obj. type
                tax
                lda OBJHUE,X            ; and get color #
                sta COLOR               ; save it
                jsr DrawObject          ; and draw object!

                jmp _repeat             ; do next one

_killObj        lda #FALSE              ; object is no longer alive
                sta isObjPresent,X

                lda #21                 ; set up death sound
                sta OBDSOU

                lda OBJSEG,X
                bpl _doitagain

                lda OBJGRD,X            ; check for collision with player?
                cmp playerGridPos
                bne _chkShort           ;   no hit

                lda #TRUE               ;   hit, kill player!
                sta isPlayerDead
                bra _doitagain          ; next object

_chkShort       lda ObjectType,X        ; is object type 1 (voltage spike)?
                cmp #1
                bne _doitagain          ;   nope!

                ldy #3                  ; try short:
_tryShort       lda SHORTF,Y            ; short available?
                beq _initShort          ; yup!

                dey                     ; keep...
                bpl _tryShort           ; trying!

                bra _doitagain          ; no short avail!

_initShort      lda OBJGRD,X            ; object's sub-grid # *16
                asl                     ; *16
                asl
                asl
                asl
                clc
                adc #8                  ; and add 8 for the short index
                sta SHORTX,Y

                lda #1                  ; short is alive!
                sta SHORTF,Y

                .frsRandomByte          ; randomize short direction
                and #1
                sta SHORTD,Y

                .frsRandomByte          ; and that direction's time!
                and #$3F
                sta SHORTT,Y

_doitagain      jmp _repeat             ; next object

                .endproc


;======================================
; DRAW OBJECT
;======================================
DrawObject      .proc
                ldx OBJNUM              ; get object #
                lda OBJGRD,X            ; get sub-grid #
                asl                     ; *16
                asl
                asl
                asl
                sta HLDGRD              ; and save.

                lda OBJSEG,X            ; divide segment by 2
                lsr
                bcs _oddSeg             ; process odd #

;   process even
                clc                     ; it's even
                adc HLDGRD              ; add grid index
                tay

                lda SEGX,Y              ; get object's x position
                sta PLOTX
                sta SAVEX               ; and save

                lda SEGY,Y              ; get object's y position
                sta PLOTY
                sta SAVEY               ; and save

                jmp _oddSkip            ; skip odd routine

;   process odd
_oddSeg         clc                     ; it's odd
                adc HLDGRD              ; add grid index
                tay

                lda SEGX,Y              ; get object's x pos
                clc
                adc SEGX+1,Y            ; add next x pos.
                ror A                   ; get average
                sta PLOTX
                sta SAVEX               ; and save

                lda SEGY,Y              ; get object's y pos
                clc
                adc SEGY+1,Y            ; add next y pos.
                ror A                   ; get average
                sta PLOTY
                sta SAVEY               ; and save

;   calculate the object's size based on its position on the grid
_oddSkip        lda #30                 ; near objects are bigger
                sec
                sbc OBJSEG,X            ; val = (30 - seg pos) / 2
                lsr
                and #$FE                ; make even #
                asl                     ; *4
                asl
                tay

;   now copy part of the size table to a size work area.
;   this table holds 8 size values based on distance.
                ldx #0
_next1          lda SIZTBL,Y
                sta SIZEWK,X
                iny
                inx
                cpx #8
                bne _next1

                ldx OBJNUM              ; get object #
                lda ObjectType,X        ; and its type
                asl                     ; *8 (index into the shape table)
                asl
                asl
                sta SHAPIX

                lda #8                  ; max 8 lines in each object
                sta SHAPCT

_next2          ldx SHAPIX              ; get line #
                lda OBJDIR,X            ; and its direction
                tay
                bmi _XIT                ; a negative # indicates end

                lda PXINC,Y             ; get x increment of line,
                sta XI
                lda PYINC,Y             ; y increment of line,
                sta YI

                lda OBJLEN,X            ; absolute length of line
                tay
                lda SIZEWK,Y            ; then scaled length
                sta LENGTH              ; and store!

;   this section adjusts the x and y plot values...
_next3          lda PLOTX
                clc
                adc XI
                sta PLOTX

                lda PLOTY
                clc
                adc YI
                sta PLOTY

                lda SHAPIX              ; don't plot first line!
                beq _noPlot1

                jsr PlotPoint           ; plot point

;   increment y again to adjust for gr. 7+ aspect ratio
_noPlot1        lda PLOTY
                clc
                adc YI
                sta PLOTY

                lda SHAPIX              ; don't plot first line!
                beq _noPlot2

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
                clc
                adc AddOrSub2,Y         ; and adjust position

                cmp #240                ; on grid?
                bcs _resetShort         ;   no! don't move

                sta SHORTX,X            ;   ok, save pos.

                dec SHORTT,X            ; direction change?
                bpl _nextShort          ;   no!

_resetShort     .frsRandomByte          ; get a random direction time
                and #$3F                ; clamp to [0-63]
                sta SHORTT,X            ; and save

                and #1                  ; clamp to [0-1]
                sta SHORTD,X            ; and save

_nextShort      dex                     ; more shorts?
                bpl _next1              ;   yup!

                rts
                .endproc
