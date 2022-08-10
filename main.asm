LIVE            .proc
                jsr Random_Seed

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                jsr InitLUT
                jsr InitCharLUT

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

                jsr SetFont
                jsr ClearScreen

                jsr InitSID             ; init sound

                lda #0                  ; clear page 0
                ldx #127
_next1          sta $80,X
                dex
                bpl _next1

                lda #1                  ; init...
                sta BCDLVL              ; level #
                sta INTRFG              ; set intro flag
                lda #<JoyMsg            ; default...
                sta CONTRL              ; control...
                lda #>JoyMsg            ; is...
                sta CONTRL+1            ; stick!

;   turn off display, disable interrupts
                lda #0                  ; init...
                ;sta DMACTL             ; DMA
                ;sta NMIEN              ; interrupts
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

                jsr RenderPublisher
                jsr RenderTitle
                jsr RenderAuthor
                jsr RenderSelect

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

_plive          lda FLTIME              ; flash going?
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

_next5          .randomByte             ; let's try to
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
_next6          .randomByte             ; get a random
                and #$0F                ; sub-grid
                cmp #15                 ; number
                beq _next6

                sta OBJGRD,X            ; and save it
                lda #30                 ; put object at
                sta OBJSEG,X            ; far end of grid
                lda #1                  ; set up...
                sta OBJINC,X            ; obj. increment
                sta OBJPRS,X            ; object present
_nxtogn         dex                     ; loop back to do
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
