; ===========================
;         LIVEWIRE
; ===========================
; ===========================
;   WRITTEN BY: TOM HUDSON
; A.N.A.L.O.G. COMPUTING #12
; ===========================

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"


;--------------------------------------
;--------------------------------------
                * = DLIST-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00

                jmp LIVE


; --------------------------------------
; --------------------------------------
                * = $2000
; --------------------------------------

; ----------------------
; MAIN GAME DISPLAY LIST
; ----------------------

DLIST           ;.byte AEMPTY8
                ;.byte AEMPTY8+ADLI
                ;.byte AEMPTY8

                ;.byte $0E+ALMS
                ;    .addr DISP
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E
                ;.byte $0E+ALMS
                ;    .word DISP+$800
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E,$0E
                ;.byte $0E,$0E,$0E

                ;.byte AEMPTY1+ADLI
                ;.byte AEMPTY1

                ;.byte $07+ALMS
                ;    .addr INFOLN

                ;.byte AVB+AJMP
                ;    .addr DLIST

; -------------------------
; TITLE SCREEN DISPLAY LIST
; -------------------------

TITLDL          ;.byte AEMPTY8,AEMPTY8,AEMPTY8,AEMPTY8
                ;.byte AEMPTY8,AEMPTY8,AEMPTY8

                ;.byte $07+ALMS
                ;    .addr LASTSC

                ;.byte AEMPTY8,AEMPTY8

                ;.byte $06+ALMS
                ;    .addr MAGMSG

                ;.byte AEMPTY8

                ;.byte $07+ALMS
                ;    .addr TITLE

                ;.byte AEMPTY4

                ;.byte $06+ALMS
                ;    .addr AUTHOR

                ;.byte AEMPTY8,AEMPTY8

                ;.byte AEMPTY4

                ;.byte $06+ALMS
CONTRL          ;    .addr JOYMSG
                ;.byte AVB+AJMP
                ;    .addr TITLDL


; -----------------------
; DISPLAY LIST INTERRUPTS
; -----------------------

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI1  .proc
                pha                     ; save accum

                ;lda GRAC1              ; get gr. ctrl [0,3]
                ;sta WSYNC              ; wait for sync
                ;sta GRACTL             ; store it

                ;lda DMAC1              ; get and save
                ;sta DMACTL             ; DMA ctrl

                ;lda #<Interrupt_DLI2   ; point...
                ;sta VDSLST             ; to...
                ;lda #>Interrupt_DLI2   ; next...
                ;sta VDSLST+1           ; DLI!

                pla                     ; get accum
                rti                     ; and exit!
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI2  .proc
                pha                     ; save accum

                ;lda #$0A               ; get white
                ;sta WSYNC              ; wait for sync
                ;sta COLPF0             ; put in color 0

                ;lda #$74               ; put blue...
                ;sta COLPF1             ; in color 1

                ;lda #$28               ; put orange...
                ;sta COLPF2             ; in color 2

;   fetch instruction, single-line player, sprite DMA, normal playfield
                ;lda #$3D               ; set up...
                ;sta DMACTL             ; DMA ctrl

                pla                     ; get accum.
                rti                     ; and exit
                .endproc

;--------------------------------------

;
; SCREEN MESSAGES
;

INFOLN          .text '          lvl   '
MAGMSG          .text 'ANALOG COMPUTING'
TITLE           .text '    livewire    '
AUTHOR          .text ' BY  TOM HUDSON '
JOYMSG          .text '    joystick    '
PADMSG          .text '     paddle     '
LASTSC          .text '                '


;--------------------------------------
; Start of Code
;--------------------------------------

LIVE            .proc
                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                InitCharLUT

                lda #<CharResX
                sta COLS_PER_LINE
                lda #>CharResX
                sta COLS_PER_LINE+1
                lda #CharResX
                sta COLS_VISIBLE

                lda #<CharResY
                sta LINES_MAX
                lda #>CharResY
                sta LINES_MAX+1
                lda #CharResY
                sta LINES_VISIBLE

                ClearScreen

                cld
                ;jsr SIOINV             ; init sound

                lda #0                  ; clear page 0
                ldx #127
_next1          sta $80,X
                dex
                bpl _next1

                lda #1                  ; init...
                sta BCDLVL              ; level #
                sta INTRFG              ; set intro flag
                lda #<JOYMSG            ; default...
                sta CONTRL              ; control...
                lda #>JOYMSG            ; is...
                sta CONTRL+1            ; stick!

;   turn off display, disable interrupts
                lda #0                  ; init...
                ;sta DMACTL             ; DMA
                ;sta NMIEN               ; interrupts
                ;sta AUDCTL             ; audio
                ;sta HITCLR             ; collision
                ;sta COLBK              ; backgnd color

                ldx #3                  ; clear shorts
_next2          sta SHORTF,X
                dex
                bpl _next2

                ldx #5                  ; zero object...
_next3          sta OBDEAD,X            ; clr dead table
                dex
                bpl _next3

                ldx #2                  ; zero score
_next4          sta SCORE,X
                sta SCOADD,X
                dex
                bpl _next4

                ldx #7
_next5          sta PROJAC,X            ; clear proj.
                dex
                bpl _next5

                ldx #5
_next6          lda INFOLN,X            ; copy score...
                sta LASTSC+5,X          ; to last...
                dex                     ; score line
                bpl _next6

                lda #29                 ; set all...
                ldx #5                  ; objects to...
_next7          sta OBJSEG,X            ; segment # 29
                dex
                bpl _next7

                jsr SHOSCO              ; show score
                jsr SNDOFF              ; no sounds

                lda #6                  ; 6 projectiles
                sta PAVAIL              ; available
                lda #2                  ; set...
                sta BONUS               ; bonus=20000
                sta LIVES               ; 2 extra lives
                jsr SHOLIV              ; show lives left

                lda #5                  ; set up...
                sta SP2IX               ; player...
                lda #10                 ; shape...
                sta SP3IX               ; indexes

                ;lda #<TITLDL           ; point to...
                ;sta DLISTL             ; title...
                ;lda #>TITLDL           ; display...
                ;sta DLISTL+1           ; list

                ;ldy #<VBI              ; point to...
                ;ldx #>VBI              ; vertical...
                ;lda #7                 ; blank...
                ;jsr SETVBV             ; interrupt

                ;lda #>PMAREA           ; set up p/m...
                ;sta PMBASE             ; base address
                jsr PMCLR               ; clear p/m

                ;lda #$74               ; put blue...
                ;sta COLPF0             ; in color 0
                ;lda #$C4               ; put green...
                ;sta COLPF1             ; in color 1
                ;lda #$0A               ; put white...
                ;sta COLPF2             ; in color 2
                ;lda #$34               ; put red...
                ;sta COLPF3             ; in color 3

;   fetch instruction, single-line player, sprite DMA, normal playfield
                ;lda #$3D               ; set up...
                ;sta DMACTL             ; DMA,

;   enable sprites
                ;lda #3                 ; graphics,
                ;sta GRACTL             ; and

;   enable VBI + DLI
                ;lda #$C0               ; interrupt...
                ;sta NMIEN              ; enable

;   5th-player, Player > Playfield > Background
                ;lda #$11               ; set p/m...
                ;sta GPRIOR             ; priority

                ;lda #$0F               ; put white...
                ;sta COLPM1             ; in player 1,
                ;sta COLPM2             ; player 2
                ;sta COLPM3             ; and 3

                ;lda #$16               ; put yellow...
                ;sta COLPM0             ; in player 0

                .endproc

                ;[fall-through]


;--------------------------------------
; INTRO SCREEN
;--------------------------------------
IntroScreen     .proc
                lda CONSOL              ; start key...
                and #1                  ; pressed?
                bne _checkSELECT        ; no!

_wait1          lda CONSOL              ; start key...
                and #1                  ; released?
                beq _wait1              ; no, wait.

                jmp DIGIN               ; go dig in!!

_checkSELECT    lda CONSOL              ; select key...
                and #2                  ; pressed?
                bne IntroScreen         ; naw, loop back.

                lda JOYPAD              ; toggle...
                clc                     ; stick/paddle...
                adc #1                  ; indicator...
                and #1
                sta JOYPAD
                tax
                lda JPLO,X              ; and show...
                sta CONTRL              ; controller...
                lda JPHI,X              ; message...
                sta CONTRL+1            ; on screen!
                lda #30                 ; 30 jiffy...
                jsr WAIT                ; wait!

                jmp IntroScreen         ; and loop.

                .endproc


;--------------------------------------
; HERE'S WHERE PROGRAM STARTS
;--------------------------------------
DIGIN           .proc
                ;lda #<DLIST            ; point to...
                ;sta DLISTL             ; game...
                ;lda #>DLIST            ; display...
                ;sta DLISTL+1           ; list

                lda #0                  ; no longer in...
                sta INTRFG              ; intro
_forever        lda #1                  ; we want...
                sta COLOR               ; color 1
                sta ZAP                 ; reset zap.
                jsr CLRSC               ; clear screen

                lda GRIDIX              ; get grid#
                and #7                  ; find which...
                tax                     ; grid shape...
                lda GRDTBL,X            ; to draw...
                sta GRDNUM              ; and store
                jsr SHOLVL              ; show level#
                jsr DRGRID              ; draw grid!

_wait1          lda PAUFLG              ; we paused?
                bne _wait1              ; yup, loop.

                lda KILPLR              ; player dead?
                beq _plive              ; nope!

                jsr DECLIV              ; one less life!

_plive          ;sta ATTRAC             ; cancel attract!
                lda FLTIME              ; flash going?
                bne _nofend             ; yes! store...

                sta SP01_X_POS          ; flash position!
_nofend         lda OBTIM1              ; objects moving?
                bne _noohan             ; not yet!

                lda OBJSPD              ; reset move...
                sta OBTIM1              ; timer

;
; COPY OBJECT KILL TABLE
;

                ldx #5                  ; this section
_next1          lda OBDEAD,X            ; copies the
                sta OBDED2,X            ; object kill
                lda #0                  ; table which is
                sta OBDEAD,X            ; set up by the
                dex                     ; projectile
                bpl _next1              ; handler


                lda MISCAD              ; misc.score?
                beq _nomsco             ; no!

                sta SCOADD+1            ; set score add...
                jsr ADDSCO              ; and add it!

                lda #0                  ; then reset the
                sta MISCAD              ; add value.
_nomsco         ldx #5                  ; this section
                lda #0                  ; tallies all
_next2          ora OBJPRS,X            ; objects that
                dex                     ; are alive
                bpl _next2

                ldx #4                  ; now tally
_next3          ora NUMOBJ,X            ; all objects
                dex                     ; that are not
                bpl _next3              ; on grid yet

                cmp #0                  ; any objects?
                beq _lvlend             ; no, end of level!


                ldx #5                  ; is object
_next4          lda OBJPRS,X            ; present?
                bne _nxtogn             ; yes, try next.

_next5          lda SID_RANDOM          ; let's try to
                and #7                  ; start up a
                cmp #5                  ; new object
                bcs _next5              ; get a type

                tay                     ; any of that
                lda NUMOBJ,Y            ; type waiting?
                beq _nxtogn             ; no, try next

                sec                     ; decrement #
                sbc #1                  ; of objects
                sta NUMOBJ,Y            ; waiting.
                tya                     ; then set
                sta OBJTYP,X            ; object type.
_next6          lda SID_RANDOM          ; get a random
                and #$0F                ; sub-grid
                cmp #15                 ; number
                beq _next6

                sta OBJGRD,X            ; and save it
                lda #30                 ; put object at
                sta OBJSEG,X            ; far end of grid
                lda #1                  ; set up...
                sta OBJINC,X            ; obj. increment
                sta OBJPRS,X            ; object present
_nxtogn          dex                     ; loop back to do
                bpl _next4              ; next object

                jsr OBJHAN              ; handle objects
                jsr SHOHAN              ; handle shorts

_noohan         lda CONSOL              ; any console
                cmp #7                  ; keys pressed?
                beq _jconwt             ; nope!

                jmp LIVE                ; yes, restart game

_jconwt         jmp _wait1              ; indirect jump

_lvlend         lda GRIDIX              ; are we on
                cmp #63                 ; grid #63?
                beq _nogrdi             ; yes, don't inc!

                clc                     ; increment
                adc #1                  ; grid #
                sta GRIDIX              ; and save it.
                and #7                  ; add 2 to
                bne _nodifi             ; difficulty if

                inc DIFF                ; on a multiple
                inc DIFF                ; of 8 grids.
_nodifi         sed                     ; increment
                lda BCDLVL              ; bcd level #
                clc
                adc #1
                sta BCDLVL
                cld                     ; now go to
_nogrdi         jmp _forever            ; draw new grid.

                .endproc


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

                lda SID_RANDOM          ; random chance
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
                jsr ADDSCO              ; add to score!

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

                lda SID_RANDOM          ; get random
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
                lda SID_RANDOM          ; randomize...
                and #1                  ; short...
                sta SHORTD,Y            ; direction
                lda SID_RANDOM          ; and that...
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

RESSHD          lda SID_RANDOM          ; get a random
                and #$3F                ; direction time
                sta SHORTT,X            ; 0-63 & save
                and #1                  ; random direction
                sta SHORTD,X            ; 0-1 & save
HANNXS          dex                     ; more shorts?
                bpl SHHANL              ; yup!

                rts                     ; all done!
                .endproc


;======================================
; ADD TO SCORE
;======================================
ADDSCO          .proc
                ldy #0                  ; get zero
                sed                     ; set decimal mode
                lda SCORE+2             ; this section
                clc                     ; increments
                adc SCOADD+2            ; the 3-digit
                sta SCORE+2             ; score using
                sty SCOADD+2            ; the 3-digit
                lda SCORE+1             ; score add
                adc SCOADD+1            ; area, then
                sta SCORE+1             ; zeros out
                sty SCOADD+1            ; the
                lda SCORE               ; score add
                adc SCOADD              ; area using
                sta SCORE               ; the
                sty SCOADD              ; y register.
                cld                     ; clr decimal mode
                jsr SHOSCO              ; show score

                lda SCORE               ; is score at
                cmp BONUS               ; bonus level?
                bne NOBONS              ; sorry!

                jsr INCLIV              ; bonus, add life!

                sed                     ; set decimal
                lda BONUS               ; get old bonus
                clc                     ; add 20000
                adc #2                  ; to it
                cld                     ; clr decimal
                sta BONUS               ; and save bonus
NOBONS          rts                     ; finis!
                .endproc


;======================================
; Show Score
;======================================
SHOSCO          .proc
                lda #$10                ; set up color
                sta SHCOLR              ; byte for show
                ldx #0                  ; zero x
                ldy #0                  ; & y regs
SSCOLP          lda SCORE,Y             ; get score byte
                jsr SHOBCD              ; show it

                inx                     ; increment show
                inx                     ; pos. by 2
                iny                     ; next score byte
                cpy #3                  ; done?
                bne SSCOLP              ; not yet!

                rts                     ; all done!
                .endproc


;======================================
; INCREMENT LIVES
;======================================
INCLIV          .proc
                lda LIVES               ; do we have
                cmp #5                  ; 5 lives now?
                beq NOMOLV              ; yup, no inc!

                inc LIVES               ; one more life
                jsr SHOLIV              ; show it

NOMOLV          rts                     ; and exit!
                .endproc


;======================================
; DECREMENT LIVES
;======================================
DECLIV          .proc
                jsr SNDOFF              ; no sound


; ---------------------------
; WAIT FOR PROJECTILES TO END
; ---------------------------

WAITPD          ldx #7                  ; 8 projectiles
                lda #0                  ; zero tally
CKPRLV          ora PROJAC,X            ; check all
                dex                     ; projectiles
                bne CKPRLV              ; for activity

                cmp #0                  ; any active?
                bne WAITPD              ; yes! wait more!

;
; STOP SHORTS
;

                ldx #3                  ; 4 shorts (0-3)
STPSHO          sta SHORTF,X            ; turn off
                dex                     ; all of 'em
                bpl STPSHO              ; loop until done

;
; PUT OBJECTS AT END OF GRID
;

                lda #0                  ; erase
                sta COLOR               ; color
                lda #5                  ; erase all 6
                sta OBJNUM              ; objects
ERSOBJ          jsr DRWOBJ              ; erase it!

                ldx OBJNUM              ; get object #
                lda #30                 ; place at
                sta OBJSEG,X            ; seg #30
                lda #1                  ; set up move
                sta OBJINC,X            ; increment
RNDOBG          lda SID_RANDOM          ; get random
                and #$0F                ; sub-grid #
                cmp #$0F                ; 0-14
                beq RNDOBG

                sta OBJGRD,X
                dec OBJNUM              ; more objects?
                bpl ERSOBJ              ; yeah, do 'em

                ;lda #$0F               ; show player
                ;sta COLPM0             ; death here
                ;sta AUDC1              ; start sound
MOREWT          ;lda SID_RANDOM         ; set random
                ;and #$1F               ; death sound
                ;sta AUDF1              ; frequency
                lda #6                  ; wait 0.1 sec
                jsr WAIT

                ;dec COLPM0             ; dec brightness
                ;lda COLPM0             ; now set
                ;sta AUDC1              ; death volume
                ;bne MOREWT             ; more wait

                lda LIVES               ; more lives?
                beq DEAD                ; no more life!

                dec LIVES               ; one less life
                jsr SHOLIV              ; show it

                lda #60                 ; wait 1 sec
                jsr WAIT

                lda #0                  ; reset player
                sta KILPLR              ; kill flag
                ;lda #$16               ; and
                ;sta COLPM0             ; player color
                rts                     ; and exit!

DEAD            pla                     ; all dead, pull
                pla                     ; return addr.
                jmp LIVE                ; and restart game

                .endproc


;======================================
; SHOW LIVES
;======================================
SHOLIV          .proc
                lda #$90                ; select display
                sta SHCOLR              ; color
                lda LIVES               ; get lives
                ldx #7                  ; 7th char on line
                jsr SHOBCD              ; show it!

                rts                     ; and exit
                .endproc


;======================================
; SHOW LEVEL
;======================================
SHOLVL          .proc
                ldy #$50                ; select display
                sty SHCOLR              ; color
                lda BCDLVL              ; get level#
                ldx #14                 ; 14th char

                .endproc

                ;[fall-through]


;======================================
; BCD CHAR DISPLAY
;======================================
SHOBCD          .proc
                sta SHOBYT              ; save character
                and #$0F                ; get num 1
                ora SHCOLR              ; add color
                sta INFOLN+1,X          ; show it
                lda SHOBYT              ; get char.
                lsr A                   ; shift right
                lsr A                   ; to get
                lsr A                   ; num 2
                lsr A
                ora SHCOLR              ; add color
                sta INFOLN,X            ; show it
                rts                     ; and exit!
                .endproc


;======================================
; FLASH OBJECT WHEN DEAD
;======================================
FLASH           .proc
                ldy FLASHY              ; get y pos.
                lda #0                  ; get ready to
                ldx #14                 ; clear old flash
CLFLSH          sta PL1,Y               ; zero out each
                iny                     ; byte of flash
                dex                     ; done yet?
                bne CLFLSH              ; no, loop.

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
                sta PL1,Y               ; put in player 1
                iny                     ; next p/m byte
                dex                     ; next image byte
                bpl SEFLSH              ; loop.

                lda #1                  ; set flash
                sta FLTIME              ; duration
                rts                     ; all done!
                .endproc


;======================================
; TIME DELAY
;======================================
WAIT            .proc
                sta TIMER               ; set timer
WAITLP          lda TIMER               ; timer = 0?
                bne WAITLP              ; nope!

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

                rts                     ; and exit
                .endproc


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


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VERTICAL BLANK ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VBI             .proc
                ;lda #<Interrupt_DLI1   ; point to
                ;sta VDSLST             ; first
                ;lda #>Interrupt_DLI1   ; display list
                ;sta VDSLST+1           ; interrupt

                cld                     ; clr decimal mode
                lda OBTIM1              ; this section
                beq NOOBTD              ; processes

                dec OBTIM1              ; all timers
NOOBTD          lda TIMER
                beq NOTIMR

                dec TIMER
NOTIMR          lda FLTIME
                beq NOFTIM

                dec FLTIME
NOFTIM          lda KILPLR              ; player dead?
                beq CHKINT              ; no, continue!

                jmp VBCONT              ; skip player stuff

CHKINT          lda INTRFG              ; in intro?
                beq NOTINT              ; no, continue!

                rti                     ; exit if intro

NOTINT          lda KEYCHAR             ; get keyboard
                cmp #$1C                ; pause (esc)?
                bne CKZAP               ; no, check zap

                lda PAUFLG              ; get pause flag
                eor #$FF                ; and flip
                sta PAUFLG              ; and store
                jmp ENDKEY              ; done w/key

CKZAP           cmp #$21                ; space bar?
                bne ENDKEY              ; naw, done w/key

                lda ZAP                 ; used zap yet?
                beq ENDKEY              ; yes, no zap

                dec ZAP                 ; zap now used
                ldx #5                  ; time to kill
                lda #1                  ; all objects
ZAPOBJ          sta OBDEAD,X
                dex
                bpl ZAPOBJ

                ldx #3                  ; and kill
ZAPSHO          lda SHORTF,X            ; all shorts
                beq NOSKIL

                lda MISCAD              ; also set
                sed                     ; miscellaneous
                clc                     ; score add
                adc #4                  ; for 400 points
                sta MISCAD              ; for each short
                cld
                lda #0                  ; kill
                sta SHORTF,X            ; short
NOSKIL          dex
                bpl ZAPSHO

ENDKEY          lda #0                  ; clear
                sta KEYCHAR             ; keypress.

                lda PAUFLG              ; paused?
                beq NOPAU               ; no, continue

                ;lda #0                 ; turn off
                ;sta AUDC1              ; all sounds
                ;sta AUDC2              ; during
                ;sta AUDC3              ; the
                ;sta AUDC4              ; pause
                rti                     ; then exit

NOPAU           lda FIRSOU              ; fire sound on?
                beq NOFSND              ; no!

                dec FIRSOU              ; dec counter
                ldx FIRSOU              ; put in index
                ;lda FIRFRQ,X           ; get frequency
                ;sta AUDF2
                ;lda FIRCTL,X           ; get control
                ;sta AUDC2
NOFSND          lda OBDSOU              ; obj death sound?
                beq NOOSND              ; no!

                dec OBDSOU              ; dec counter
                ldx OBDSOU              ; put in index
                ;lda OBDFRQ,X           ; get frequency
                ;sta AUDF3
                ;lda OBDCTL,X           ; get control
                ;sta AUDC3
NOOSND          lda MOVSOU              ; move sound?
                beq CYCCOL              ; no!

                dec MOVSOU              ; dec counter
                ldx MOVSOU              ; put in index
                ;lda MOVFRQ,X           ; get frequency
                ;sta AUDF4
                ;lda MOVCTL,X           ; get control
                ;sta AUDC4
CYCCOL          ;lda COLPM2             ; cycle
                ;clc                    ; player 2
                ;adc #16                ; color
                ;sta COLPM2             ; save in p/m 2
                ;sta COLPM3             ; and in p/m 3
                ;and #$FC               ; also put in
                ;sta COLPF3             ; pf3 for missiles

                dec TRANTM              ; transient time
                bne NOTRAN              ; no change

                lda OBJHUE+4            ; flip
                bne TRAN1               ; transient

                lda #2                  ; hue
                bne STOTRN              ; to either

TRAN1           lda #0                  ; 0 or 2
STOTRN          sta OBJHUE+4
                lda SID_RANDOM
                ora #$1F                ; reset
                and #$3F                ; the
                sta TRANTM              ; transient time
NOTRAN          inc PSCNT               ; inc plyr timer
                lda PSCNT               ; ready to
                cmp #3                  ; change shape?
                bne NOPSIN              ; not yet!

                lda #0                  ; better reset
                sta PSCNT               ; index
                inc SP1IX               ; and increment
                inc SP2IX               ; all shape
                inc SP3IX               ; indexes!
NOPSIN          lda PFTIME              ; see if we're
                beq FIRE                ; ready to check

                dec PFTIME              ; if player is
                jmp CHKPMV              ; shooting

FIRE            lda #4                  ; reset fire
                sta PFTIME              ; timer
                lda JOYPAD              ; using stick?
                beq RDSTRG              ; yes!

                ;lda PTRIG0             ; get padl trigger
                ;jmp CMPTRG             ; check it

RDSTRG          lda JOYSTICK0           ; get stick trigger
                and #$10
CMPTRG          bne CHKPMV              ; not firing!

                lda PAVAIL              ; any proj avail?
                beq CHKPMV              ; no!

                ldx #7                  ; find an
PRSCAN          lda PROJAC,X            ; available
                beq GOTPRN              ; projectile

                dex
                bne PRSCAN

GOTPRN          dec PAVAIL              ; 1 less available
                lda #1                  ; it's now
                sta PROJAC,X            ; active
                lda #21                 ; start up
                sta FIRSOU              ; fire sound
                lda #0                  ; initialize
                sta PROJSG,X            ; segment # to 0
                lda PLRGRD              ; set up
                sta PROGRD,X            ; proj grid#
                asl A                   ; and
                asl A                   ; multiply
                asl A                   ; by 16
                asl A
                sta PROJGN,X            ; for index
                lda #1                  ; initialize
                sta PROINC,X            ; proj increment
CHKPMV          lda JOYPAD              ; using stick?
                beq GOSTIK              ; yes!

                ;lda POT0               ; get paddle
                ;lsr A                  ; divide by
                ;lsr A                  ; 16 to get
                ;lsr A                  ; usable value
                ;lsr A
                ;cmp #15                ; > 14?
                ;bmi STOPOS             ; no, go store
                bra STOPOS  ; HACK:

                lda #14                 ; max. is 14
                bne STOPOS              ; and go store

GOSTIK          lda PMTIME              ; ready for stick?
                beq RDSTIK              ; yes!

                dec PMTIME              ; dec timer
JVBC            jmp VBCONT              ; jmp to continue

RDSTIK          lda #2                  ; reset stick timer
                sta PMTIME              ; to 2 jiffies

                .setbank $AF
                ldx JOYSTICK0           ; get stick
                .setbank $00

                lda PLRGRD              ; get plyr grid #
                clc                     ; add the
                adc STKADD,X            ; direction inc
                bmi SAMPOS              ; if <0 reject

                cmp #15                 ; if <15...
                bne STOPOS              ; use it!

SAMPOS          lda PLRGRD              ; get grid#
STOPOS          cmp PLRGRD              ; same as last?
                beq NOPSTO              ; yes, don't store

                ldx #9                  ; start up
                stx MOVSOU              ; move sound
                sta PLRGRD              ; save grid#
NOPSTO          asl A                   ; multiply
                asl A                   ; by 16 for
                asl A                   ; position
                asl A                   ; index
                tax

                ;lda P0PL
                ;and #$0C               ; hit p2/p3?
                ;beq NOHSHO             ; no!
                bra NOHSHO  ; HACK:

                lda #1                  ; oops! hit short!
                sta KILPLR              ; kill player
                jmp VBEND               ; and exit vblank

NOHSHO          lda SEGX,X              ; get player's
                clc                     ; x position and
                adc #61                 ; adjust for p/m
                sta SP00_X_POS          ; and save
                ldy PLRY                ; hold old y pos
                lda SEGY,X              ; get new y pos
                clc                     ; adjust for p/m
                adc #32                 ; by adding 32
                sta PLRY                ; set y pos
                lda #0                  ; clear out
                ldx #15                 ; old player
CLRPS           sta PL0-8,Y             ; image
                iny
                dex
                bpl CLRPS

                lda #15                 ; now copy
                sta SPIX                ; 16-byte
SPLOOP          lda #0                  ; player image
                sta PLTBYT              ; to player 0
                lda SP1IX
                and #15
                tax
                lda SPIX
                cmp SPTBL,X
                bcc NOSP1

                cmp EPTBL,X
                bcs NOSP1

                tax
                lda PN1,X               ; get image 1
                sta PLTBYT              ; and save
NOSP1           lda SP2IX
                and #15
                tax
                lda SPIX
                cmp SPTBL,X
                bcc NOSP2

                cmp EPTBL,X
                bcs NOSP2

                tax
                lda PN2,X
                ora PLTBYT              ; add image 2
                sta PLTBYT              ; and save
NOSP2           lda SP3IX
                and #15
                tax
                lda SPIX
                cmp SPTBL,X
                bcc NOSP3

                cmp EPTBL,X
                bcs NOSP3

                tax
                lda PN3,X
                ora PLTBYT              ; add image 3
                sta PLTBYT              ; and save
NOSP3           lda PLRY
                clc
                adc SPIX
                sec
                sbc #8
                tay
                lda PLTBYT              ; get image byte
                sta PL0,Y               ; put in p/m area
                dec SPIX                ; more image?
                bpl SPLOOP              ; yes!

VBCONT          lda PRADV1              ; advance proj?
                beq SETPRA              ; yes!

                dec PRADV1              ; no, dec timer
                jmp FLIPIT              ; go flip display

SETPRA          inc PRADVT
                lda #1                  ; set advance
                sta PRADV1              ; timer

; ------------------------------
; THIS SECTION FLIP-FLOPS THE 4
; MISSILES IN ORDER TO ALLOW THE
; DISPLAY OF 8 PROJECTILES.  AS
; A RESULT, SOME FLICKER CAN BE
; OBSERVED.
; ------------------------------

FLIPIT          inc PRFLIP              ; inc flip index
                lda PRFLIP              ; get index
                and #1                  ; make 0/1
                tay                     ; save in y
                lda PREND,Y             ; get # of last
                sta ENDVAL              ; projectile
                ldx PRSTRT,Y            ; get # of first
                stx VBXHLD              ; projectile
                lda #3                  ; start w/missile
                sta MISNUM              ; number 3
PROJLP          lda PROJAC,X            ; is proj. active?
                bne GOTPRJ              ; you bet.

                jmp CKPEND              ; try another

GOTPRJ          ldx MISNUM              ; get missile #
                ldy PRYHLD,X            ; get last position
                lda MISSLS-1,Y          ; erase old
                and MISLOF,X            ; projectile
                sta MISSLS-1,Y          ; image
                lda MISSLS,Y
                and MISLOF,X
                sta MISSLS,Y
                lda MISSLS+1,Y
                and MISLOF,X
                sta MISSLS+1,Y
                ldx VBXHLD
                lda PRADVT              ; ready to
                and #1                  ; advance proj?
                bne NOPADV              ; not yet

                lda PROJSG,X            ; get proj seg#
                clc                     ; and
                adc PROINC,X            ; add increment
                sta PROJSG,X            ; then save
NOPADV          lda PROINC,X            ; enemy shot?
                bmi NOOHCK              ; no obj hit check

                ldy #5
OBKILP          lda OBDEAD,Y            ; already dead?
                bne NXTOCK              ; yes!

                lda OBJPRS,Y            ; object there?
                beq NXTOCK              ; no!

                lda OBJTYP,Y            ; transient?
                cmp #4
                bne NOTRNC              ; no!

                lda OBJHUE+4            ; invisible?
                beq NXTOCK              ; yes!

NOTRNC          lda OBJGRD,Y            ; same grid #
                cmp PROGRD,X            ; as proj?
                bne NXTOCK              ; no!

                lda OBJSEG,Y            ; same seg #
                lsr A
                sec
                sbc PROJSG,X            ; as proj?
                beq HITOBJ

                cmp #254
                bcc NXTOCK              ; no!

HITOBJ          lda OBJTYP,Y            ; resistor?
                beq CGPRDR              ; yes!

                lda #1                  ; kill object
                sta OBDEAD,Y
                jmp KILLPR              ; and proj.

CGPRDR          lda #$FF                ; proj now heading
                sta PROINC,X            ; for player!
NXTOCK          dey                     ; next object
                bpl OBKILP              ; more to do!

NOOHCK          lda PROJSG,X            ; is proj seg# =0?
                beq KILLPR              ; yes, kill it!

                cmp #16                 ; =16?
                beq KILLPR              ; yes, kill it!

                clc                     ; now add proj
                adc PROJGN,X            ; grid index
                tax                     ; and get
                lda SEGX,X              ; x coord
                ldy SEGY,X              ; and y coord
                clc                     ; add 64 to
                adc #64                 ; x coord for
                ldx MISNUM              ; p/m horiz
                sta SP03_X_POS,X        ; and save
                tya                     ; get y
                clc                     ; add 32 to
                adc #32                 ; y coord for
                tay                     ; p/m vert
                sty PRYHLD,X            ; and save.
                lda MISSLS-1,Y          ; now draw
                ora MISLON,X            ; projectile in
                sta MISSLS-1,Y          ; new position
                lda MISSLS,Y
                ora MISLON,X
                sta MISSLS,Y
                lda MISSLS+1,Y
                ora MISLON,X
                sta MISSLS+1,Y
CKPEND          dec MISNUM              ; next missile #
                dec VBXHLD              ; next proj.
                ldx VBXHLD
                cpx ENDVAL              ; done?
                beq SHORTS              ; yes!

                jmp PROJLP              ; do next proj.

KILLPR          lda #0                  ; kill proj.
                sta PROJAC,X
                cpx #2                  ; enemy proj?
                bcc NOAVIN              ; yes don't inc

                inc PAVAIL              ; another avail
NOAVIN          lda PROJSG,X            ; segment 0?
                bne NOKILP              ; no!

                lda PROINC,X            ; toward rim?
                bpl NOKILP              ; no!

                lda PROGRD,X            ; same grid...
                cmp PLRGRD              ; as player?
                bne NOKILP              ; no!

                lda #1                  ; the player
                sta KILPLR              ; is dead!
NOKILP          jmp CKPEND              ; next proj.


; ------------------------------
; THIS SECTION HANDLES SHORTS.
; 2 PLAYERS ARE USED TO SHOW A
; MAXIMUM OF 4 SHORTS, SO SOME
; FLICKER MAY BE OBSERVED.
; ------------------------------

SHORTS          inc SHFLIP              ; toggle flip
                lda SHFLIP              ; mask flip
                lsr A                   ; to either
                and #1                  ; 0 or 1
                tay                     ; put in y
                lda CPYSTN,Y            ; and get image
                sta CPYST               ; to use (+/x)
                lda SHFLIP              ; get flip,
                and #1                  ; mask and
                tay                     ; put in y
                lda #>PL3               ; put player 3
                sta DESTHI              ; in destination
                lda #<PL3               ; address
                sta DESTLO              ; hi & lo
                lda #1                  ; set dest #
                sta DESTNM
                lda SHSTRT,Y            ; get start
                sta VBXHLD              ; short #
SHORLP          lda #0
                ldx DESTNM
                ldy SHYHLD,X            ; get last index
                ldx #9                  ; now erase
ERSSHO          sta (DESTLO),Y          ; previous
                iny                     ; short
                dex
                bpl ERSSHO

                ldx VBXHLD
                lda SHORTF,X            ; short alive?
                beq NXTSHO              ; no!

                lda SHORTX,X            ; get index of
                tax                     ; short's pos.
                lda RIMX,X              ; get x coord
                ldy RIMY,X              ; and y coord
                clc
                adc #62                 ; adjust x
                ldx DESTNM              ; get player#
                sta SP02_X_POS,X        ; and store
                tya
                clc
                adc #28                 ; adjust y
                sta SHYHLD,X            ; save it
                tay
                ldx CPYST
                lda #4
                sta CPYCNT
SHOCOP          lda SHOIMG,X            ; now copy
                sta (DESTLO),Y          ; short image
                iny                     ; to p/m
                sta (DESTLO),Y          ; area
                iny
                dex
                dec CPYCNT
                bpl SHOCOP

NXTSHO          dec DESTNM              ; more?
                bmi VBEND               ; no, exit!

                dec DESTHI              ; next player
                inc VBXHLD
                jmp SHORLP              ; loop back.

VBEND           ;sta HITCLR             ; clear collision
                rti                     ; VBI done! (whew!)

                .endproc


;======================================
; CLEAR Player-MISSILES
;======================================
PMCLR           .proc
                lda #0                  ; put 255
                tax                     ; zeros in
PMCLP           sta MISSLS,X            ; each p/m
                sta PL0,X               ; area
                sta PL1,X
                sta PL2,X
                sta PL3,X
                dex
                bne PMCLP

                rts                     ; finis!
                .endproc


;======================================
; CLEAR SCREEN
;======================================
CLRSC           .proc
                lda #>DISP              ; initial
                sta HI                  ; display
                lda #<DISP              ; address
                sta LO                  ; work area
                ldx #20                 ; clear 20 groups
CLRSC2          ldy #0                  ; of 256 bytes
                tya                     ; (5120 bytes)
CLRSC3          sta (LO),Y
                dey
                bne CLRSC3

                dex
                bne CLRSC4

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
                lda #<DISP              ; add the display
                clc                     ; address to get
                adc LO                  ; the actual
                sta LO                  ; address of the
                lda #>DISP              ; byte that will
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
PABORT          rts                     ; finis!
                .endproc

;--------------------------------------

;
; PLOT MASK TABLES
;

COLORS          .byte $00,$55,$AA,$FF
BMASK1          .byte $3F,$CF,$F3,$FC
BMASK2          .byte $C0,$30,$0C,$03
COLR1          .byte $40,$10,$04,$01


;======================================
; DRAW HANDLER
;======================================
DRAW            .proc
                lda DRAWY
                cmp PLOTY               ; is drawy>ploty?
                bcc YMINUS              ; no!

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
                bcc XMINUS              ; no!

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
                bcc YMAX                ; no!

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
                bcc BEGIN2              ; no, go do x.

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
                bcc PLOTIT              ; no, go plot.

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
                bne BEGIN               ; yes!

DRWEND          rts                     ; no, exit!
                .endproc


;
; MISCELLANEOUS DATA
;

GRDTBL          .byte 0,1,2,3,4,1,5,3
                ;     L,I,V,E,W,I,R,E

;
; COLORS (0=GRID, 1=OBJ1 2=OBJ2)
;

C0TBL           .byte $C4,$36,$74,$F6
                .byte $54,$06,$00,$26
C1TBL           .byte $86,$0C,$36,$56
                .byte $26,$C6,$98,$18
C2TBL           .byte $98,$46,$A8,$36
                .byte $84,$18,$C6,$38

;
; OBJECT COUNT TABLES (DIFFICULTY)
;

OBCNT0          .byte 0,0,0,0,4,6,8,10
OBCNT1          .byte 0,0,0,6,8,9,10,11
OBCNT2          .byte 8,10,12,14,16,18,20,22
OBCNT3          .byte 6,8,10,11,12,14,15,16
OBCNT4          .byte 0,0,4,8,10,12,14,16

;
; STICK ADD VALUES
;

STKADD          .byte 0,0,0,0,0,1,1,1
                .byte 0,$FF,$FF,$FF,0,0,0,0

;
; PROJECTILE DATA
;

PROJAC          .byte 0,0,0,0,0,0,0,0
PROINC          .fill 8,$00
PROGRD          .fill 8,$00
PROJGN          .fill 8,$00
PROJSG          .fill 8,$00
PRSTRT          .byte 3,7
PREND           .byte $FF,3
MISLON          .byte $03,$0C,$30,$C0
MISLOF          .byte $FC,$F3,$CF,$3F

;
; FLASH (OBJECT DEATH) DATA
;

FLBYTE          .byte $28,$28,$28,$92,$54,$28,$10
                .byte $10,$28,$54,$92,$28,$28,$28

;
; OBJECT POINTS (250,200,50,100,150)
;

POINT1          .byte $02,$02,$00,$01,$01
POINT2          .byte $50,$00,$50,$00,$50

;
; SHORT DATA
;

SHORTF          .fill 4,$00
SHORTX          .fill 4,$00
SHORTD          .fill 4,$00
SHORTT          .fill 4,$00

;
; OBJECT DATA
;

OBDEAD          .fill 6,$00
OBDED2          .fill 6,$00
OBJTYP          .fill 6,$00
OBJINC          .fill 6,$00
OBJGRD          .fill 6,$00
OBJSEG          .fill 6,$00

OBJHUE          .byte 2,3,2,3,2
SIZEWK          .byte 0,0,0,0,0,0,0,0
PXINC           .byte 0,0,1,$FF,1,$FF,1,$FF
PYINC           .byte $FF,1,0,0,$FF,1,1,$FF
OBSTBL          .byte 18,15,14,12
                .byte 11,10,9,7
OBJDIR          .byte 4,3,1,2,0,5,$FF,0
                .byte 4,5,0,6,0,$FF,0,0
                .byte 0,5,6,4,7,1,$FF,0
                .byte 6,0,3,1,2,7,$FF,0
                .byte 4,6,5,7,5,6,4,$FF
OBJLEN          .byte 3,7,7,7,7,7,0,0
                .byte 3,7,7,7,7,0,0,0
                .byte 3,3,3,3,3,7,0,0
                .byte 2,3,3,3,3,3,0,0
                .byte 1,1,1,3,1,1,3,0
SIZTBL          .byte 0,0,0,0,0,1,1,1
                .byte 0,0,0,1,1,2,2,2
                .byte 0,0,1,1,1,2,2,2
                .byte 0,1,1,2,2,2,2,3
                .byte 0,1,1,2,2,2,3,3
                .byte 1,2,2,2,2,2,3,3
                .byte 1,2,2,2,3,3,3,4
                .byte 1,2,2,3,3,3,4,4

;
; PLAYER SHAPES
;

PN1             ;.byte $10,$10,$10,$10,$10,$10,$10,$10
                ;.byte $08,$08,$08,$08,$08,$08,$08,$08
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00010000         ; .A..
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
                .byte %00001000         ; ..B.
PN2             ;.byte $00,$00,$00,$00,$80,$40,$20,$10
                ;.byte $08,$04,$02,$01,$00,$00,$00,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %10000000         ; B...
                .byte %01000000         ; A...
                .byte %00100000         ; .B..
                .byte %00010000         ; .A..
                .byte %00001000         ; ..B.
                .byte %00000100         ; ..A.
                .byte %00000010         ; ...B
                .byte %00000001         ; ...A
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
PN3             ;.byte $00,$00,$01,$01,$02,$02,$04,$08
                ;.byte $10,$20,$40,$40,$80,$80,$00,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000001         ; ...A
                .byte %00000001         ; ...A
                .byte %00000010         ; ...B
                .byte %00000010         ; ...B
                .byte %00000100         ; ..A.
                .byte %00001000         ; ..B.
                .byte %00010000         ; .A..
                .byte %00100000         ; .B..
                .byte %01000000         ; A...
                .byte %01000000         ; A...
                .byte %10000000         ; B...
                .byte %10000000         ; B...
                .byte %00000000         ; ....
                .byte %00000000         ; ....

;
; SHAPE START/END POINTS
;

SPTBL           .byte 0,1,2,3,4,5,6,7
                .byte 8,7,6,5,4,3,2,1
EPTBL           .byte 17,16,15,14,13,12,11,10
                .byte 9,10,11,12,13,14,15,16

;
; JOYSTICK/PADDLE MESSAGE POINTERS
;

JPLO            .byte <JOYMSG,<PADMSG
JPHI            .byte >JOYMSG,>PADMSG

;
; GRID DATA TABLES
;

CX              .byte 14,14,14,14,14,14,14,14
                .byte 26,39,51,64,75,88,100,113
                .byte 14,14,14,14,14,14,14,14
                .byte 14,14,14,14,14,14,14,14
                .byte 14,20,26,32,38,43,49,59
                .byte 69,78,84,89,95,101,107,113
                .byte 113,88,64,39,14,14,14,27
                .byte 27,14,14,14,39,64,88,113
                .byte 14,14,14,14,14,29,43,58
                .byte 70,84,98,113,113,113,113,113
                .byte 113,106,100,113,113,100,82,65
                .byte 48,32,14,14,14,14,14,14

CY              .byte 18,34,52,70,88,105,123,141
                .byte 141,141,141,141,141,141,141,141
                .byte 18,25,34,42,50,58,67,75
                .byte 83,91,100,108,116,125,133,141
                .byte 18,39,59,80,101,121,141,141
                .byte 141,141,121,101,80,59,39,18
                .byte 18,18,18,18,18,35,53,71
                .byte 89,106,124,141,141,141,141,141
                .byte 18,49,80,111,141,132,123,114
                .byte 114,123,132,141,111,80,49,18
                .byte 141,110,80,61,38,18,18,18
                .byte 18,18,18,43,68,92,117,141

FX              .byte 55,55,55,55,55,55,55,55
                .byte 58,60,62,64,66,68,70,73
                .byte 55,55,55,55,55,55,55,55
                .byte 55,55,55,55,55,55,55,55
                .byte 55,57,58,59,59,60,61,63
                .byte 65,67,68,69,69,70,71,73
                .byte 73,68,64,60,55,55,55,57
                .byte 57,55,55,55,60,64,68,73
                .byte 55,55,55,55,55,58,61,63
                .byte 65,67,70,73,73,73,73,73
                .byte 73,72,70,73,73,70,67,64
                .byte 61,58,55,55,55,55,55,55

FY              .byte 67,71,74,77,81,84,87,90
                .byte 90,90,90,90,90,90,90,90
                .byte 60,62,65,68,71,73,76,78
                .byte 81,83,86,89,92,94,97,99
                .byte 67,73,77,80,84,88,90,90
                .byte 90,90,88,84,80,77,73,67
                .byte 67,67,67,67,67,71,74,77
                .byte 80,83,86,90,90,90,90,90
                .byte 67,74,80,86,90,89,87,86
                .byte 86,87,89,90,86,80,74,67
                .byte 90,85,80,75,71,67,67,67
                .byte 67,67,67,73,78,82,86,90

SHSTRT          .byte 0,2
SHYHLD          .fill 2,$00
SHOIMG          .byte $88,$50,$20,$50,$88
                .byte $20,$20,$F8,$20,$20
CPYSTN          .byte 4,9

ADDSUB          .byte 2,$FE               ; add/sub. 2
ADDSB1          .byte 1,$FF               ; add/sub. 1

;
; SOUND DATA
;

FIRCTL          .byte $00,$A1,$A1,$A2,$A2,$A3
                .byte $A3,$A4,$A4,$A5,$A5,$A6
                .byte $A6,$A7,$A7,$A8,$A8,$A9
                .byte $A9,$AA,$AA
FIRFRQ          .byte 0,194,166,180,152,166
                .byte 138,152,124,138,110,124
                .byte 96,110,82,96,68,82
                .byte 54,68,40

OBDCTL          .byte $00,$41,$41,$42,$42,$43
                .byte $43,$44,$44,$45,$45,$46
                .byte $46,$47,$47,$48,$48,$49
                .byte $49,$4A,$4A
OBDFRQ          .byte 0,80,40,120,80,160
                .byte 120,200,160,240,200,24
                .byte 240,64,24,104,64,144
                .byte 104,204,144

MOVCTL          .byte $00,$A1,$A1,$A2,$A2,$A3
                .byte $A3,$A4,$A4
MOVFRQ          .byte 0,20,30,20,30,20,30,20,30

;
; DATA TABLES
;

SEGWK           .fill 17
SEGX            .fill 256
SEGY            .fill 256
RIMX            .fill 256
RIMY            .fill 256

                .end
