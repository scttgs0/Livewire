; ===========================
;         LIVEWIRE
; ===========================
; ===========================
;   WRITTEN BY: TOM HUDSON
; A.N.A.L.O.G. COMPUTING #12
; ===========================

                .include "equates_system_atari8.asm"
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

DLIST           .byte AEMPTY8
                .byte AEMPTY8+ADLI
                .byte AEMPTY8

                .byte $0E+ALMS
                    .addr DISP
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E
                .byte $0E+ALMS
                    .word DISP+$800
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E,$0E
                .byte $0E,$0E,$0E

                .byte AEMPTY1+ADLI
                .byte AEMPTY1

                .byte $07+ALMS
                    .addr INFOLN

                .byte AVB+AJMP
                    .addr DLIST

; -------------------------
; TITLE SCREEN DISPLAY LIST
; -------------------------

TITLDL          .byte AEMPTY8,AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $07+ALMS
                    .addr LASTSC

                .byte AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr MAGMSG

                .byte AEMPTY8

                .byte $07+ALMS
                    .addr TITLE

                .byte AEMPTY4

                .byte $06+ALMS
                    .addr AUTHOR

                .byte AEMPTY8,AEMPTY8

                .byte AEMPTY4

                .byte $06+ALMS
CONTRL              .addr JOYMSG
                .byte AVB+AJMP
                    .addr TITLDL


; -----------------------
; DISPLAY LIST INTERRUPTS
; -----------------------

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI1            pha                     ; SAVE ACCUM
                lda GRAC1               ; GET GR. CTRL
                sta WSYNC               ; WAIT FOR SYNC
                sta GRACTL              ; STORE IT
                lda DMAC1               ; GET AND SAVE
                sta $D400               ; DMA CTRL
                lda #<DLI2              ; POINT...
                sta VDSLST              ; TO...
                lda #>DLI2              ; NEXT...
                sta VDSLST+1            ; DLI!
                pla                     ; GET ACCUM
                rti                     ; AND EXIT!


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLI2            pha                     ; SAVE ACCUM
                lda #$0A                ; GET WHITE
                sta WSYNC               ; WAIT FOR SYNC
                sta $D016               ; PUT IN COLOR 0
                lda #$74                ; PUT BLUE...
                sta $D017               ; IN COLOR 1
                lda #$28                ; PUT ORANGE...
                sta $D018               ; IN COLOR 2
                lda #$3D                ; SET UP...
                sta $D400               ; DMA CTRL
                pla                     ; GET ACCUM.
                rti                     ; AND EXIT

;
; SCREEN MESSAGES
;

INFOLN          .byte 0,0,0,0,0,0,0,0
                .byte 0,0,$6C,$76,$6C,0,0,0
MAGMSG          .byte $21,$2E,$21,$2C,$2F,$27
                .byte 0,$23,$2F,$2D,$30,$35
                .byte $34,$29,$2E,$27
TITLE           .byte 0,0,0,0,$6C,$69,$76,$65
                .byte $77,$69,$72,$65,0,0,0,0
AUTHOR          .byte 0,$A2,$B9,0,0,$B4,$AF
                .byte $AD,0,$A8,$B5,$A4,$B3
                .byte $AF,$AE,0
JOYMSG          .byte 0,0,0,0,$EA,$EF,$F9,$F3
                .byte $F4,$E9,$E3,$EB,0,0,0,0
PADMSG          .byte 0,0,0,0,0,$F0,$E1,$E4
                .byte $E4,$EC,$E5,0,0,0,0,0
LASTSC          .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0


;--------------------------------------
; Start of Code
;--------------------------------------

LIVE            .frsGraphics mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                cld
                jsr SIOINV              ; INIT SOUND

                lda #0                  ; CLEAR PAGE 0
                ldx #127
CPAGE0          sta $80,X
                dex
                bpl CPAGE0

                lda #1                  ; INIT...
                sta BCDLVL              ; LEVEL #
                sta INTRFG              ; SET INTRO FLAG
                lda #<JOYMSG            ; DEFAULT...
                sta CONTRL              ; CONTROL...
                lda #>JOYMSG            ; IS...
                sta CONTRL+1            ; STICK!
                lda #0                  ; INIT...
                sta DMACTL              ; DMA
                sta NMIEN               ; INTERRUPTS
                sta AUDCTL              ; AUDIO
                sta HITCLR              ; COLLISION
                sta COLBK               ; BACKGND COLOR
                ldx #3                  ; CLEAR SHORTS
CLRSHO          sta SHORTF,X
                dex
                bpl CLRSHO

                ldx #5                  ; ZERO OBJECT...
CLRDED          sta OBDEAD,X            ; CLR DEAD TABLE
                dex
                bpl CLRDED

                ldx #2                  ; ZERO SCORE
CLRSCO          sta SCORE,X
                sta SCOADD,X
                dex
                bpl CLRSCO

                ldx #7
CLRPRJ          sta PROJAC,X            ; CLEAR PROJ.
                dex
                bpl CLRPRJ

                ldx #5
MOVSCO          lda INFOLN,X            ; COPY SCORE...
                sta LASTSC+5,X          ; TO LAST...
                dex                     ; SCORE LINE
                bpl MOVSCO

                lda #29                 ; SET ALL...
                ldx #5                  ; OBJECTS TO...
INIOBS          sta OBJSEG,X            ; SEGMENT # 29
                dex
                bpl INIOBS

                jsr SHOSCO              ; SHOW SCORE
                jsr SNDOFF              ; NO SOUNDS

                lda #6                  ; 6 PROJECTILES
                sta PAVAIL              ; AVAILABLE
                lda #2                  ; SET...
                sta BONUS               ; BONUS=20000
                sta LIVES               ; 2 EXTRA LIVES
                jsr SHOLIV              ; SHOW LIVES LEFT

                lda #5                  ; SET UP...
                sta SP2IX               ; PLAYER...
                lda #10                 ; SHAPE...
                sta SP3IX               ; INDEXES
                lda #<TITLDL            ; POINT TO...
                sta DLISTL              ; TITLE...
                lda #>TITLDL            ; DISPLAY...
                sta DLISTL+1            ; LIST
                ldy #<VBI               ; POINT TO...
                ldx #>VBI               ; VERTICAL...
                lda #7                  ; BLANK...
                jsr SETVBV              ; INTERRUPT

                lda #>PMAREA            ; SET UP P/M...
                sta PMBASE              ; BASE ADDRESS
                jsr PMCLR               ; CLEAR P/M

                lda #$74                ; PUT BLUE...
                sta COLPF0              ; IN COLOR 0
                lda #$C4                ; PUT GREEN...
                sta COLPF1              ; IN COLOR 1
                lda #$0A                ; PUT WHITE...
                sta COLPF2              ; IN COLOR 2
                lda #$34                ; PUT RED...
                sta COLPF3              ; IN COLOR 3
                lda #$3D                ; SET UP...
                sta DMACTL              ; DMA,
                lda #3                  ; GRAPHICS,
                sta GRACTL              ; AND
                lda #$C0                ; INTERRUPT...
                sta NMIEN               ; ENABLE
                lda #$11                ; SET P/M...
                sta PRIOR               ; PRIORITY
                lda #$0F                ; PUT WHITE...
                sta COLPM1              ; IN PLAYER 1,
                sta COLPM2              ; PLAYER 2
                sta COLPM3              ; AND 3
                lda #$16                ; PUT YELLOW...
                sta COLPM0              ; IN PLAYER 0

;
; INTRO SCREEN
;

INTRO           lda CONSOL              ; START KEY...
                and #1                  ; PRESSED?
                bne CKSEL               ; NO!

GOCHEK          lda CONSOL              ; START KEY...
                and #1                  ; RELEASED?
                beq GOCHEK              ; NO, WAIT.

                jmp DIGIN               ; GO DIG IN!!

CKSEL           lda CONSOL              ; SELECT KEY...
                and #2                  ; PRESSED?
                bne INTRO               ; NAW, LOOP BACK.

                lda JOYPAD              ; TOGGLE...
                clc                     ; STICK/PADDLE...
                adc #1                  ; INDICATOR...
                and #1
                sta JOYPAD
                tax
                lda JPLO,X              ; AND SHOW...
                sta CONTRL              ; CONTROLLER...
                lda JPHI,X              ; MESSAGE...
                sta CONTRL+1            ; ON SCREEN!
                lda #30                 ; 30 JIFFY...
                jsr WAIT                ; WAIT!

                jmp INTRO               ; AND LOOP.


; ---------------------------
; HERE'S WHERE PROGRAM STARTS
; ---------------------------

DIGIN           lda #<DLIST             ; POINT TO...
                sta DLISTL              ; GAME...
                lda #>DLIST             ; DISPLAY...
                sta DLISTL+1            ; LIST
                lda #0                  ; NO LONGER IN...
                sta INTRFG              ; INTRO
FOREVR          lda #1                  ; WE WANT...
                sta COLOR               ; COLOR 1
                sta ZAP                 ; RESET ZAP.
                jsr CLRSC               ; CLEAR SCREEN

                lda GRIDIX              ; GET GRID#
                and #7                  ; FIND WHICH...
                tax                     ; GRID SHAPE...
                lda GRDTBL,X            ; TO DRAW...
                sta GRDNUM              ; AND STORE
                jsr SHOLVL              ; SHOW LEVEL#
                jsr DRGRID              ; DRAW GRID!

CONWT           lda PAUFLG              ; WE PAUSED?
                bne CONWT               ; YUP, LOOP.

                lda KILPLR              ; PLAYER DEAD?
                beq PLIVE               ; NOPE!

                jsr DECLIV              ; ONE LESS LIFE!

PLIVE           sta ATTRAC              ; CANCEL ATTRACT!
                lda FLTIME              ; FLASH GOING?
                bne NOFEND              ; YES! STORE...

                sta HPOSP1              ; FLASH POSITION!
NOFEND          lda OBTIM1              ; OBJECTS MOVING?
                bne NOOHAN              ; NOT YET!

                lda OBJSPD              ; RESET MOVE...
                sta OBTIM1              ; TIMER

;
; COPY OBJECT KILL TABLE
;

                ldx #5                  ; THIS SECTION
COPDED          lda OBDEAD,X            ; COPIES THE
                sta OBDED2,X            ; OBJECT KILL
                lda #0                  ; TABLE WHICH IS
                sta OBDEAD,X            ; SET UP BY THE
                dex                     ; PROJECTILE
                bpl COPDED              ; HANDLER


                lda MISCAD              ; MISC.SCORE?
                beq NOMSCO              ; NO!

                sta SCOADD+1            ; SET SCORE ADD...
                jsr ADDSCO              ; AND ADD IT!

                lda #0                  ; THEN RESET THE
                sta MISCAD              ; ADD VALUE.
NOMSCO          ldx #5                  ; THIS SECTION
                lda #0                  ; TALLIES ALL
CKOBLV          ora OBJPRS,X            ; OBJECTS THAT
                dex                     ; ARE ALIVE
                bpl CKOBLV

                ldx #4                  ; NOW TALLY
CKOBWT          ora NUMOBJ,X            ; ALL OBJECTS
                dex                     ; THAT ARE NOT
                bpl CKOBWT              ; ON GRID YET

                cmp #0                  ; ANY OBJECTS?
                beq LVLEND              ; NO, END OF LEVEL!


                ldx #5                  ; IS OBJECT
GENNOL          lda OBJPRS,X            ; PRESENT?
                bne NXTOGN              ; YES, TRY NEXT.

TRYTYP          lda RANDOM              ; LET'S TRY TO
                and #7                  ; START UP A
                cmp #5                  ; NEW OBJECT
                bcs TRYTYP              ; GET A TYPE

                tay                     ; ANY OF THAT
                lda NUMOBJ,Y            ; TYPE WAITING?
                beq NXTOGN              ; NO, TRY NEXT

                sec                     ; DECREMENT #
                sbc #1                  ; OF OBJECTS
                sta NUMOBJ,Y            ; WAITING.
                tya                     ; THEN SET
                sta OBJTYP,X            ; OBJECT TYPE.
NEWGRD          lda RANDOM              ; GET A RANDOM
                and #$0F                ; SUB-GRID
                cmp #15                 ; NUMBER
                beq NEWGRD

                sta OBJGRD,X            ; AND SAVE IT
                lda #30                 ; PUT OBJECT AT
                sta OBJSEG,X            ; FAR END OF GRID
                lda #1                  ; SET UP...
                sta OBJINC,X            ; OBJ. INCREMENT
                sta OBJPRS,X            ; OBJECT PRESENT
NXTOGN          dex                     ; LOOP BACK TO DO
                bpl GENNOL              ; NEXT OBJECT

                jsr OBJHAN              ; HANDLE OBJECTS
                jsr SHOHAN              ; HANDLE SHORTS

NOOHAN          lda CONSOL              ; ANY CONSOLE
                cmp #7                  ; KEYS PRESSED?
                beq JCONWT              ; NOPE!

                jmp LIVE                ; YES, RESTART GAME

JCONWT          jmp CONWT               ; INDIRECT JUMP

LVLEND          lda GRIDIX              ; ARE WE ON
                cmp #63                 ; GRID #63?
                beq NOGRDI              ; YES, DON'T INC!

                clc                     ; INCREMENT
                adc #1                  ; GRID #
                sta GRIDIX              ; AND SAVE IT.
                and #7                  ; ADD 2 TO
                bne NODIFI              ; DIFFICULTY IF

                inc DIFF                ; ON A MULTIPLE
                inc DIFF                ; OF 8 GRIDS.
NODIFI          sed                     ; INCREMENT
                lda BCDLVL              ; BCD LEVEL #
                clc
                adc #1
                sta BCDLVL
                cld                     ; NOW GO TO
NOGRDI          jmp FOREVR              ; DRAW NEW GRID.


;======================================
; OBJECT HANDLER
;======================================
OBJHAN          lda OBJNUM              ; INCREMENT
                clc                     ; OBJECT #
                adc #1
                cmp #6                  ; DONE?
                bne STONUM              ; NO, CONTINUE.

                lda #$FF                ; RESET
                sta OBJNUM              ; OBJECT #
                rts                     ; AND EXIT.

STONUM          sta OBJNUM              ; SAVE OBJ #
OBHLP1          ldx OBJNUM              ; GET OBJ #
                lda OBJPRS,X            ; OBJ PRESENT?
                beq OBJHAN              ; NO!

OBLIVE          lda OBJSEG,X            ; WITHIN 2 UNITS
                cmp #2                  ; OF RIM?
                bcc NOOBFI              ; YES, DON'T FIRE

                lda RANDOM              ; RANDOM CHANCE
                and #$0F                ; OF SHOOTING
                bne NOOBFI              ; DON'T SHOOT

                lda PROJAC              ; PROJ. 0 ACTIVE?
                bne TRYPR1              ; YES, IGNORE!

                ldy #0                  ; FORCE BRANCH
                beq STOBFI              ; TO STORE IT

TRYPR1          lda PROJAC+1            ; PROJ. 1 ACTIVE?
                bne NOOBFI              ; YES, NO FIRE

                ldy #1                  ; SET INDEX
STOBFI          lda OBJSEG,X            ; INITIALIZE
                lsr A                   ; PROJECTILE
                sta PROJSG,Y            ; SEGMENT #
                lda OBJGRD,X            ; AND
                sta PROGRD,Y            ; SUB-GRID #
                asl A                   ; MULTIPLY
                asl A                   ; BY
                asl A                   ; 16
                asl A                   ; AND
                sta PROJGN,Y            ; SAVE INDEX!
                lda #$FF                ; SET INCREMENT
                sta PROINC,Y            ; (TOWARD RIM)
                lda #21                 ; START THE
                sta FIRSOU              ; FIRE SOUND
                lda #1                  ; AND
                sta PROJAC,Y            ; PROJECTILE
NOOBFI          lda #0                  ; SET COLOR 0
                sta COLOR               ; TO ERASE OBJECT
                jsr DRWOBJ              ; AND ERASE IT

                ldx OBJNUM
                lda OBDED2,X            ; OBJ DEAD?
                beq NOOKIL              ; YES! START

                jsr FLASH               ; DEATH FLASH

                ldx OBJNUM
                ldy OBJTYP,X            ; GET OBJECT TYPE
                lda POINT1,Y            ; GET POINTS
                sta SCOADD+1            ; AND READY
                lda POINT2,Y            ; THE SCORE
                sta SCOADD+2            ; ADD VALUE
                jsr ADDSCO              ; ADD TO SCORE!

                ldx OBJNUM
                jmp KILOBJ              ; THEN KILL OBJ.

NOOKIL          lda OBJSEG,X            ; INCREMENT
                sec                     ; OBJECT'S
                sbc OBJINC,X            ; SEGMENT
                sta OBJSEG,X            ; POSITION
                bmi KILOBJ              ; PAST RIM!

                cmp #30                 ; TYPE 3 PAST END?
                bne NOTOT3              ; NOPE!

                inc NUMOBJ+2            ; START TYPE 2
                bne KILOBJ              ; FORCE BRANCH

NOTOT3          cmp #10                 ; AT TYPE 3 TURN?
                bne OBHLP2              ; NO!

                lda OBJTYP,X            ; IS IT
                cmp #3                  ; TYPE 3?
                bne OBHLP2              ; NO!

                lda #$FF                ; REVERSE OBJECT
                sta OBJINC,X            ; INCREMENT
OBHLP2          lda OBJTYP,X            ; IS OBJECT
                cmp #2                  ; TYPE 2?
                bne SETHUE              ; NO, SET COLOR

                lda RANDOM              ; GET RANDOM
                and #1                  ; DIRECTION
                tay                     ; FOR TYPE 2
                lda OBJGRD,X            ; AND
                clc                     ; ADD OR
                adc ADDSB1,Y            ; SUBTRACT 1
                cmp #15                 ; PAST LIMIT?
                bcs SETHUE              ; YES!

                sta OBJGRD,X            ; SAVE NEW POS.
SETHUE          lda OBJTYP,X            ; GET OBJ. TYPE
                tax                     ; AND GET
                lda OBJHUE,X            ; COLOR #
                sta COLOR               ; SAVE IT
                jsr DRWOBJ              ; AND DRAW OBJECT!

                jmp OBJHAN              ; DO NEXT ONE


KILOBJ          lda #0                  ; OBJECT IS NO
                sta OBJPRS,X            ; LONGER ALIVE
                lda #21                 ; SET UP
                sta OBDSOU              ; DEATH SOUND
                lda OBJSEG,X            ; CHECK
                bpl JOBHAN              ; FOR A

                lda OBJGRD,X            ; COLLISION
                cmp PLRGRD              ; WITH PLAYER
                bne CKSHOR              ; NO HIT

                lda #1                  ; HIT,
                sta KILPLR              ; KILL PLAYER!
                bne JOBHAN              ; NEXT OBJECT

CKSHOR          lda OBJTYP,X            ; OBJECT
                cmp #1                  ; TYPE 1?
                bne JOBHAN              ; NOPE!

                ldy #3                  ; TRY SHORT:
TRYSHO          lda SHORTF,Y            ; SHORT AVAILABLE?
                beq INISHO              ; YUP!

                dey                     ; KEEP...
                bpl TRYSHO              ; TRYING!

                bmi JOBHAN              ; NO SHORT AVAIL!

INISHO          lda OBJGRD,X            ; MULTIPLY THE
                asl A                   ; OBJECT'S
                asl A                   ; SUB-GRID #
                asl A                   ; BY 16...
                asl A
                clc
                adc #8                  ; AND ADD 8 FOR
                sta SHORTX,Y            ; THE SHORT INDEX
                lda #1                  ; SHORT IS
                sta SHORTF,Y            ; ALIVE!
                lda RANDOM              ; RANDOMIZE...
                and #1                  ; SHORT...
                sta SHORTD,Y            ; DIRECTION
                lda RANDOM              ; AND THAT...
                and #$3F                ; DIRECTION'S...
                sta SHORTT,Y            ; TIME!
JOBHAN          jmp OBJHAN              ; NEXT OBJECT


;======================================
; DRAW OBJECT
;======================================
DRWOBJ          ldx OBJNUM              ; GET OBJECT #
                lda OBJGRD,X            ; GET SUB-GRID #
                asl A                   ; MULTIPLY
                asl A                   ; BY 16...
                asl A
                asl A
                sta HLDGRD              ; AND SAVE.
                lda OBJSEG,X            ; DIVIDE
                lsr A                   ; SEGMENT BY 2
                bcs ODDSEG              ; PROCESS ODD #

                clc                     ; IT'S EVEN, ADD
                adc HLDGRD              ; GRID INDEX
                tay                     ; PUT IN Y REG.
                lda SEGX,Y              ; GET OBJECT'S
                sta PLOTX               ; X POSITION
                sta SAVEX               ; AND SAVE
                lda SEGY,Y              ; GET OBJECT'S
                sta PLOTY               ; Y POSITION
                sta SAVEY               ; AND SAVE
                jmp ODDSKP              ; SKIP ODD ROUTINE

ODDSEG          clc                     ; IT'S ODD, ADD
                adc HLDGRD              ; GRID INDEX
                tay                     ; PUT IN Y REG.
                lda SEGX,Y              ; GET OBJECT'S
                clc                     ; X POS, ADD
                adc SEGX+1,Y            ; NEXT X POS.
                ror A                   ; GET AVERAGE
                sta PLOTX               ; PUT IN PLOT X
                sta SAVEX               ; AND SAVE
                lda SEGY,Y              ; GET OBJECT'S
                clc                     ; Y POS, ADD
                adc SEGY+1,Y            ; NEXT Y POS.
                ror A                   ; GET AVERAGE
                sta PLOTY               ; PUT IN PLOT Y
                sta SAVEY               ; AND SAVE
ODDSKP          lda #30                 ; NOW CALCULATE
                sec                     ; THE OBJECT'S
                sbc OBJSEG,X            ; SIZE BASED ON
                lsr A                   ; ITS POSITION
                and #$FE                ; ON THE GRID
                asl A
                asl A
                tay                     ; PUT INDEX IN Y
                ldx #0                  ; NOW COPY PART
COPYSZ          lda SIZTBL,Y            ; OF THE SIZE
                sta SIZEWK,X            ; TABLE TO A
                iny                     ; SIZE WORK AREA
                inx                     ; THIS TABLE HOLDS
                cpx #8                  ; 8 SIZE VALUES
                bne COPYSZ              ; BASED ON DIST.

                ldx OBJNUM              ; GET OBJECT #
                lda OBJTYP,X            ; AND ITS TYPE
                asl A                   ; AND MULTIPLY
                asl A                   ; BY 8 FOR AN
                asl A                   ; INDEX INTO
                sta SHAPIX              ; THE SHAPE TABLE
                lda #8                  ; MAX 8 LINES IN
                sta SHAPCT              ; EACH OBJECT
DOBLP           ldx SHAPIX              ; GET LINE#
                lda OBJDIR,X            ; & ITS DIRECTION
                tay                     ; A NEGATIVE #
                bmi ENDOBJ              ; INDICATES END

                lda PXINC,Y             ; GET X INCREMENT
                sta XI                  ; OF LINE,
                lda PYINC,Y             ; Y INCREMENT
                sta YI                  ; OF LINE,
                lda OBJLEN,X            ; ABSOLUTE LENGTH
                tay                     ; OF LINE THEN
                lda SIZEWK,Y            ; SCALED LENGTH
                sta LENGTH              ; AND STORE!
PLOTOB          lda PLOTX               ; THIS SECTION
                clc                     ; ADJUSTS THE
                adc XI                  ; X AND Y PLOT
                sta PLOTX               ; VALUES...
                lda PLOTY
                clc
                adc YI
                sta PLOTY
                lda SHAPIX              ; DON'T PLOT
                beq NOPLT1              ; FIRST LINE!

                jsr PLOTCL              ; PLOT POINT

NOPLT1          lda PLOTY               ; INCREMENT Y
                clc                     ; AGAIN TO ADJUST
                adc YI                  ; FOR GR. 7+
                sta PLOTY               ; ASPECT RATIO
                lda SHAPIX              ; DON'T PLOT
                beq NOPLT2              ; FIRST LINE

                jsr PLOTCL              ; PLOT POINT

NOPLT2          dec LENGTH              ; END OF LINE?
                bpl PLOTOB              ; NOPE!

                inc SHAPIX              ; NEXT LINE
                dec SHAPCT              ; LAST LINE?
                bne DOBLP               ; NOT YET!

ENDOBJ          rts                     ; ALL DONE!


;======================================
; SHORT HANDLER
;======================================
SHOHAN          ldx #3                  ; MAX. 4 SHORTS
SHHANL          lda SHORTF,X            ; SHORT ALIVE?
                beq HANNXS              ; NO, DO NEXT

                ldy SHORTD,X            ; GET SHORT DIR.
                lda SHORTX,X            ; GET X POS.
                clc                     ; AND ADJUST
                adc ADDSUB,Y            ; POSITION
                cmp #240                ; ON GRID?
                bcs RESSHD              ; NO! DON'T MOVE

                sta SHORTX,X            ; OK, SAVE POS.
                dec SHORTT,X            ; DIRECTION CHANGE?
                bpl HANNXS              ; NO!

RESSHD          lda RANDOM              ; GET A RANDOM
                and #$3F                ; DIRECTION TIME
                sta SHORTT,X            ; 0-63 & SAVE
                and #1                  ; RANDOM DIRECTION
                sta SHORTD,X            ; 0-1 & SAVE
HANNXS          dex                     ; MORE SHORTS?
                bpl SHHANL              ; YUP!

                rts                     ; ALL DONE!


;======================================
; ADD TO SCORE
;======================================
ADDSCO          ldy #0                  ; GET ZERO
                sed                     ; SET DECIMAL MODE
                lda SCORE+2             ; THIS SECTION
                clc                     ; INCREMENTS
                adc SCOADD+2            ; THE 3-DIGIT
                sta SCORE+2             ; SCORE USING
                sty SCOADD+2            ; THE 3-DIGIT
                lda SCORE+1             ; SCORE ADD
                adc SCOADD+1            ; AREA, THEN
                sta SCORE+1             ; ZEROS OUT
                sty SCOADD+1            ; THE
                lda SCORE               ; SCORE ADD
                adc SCOADD              ; AREA USING
                sta SCORE               ; THE
                sty SCOADD              ; Y REGISTER.
                cld                     ; CLR DECIMAL MODE
                jsr SHOSCO              ; SHOW SCORE

                lda SCORE               ; IS SCORE AT
                cmp BONUS               ; BONUS LEVEL?
                bne NOBONS              ; SORRY!

                jsr INCLIV              ; BONUS, ADD LIFE!

                sed                     ; SET DECIMAL
                lda BONUS               ; GET OLD BONUS
                clc                     ; ADD 20000
                adc #2                  ; TO IT
                cld                     ; CLR DECIMAL
                sta BONUS               ; AND SAVE BONUS
NOBONS          rts                     ; FINIS!


;======================================
; Show Score
;======================================
SHOSCO          lda #$10                ; SET UP COLOR
                sta SHCOLR              ; BYTE FOR SHOW
                ldx #0                  ; ZERO X
                ldy #0                  ; & Y REGS
SSCOLP          lda SCORE,Y             ; GET SCORE BYTE
                jsr SHOBCD              ; SHOW IT

                inx                     ; INCREMENT SHOW
                inx                     ; POS. BY 2
                iny                     ; NEXT SCORE BYTE
                cpy #3                  ; DONE?
                bne SSCOLP              ; NOT YET!

                rts                     ; ALL DONE!


;======================================
; INCREMENT LIVES
;======================================
INCLIV          lda LIVES               ; DO WE HAVE
                cmp #5                  ; 5 LIVES NOW?
                beq NOMOLV              ; YUP, NO INC!

                inc LIVES               ; ONE MORE LIFE
                jsr SHOLIV              ; SHOW IT

NOMOLV          rts                     ; AND EXIT!


;======================================
; DECREMENT LIVES
;======================================
DECLIV          jsr SNDOFF              ; NO SOUND


; ---------------------------
; WAIT FOR PROJECTILES TO END
; ---------------------------

WAITPD          ldx #7                  ; 8 PROJECTILES
                lda #0                  ; ZERO TALLY
CKPRLV          ora PROJAC,X            ; CHECK ALL
                dex                     ; PROJECTILES
                bne CKPRLV              ; FOR ACTIVITY

                cmp #0                  ; ANY ACTIVE?
                bne WAITPD              ; YES! WAIT MORE!

;
; STOP SHORTS
;

                ldx #3                  ; 4 SHORTS (0-3)
STPSHO          sta SHORTF,X            ; TURN OFF
                dex                     ; ALL OF 'EM
                bpl STPSHO              ; LOOP UNTIL DONE

;
; PUT OBJECTS AT END OF GRID
;

                lda #0                  ; ERASE
                sta COLOR               ; COLOR
                lda #5                  ; ERASE ALL 6
                sta OBJNUM              ; OBJECTS
ERSOBJ          jsr DRWOBJ              ; ERASE IT!

                ldx OBJNUM              ; GET OBJECT #
                lda #30                 ; PLACE AT
                sta OBJSEG,X            ; SEG #30
                lda #1                  ; SET UP MOVE
                sta OBJINC,X            ; INCREMENT
RNDOBG          lda RANDOM              ; GET RANDOM
                and #$0F                ; SUB-GRID #
                cmp #$0F                ; 0-14
                beq RNDOBG

                sta OBJGRD,X
                dec OBJNUM              ; MORE OBJECTS?
                bpl ERSOBJ              ; YEAH, DO 'EM

                lda #$0F                ; SHOW PLAYER
                sta COLPM0              ; DEATH HERE
                sta AUDC1               ; START SOUND
MOREWT          lda RANDOM              ; SET RANDOM
                and #$1F                ; DEATH SOUND
                sta AUDF1               ; FREQUENCY
                lda #6                  ; WAIT 0.1 SEC
                jsr WAIT

                dec COLPM0              ; DEC BRIGHTNESS
                lda COLPM0              ; NOW SET
                sta AUDC1               ; DEATH VOLUME
                bne MOREWT              ; MORE WAIT

                lda LIVES               ; MORE LIVES?
                beq DEAD                ; NO MORE LIFE!

                dec LIVES               ; ONE LESS LIFE
                jsr SHOLIV              ; SHOW IT

                lda #60                 ; WAIT 1 SEC
                jsr WAIT

                lda #0                  ; RESET PLAYER
                sta KILPLR              ; KILL FLAG
                lda #$16                ; AND
                sta COLPM0              ; PLAYER COLOR
                rts                     ; AND EXIT!

DEAD            pla                     ; ALL DEAD, PULL
                pla                     ; RETURN ADDR.
                jmp LIVE                ; AND RESTART GAME


;======================================
; SHOW LIVES
;======================================
SHOLIV          lda #$90                ; SELECT DISPLAY
                sta SHCOLR              ; COLOR
                lda LIVES               ; GET LIVES
                ldx #7                  ; 7TH CHAR ON LINE
                jsr SHOBCD              ; SHOW IT!

                rts                     ; AND EXIT


;======================================
; SHOW LEVEL
;======================================
SHOLVL          ldy #$50                ; SELECT DISPLAY
                sty SHCOLR              ; COLOR
                lda BCDLVL              ; GET LEVEL#
                ldx #14                 ; 14TH CHAR


;======================================
; BCD CHAR DISPLAY
;======================================
SHOBCD          sta SHOBYT              ; SAVE CHARACTER
                and #$0F                ; GET NUM 1
                ora SHCOLR              ; ADD COLOR
                sta INFOLN+1,X          ; SHOW IT
                lda SHOBYT              ; GET CHAR.
                lsr A                   ; SHIFT RIGHT
                lsr A                   ; TO GET
                lsr A                   ; NUM 2
                lsr A
                ora SHCOLR              ; ADD COLOR
                sta INFOLN,X            ; SHOW IT
                rts                     ; AND EXIT!


;======================================
; FLASH OBJECT WHEN DEAD
;======================================
FLASH           ldy FLASHY              ; GET Y POS.
                lda #0                  ; GET READY TO
                ldx #14                 ; CLEAR OLD FLASH
CLFLSH          sta PL1,Y               ; ZERO OUT EACH
                iny                     ; BYTE OF FLASH
                dex                     ; DONE YET?
                bne CLFLSH              ; NO, LOOP.

                lda SAVEX               ; GET OBJECT'S
                clc                     ; X POS. AND
                adc #61                 ; ADD 61 FOR
                sta HPOSP1              ; FLASH HORIZ.
                lda SAVEY               ; GET Y POS AND
                clc                     ; ADD 26 FOR
                adc #26                 ; FLASH VERT.
                tay                     ; POSITION
                sty FLASHY              ; AND SAVE
                ldx #13                 ; FLASH = 14 BYTES
SEFLSH          lda FLBYTE,X            ; GET IMAGE
                sta PL1,Y               ; PUT IN PLAYER 1
                iny                     ; NEXT P/M BYTE
                dex                     ; NEXT IMAGE BYTE
                bpl SEFLSH              ; LOOP.

                lda #1                  ; SET FLASH
                sta FLTIME              ; DURATION
                rts                     ; ALL DONE!


;======================================
; TIME DELAY
;======================================
WAIT            sta TIMER               ; SET TIMER
WAITLP          lda TIMER               ; TIMER = 0?
                bne WAITLP              ; NOPE!

                rts                     ; TIMER FINISHED!


;======================================
; TURN SOUNDS OFF
;======================================
SNDOFF          lda #0                  ; ZERO OUT:
                sta FIRSOU              ; FIRE SOUND
                sta OBDSOU              ; OBJ DEATH SOUND
                sta MOVSOU              ; PLYR MOVE SOUND
                ldx #7                  ; ZERO ALL:
SNDOF2          sta AUDF1,X             ; AUDIO REGISTERS
                dex
                bpl SNDOF2

                rts                     ; AND EXIT


;======================================
; DRAW GRID
;======================================
DRGRID          lda #1                  ; TELL INTERRUPT
                sta INTRFG              ; IT'S INTRO
                jsr SNDOFF              ; TURN OFF SOUND

                lda #$20                ; TURN OFF TOP
                sta DMAC1               ; OF SCREEN BY
                lda #0                  ; SHUTTING OFF
                sta GRAC1               ; DMA & GRAPHICS
                ldx #3                  ; TURN OFF SHORTS
CLSHRT          sta SHORTF,X
                dex
                bpl CLSHRT

                ldx #7                  ; TURN OFF
CLPRJC          sta PROJAC,X            ; ALL PROJECTILES
                dex
                bpl CLPRJC

                jsr PMCLR               ; CLEAR P/M AREA

                sta OFFSET              ; ZERO OFFSET
                lda #6                  ; SET 6 PROJECT.
                sta PAVAIL              ; AVAILABLE
                lda GRIDIX              ; GET GRID #
                lsr A                   ; DIVIDE
                lsr A                   ; BY
                lsr A                   ; 8
                tax                     ; LOAD APPROPRIATE
                lda C0TBL,X             ; GRID COLOR
                sta COLPF0
                lda C1TBL,X             ; OBJECT COLOR 1
                sta COLPF1
                lda C2TBL,X             ; OBJECT COLOR 2
                sta COLPF2
                lda OBSTBL,X            ; OBJECT SPEED
                sta OBJSPD
                lda GRIDIX              ; GET GRID
                and #7                  ; SHAPE INDEX
                tax                     ; LOAD:
                lda OBCNT0,X            ; TYPE 0
                sta NUMOBJ              ; OBJECT COUNT
                lda OBCNT1,X            ; TYPE 1
                sta NUMOBJ+1            ; OBJECT COUNT
                lda OBCNT2,X            ; TYPE 2
                sta NUMOBJ+2            ; OBJECT COUNT
                lda OBCNT3,X            ; TYPE 3
                sta NUMOBJ+3            ; OBJECT COUNT
                lda OBCNT4,X            ; TYPE 4
                sta NUMOBJ+4            ; OBJECT COUNT
                ldx #4                  ; ADJUST ALL
DIFFAD          lda NUMOBJ,X            ; OBJECT COUNTS
                clc                     ; BY ADDING
                adc DIFF                ; DIFFICULTY
                sta NUMOBJ,X            ; AND SAVE
                dex
                bpl DIFFAD

                lda GRDNUM              ; GET GRID #
                asl A                   ; MULTIPLY
                asl A                   ; BY 16
                asl A
                asl A
                sta GRDADJ              ; SAVE
                sta GRDWK               ; SAVE
                tax                     ; SET X INDEX
                lda #16                 ; LOAD 16 BYTES
                sta GRDWK2
GRDLIN          lda CX,X                ; GET CLOSE X
                sta PLOTX
                lda CY,X                ; GET CLOSE Y
                sta PLOTY
                lda FX,X                ; GET FAR X
                sta DRAWX
                lda FY,X                ; GET FAR Y
                sta DRAWY
                lda COLPF0              ; INVISIBLE?
                beq NOGRD1              ; YES, DON'T DRAW

                jsr PLOTCL              ; PLOT CLOSE POINT
                jsr DRAW                ; DRAW TO FAR

NOGRD1          dec GRDWK2              ; CONTINUE DRAWING
                beq GRDBO1              ; UNTIL ALL 16

                inc GRDWK               ; LINES ARE DONE
                ldx GRDWK
                jmp GRDLIN

GRDBO1          ldx GRDADJ              ; NOW DRAW 15
                stx GRDWK               ; CLOSE GRID
                lda #15                 ; BORDER LINES
                sta GRDWK2
GRDBL1          lda CX,X                ; GET CLOSE X
                sta PLOTX
                lda CY,X                ; GET CLOSE Y
                sta PLOTY
                lda CX+1,X              ; NEXT CLOSE X
                sta DRAWX
                clc                     ; FIND POINT
                adc PLOTX               ; BETWEEN THEM
                ror A
                sta XWORK               ; AND SAVE IT!
                lda CY+1,X              ; NEXT CLOSE Y
                sta DRAWY
                clc                     ; FIND POINT
                adc PLOTY               ; BETWEEN THEM
                ror A
                sta YWORK               ; AND SAVE IT!
                lda #15                 ; SET UP A WORK
                sec                     ; AREA TO HOLD
                sbc GRDWK2              ; THE POINTS
                sta GRID                ; BETWEEN LINES
                jsr GRIDSV              ; AND SAVE THEM

                lda COLPF0              ; INVISIBLE GRID?
                beq NOGRD2              ; YES, DON'T DRAW

                jsr PLOTCL              ; PLOT CLOSE POINT1
                jsr DRAW                ; DRAW TO POINT 2

NOGRD2          dec GRDWK2              ; MORE LINES?
                beq GRDBO2              ; NO!

                inc GRDWK               ; INCREMENT TO
                ldx GRDWK               ; NEXT LINE
                jmp GRDBL1              ; AND LOOP

GRDBO2          ldx GRDADJ              ; NOW DRAW 15
                stx GRDWK               ; FAR GRID
                lda #15                 ; BORDER LINES
                sta GRDWK2
                sta OFFSET              ; AND SET OFFSET
GRDBL2          lda FX,X                ; GET FAR X
                sta PLOTX
                lda FY,X                ; GET FAR Y
                sta PLOTY
                lda FX+1,X              ; NEXT FAR X
                sta DRAWX
                clc                     ; AND FIND
                adc PLOTX               ; MIDPOINT
                ror A                   ; BETWEEN THEM
                sta XWORK               ; AND SAVE IT!
                lda FY+1,X              ; NEXT FAR Y
                sta DRAWY
                clc                     ; AND FIND
                adc PLOTY               ; MIDPOINT
                ror A                   ; BETWEEN THEM
                sta YWORK               ; AND SAVE IT!
                lda #15                 ; USE THE SAME
                sec                     ; WORK AREA
                sbc GRDWK2              ; TO HOLD THE
                sta GRID                ; MIDPOINTS
                jsr GRIDSV              ; AND SAVE THEM

                lda COLPF0              ; INVISIBLE GRID?
                beq NOGRD3              ; YES, DON'T DRAW

                jsr PLOTCL              ; PLOT FAR POINT 1
                jsr DRAW                ; DRAW TO POINT 2

NOGRD3          dec GRDWK2              ; MORE LINES?
                beq GENCOO              ; NO!

                inc GRDWK               ; INCREMENT TO
                ldx GRDWK               ; NEXT LINE
                jmp GRDBL2              ; AND LOOP


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

GENCOO          lda #0
                sta GRIDNO
DIVCTL          tax
                lda SEGX,X              ; SET UP SEGWK
                sta SEGWK               ; WITH END
                lda SEGX+15,X           ; COORDINATES
                sta SEGWK+16
                jsr DIVIDE              ; DIVIDE SEGWK

                ldx GRIDNO
                ldy #0
COPY1           lda SEGWK,Y             ; COPY SEGWK
                sta SEGX,X              ; TABLE TO SEGX
                inx
                iny
                cpy #16
                bne COPY1

; NOW THE Y COORDS
                ldx GRIDNO
                lda SEGY,X              ; SET UP SEGWK
                sta SEGWK               ; WITH END
                lda SEGY+15,X           ; COORDINATES
                sta SEGWK+16
                jsr DIVIDE              ; DIVIDE SEGWK

                ldx GRIDNO
                ldy #0
COPY2           lda SEGWK,Y             ; COPY SEGWK
                sta SEGY,X              ; TABLE TO SEGY
                inx
                iny
                cpy #16
                bne COPY2


; ----------------------------
; NOW GENERATE RIM COORDINATES
; ----------------------------

                ldx GRIDNO
                lda RIMX,X              ; SET UP SEGWK
                sta SEGWK               ; WITH END
                lda RIMX+15,X           ; COORDINATES
                sta SEGWK+16
                jsr DIVIDE              ; DIVIDE SEGWK

                ldx GRIDNO
                ldy #0
COPY3           lda SEGWK,Y             ; COPY SEGWK
                sta RIMX,X              ; TABLE TO RIMX
                inx
                iny
                cpy #16
                bne COPY3

; NOW THE RIM Y COORDS
                ldx GRIDNO
                lda RIMY,X              ; SET UP SEGWK
                sta SEGWK               ; WITH END
                lda RIMY+15,X           ; COORDINATES
                sta SEGWK+16
                jsr DIVIDE              ; DIVIDE SEGWK

                ldx GRIDNO
                ldy #0
COPY4           lda SEGWK,Y             ; COPY SEGWK
                sta RIMY,X              ; TABLE TO RIMY
                inx
                iny
                cpy #16
                bne COPY4

                lda GRIDNO              ; DO ALL 15
                clc                     ; GRID LINES
                adc #16
                sta GRIDNO
                cmp #240                ; ALL DONE?
                beq ENDDVC              ; YOU BET!

                jmp DIVCTL              ; LOOP BACK!

ENDDVC          lda #$3D                ; RESTART
                sta DMAC1               ; THE DISPLAY
                lda #$03                ; AFTER GRID
                sta GRAC1               ; IS DRAWN
                lda #0                  ; NO MORE
                sta INTRFG              ; INTRO STATUS
                rts                     ; FINIS!


;======================================
; DIVIDE SEGWK TABLE
;--------------------------------------
; This routine examines the first
; and last bytes in the SEGWK
; table and fills the bytes in
; between with an even transition
; from one endpoint to the other
;======================================
DIVIDE          lda #16
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


;======================================
; GRID COORDINATES SAVE
;======================================
GRIDSV          lda GRID
                asl A                   ; *2
                asl A                   ; *4
                asl A                   ; *8
                asl A                   ; *16
                clc                     ; ADD THE
                adc OFFSET              ; OFFSET VALUE
                tax                     ; SAVE IN INDEX
                lda XWORK               ; GET X WORK
                sta SEGX,X              ; AND SAVE
                lda YWORK               ; GET Y WORK
                sta SEGY,X              ; AND SAVE
                lda OFFSET              ; DON'T CONTINUE
                bne SAVEND              ; IF OFFSET >0

                lda PLOTX               ; GET PLOTX
                sta RIMX,X              ; AND SAVE
                lda PLOTY               ; GET PLOTY
                sta RIMY,X              ; AND SAVE
                lda DRAWX               ; GET DRAWX
                sta RIMX+15,X           ; AND SAVE
                lda DRAWY               ; GET DRAWY
                sta RIMY+15,X           ; AND SAVE
SAVEND          rts                     ; ALL DONE!


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VERTICAL BLANK ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VBI             lda #<DLI1              ; POINT TO
                sta VDSLST              ; FIRST
                lda #>DLI1              ; DISPLAY LIST
                sta VDSLST+1            ; INTERRUPT
                cld                     ; CLR DECIMAL MODE
                lda OBTIM1              ; THIS SECTION
                beq NOOBTD              ; PROCESSES

                dec OBTIM1              ; ALL TIMERS
NOOBTD          lda TIMER
                beq NOTIMR

                dec TIMER
NOTIMR          lda FLTIME
                beq NOFTIM

                dec FLTIME
NOFTIM          lda KILPLR              ; PLAYER DEAD?
                beq CHKINT              ; NO, CONTINUE!

                jmp VBCONT              ; SKIP PLAYER STUFF

CHKINT          lda INTRFG              ; IN INTRO?
                beq NOTINT              ; NO, CONTINUE!

                jmp XITVBV              ; EXIT IF INTRO

NOTINT          lda KEY                 ; GET KEYBOARD
                cmp #$1C                ; PAUSE (ESC)?
                bne CKZAP               ; NO, CHECK ZAP

                lda PAUFLG              ; GET PAUSE FLAG
                eor #$FF                ; AND FLIP
                sta PAUFLG              ; AND STORE
                jmp ENDKEY              ; DONE W/KEY

CKZAP           cmp #$21                ; SPACE BAR?
                bne ENDKEY              ; NAW, DONE W/KEY

                lda ZAP                 ; USED ZAP YET?
                beq ENDKEY              ; YES, NO ZAP

                dec ZAP                 ; ZAP NOW USED
                ldx #5                  ; TIME TO KILL
                lda #1                  ; ALL OBJECTS
ZAPOBJ          sta OBDEAD,X
                dex
                bpl ZAPOBJ

                ldx #3                  ; AND KILL
ZAPSHO          lda SHORTF,X            ; ALL SHORTS
                beq NOSKIL

                lda MISCAD              ; ALSO SET
                sed                     ; MISCELLANEOUS
                clc                     ; SCORE ADD
                adc #4                  ; FOR 400 POINTS
                sta MISCAD              ; FOR EACH SHORT
                cld
                lda #0                  ; KILL
                sta SHORTF,X            ; SHORT
NOSKIL          dex
                bpl ZAPSHO

ENDKEY          lda #0                  ; CLEAR
                sta KEY                 ; KEYPRESS.
                lda PAUFLG              ; PAUSED?
                beq NOPAU               ; NO, CONTINUE

                lda #0                  ; TURN OFF
                sta AUDC1               ; ALL SOUNDS
                sta AUDC2               ; DURING
                sta AUDC3               ; THE
                sta AUDC4               ; PAUSE
                jmp XITVBV              ; THEN EXIT

NOPAU           lda FIRSOU              ; FIRE SOUND ON?
                beq NOFSND              ; NO!

                dec FIRSOU              ; DEC COUNTER
                ldx FIRSOU              ; PUT IN INDEX
                lda FIRFRQ,X            ; GET FREQUENCY
                sta AUDF2
                lda FIRCTL,X            ; GET CONTROL
                sta AUDC2
NOFSND          lda OBDSOU              ; OBJ DEATH SOUND?
                beq NOOSND              ; NO!

                dec OBDSOU              ; DEC COUNTER
                ldx OBDSOU              ; PUT IN INDEX
                lda OBDFRQ,X            ; GET FREQUENCY
                sta AUDF3
                lda OBDCTL,X            ; GET CONTROL
                sta AUDC3
NOOSND          lda MOVSOU              ; MOVE SOUND?
                beq CYCCOL              ; NO!

                dec MOVSOU              ; DEC COUNTER
                ldx MOVSOU              ; PUT IN INDEX
                lda MOVFRQ,X            ; GET FREQUENCY
                sta AUDF4
                lda MOVCTL,X            ; GET CONTROL
                sta AUDC4
CYCCOL          lda COLPM2              ; CYCLE
                clc                     ; PLAYER 2
                adc #16                 ; COLOR
                sta COLPM2              ; SAVE IN P/M 2
                sta COLPM3              ; AND IN P/M 3
                and #$FC                ; ALSO PUT IN
                sta COLPF3              ; PF3 FOR MISSILES
                dec TRANTM              ; TRANSIENT TIME
                bne NOTRAN              ; NO CHANGE

                lda OBJHUE+4            ; FLIP
                bne TRAN1               ; TRANSIENT

                lda #2                  ; HUE
                bne STOTRN              ; TO EITHER

TRAN1           lda #0                  ; 0 OR 2
STOTRN          sta OBJHUE+4
                lda RANDOM
                ora #$1F                ; RESET
                and #$3F                ; THE
                sta TRANTM              ; TRANSIENT TIME
NOTRAN          inc PSCNT               ; INC PLYR TIMER
                lda PSCNT               ; READY TO
                cmp #3                  ; CHANGE SHAPE?
                bne NOPSIN              ; NOT YET!

                lda #0                  ; BETTER RESET
                sta PSCNT               ; INDEX
                inc SP1IX               ; AND INCREMENT
                inc SP2IX               ; ALL SHAPE
                inc SP3IX               ; INDEXES!
NOPSIN          lda PFTIME              ; SEE IF WE'RE
                beq FIRE                ; READY TO CHECK

                dec PFTIME              ; IF PLAYER IS
                jmp CHKPMV              ; SHOOTING

FIRE            lda #4                  ; RESET FIRE
                sta PFTIME              ; TIMER
                lda JOYPAD              ; USING STICK?
                beq RDSTRG              ; YES!

                lda PTRIG0              ; GET PADL TRIGGER
                jmp CMPTRG              ; CHECK IT

RDSTRG          lda STRIG               ; GET STICK TRIGGER
CMPTRG          bne CHKPMV              ; NOT FIRING!

                lda PAVAIL              ; ANY PROJ AVAIL?
                beq CHKPMV              ; NO!

                ldx #7                  ; FIND AN
PRSCAN          lda PROJAC,X            ; AVAILABLE
                beq GOTPRN              ; PROJECTILE

                dex
                bne PRSCAN

GOTPRN          dec PAVAIL              ; 1 LESS AVAILABLE
                lda #1                  ; IT'S NOW
                sta PROJAC,X            ; ACTIVE
                lda #21                 ; START UP
                sta FIRSOU              ; FIRE SOUND
                lda #0                  ; INITIALIZE
                sta PROJSG,X            ; SEGMENT # TO 0
                lda PLRGRD              ; SET UP
                sta PROGRD,X            ; PROJ GRID#
                asl A                   ; AND
                asl A                   ; MULTIPLY
                asl A                   ; BY 16
                asl A
                sta PROJGN,X            ; FOR INDEX
                lda #1                  ; INITIALIZE
                sta PROINC,X            ; PROJ INCREMENT
CHKPMV          lda JOYPAD              ; USING STICK?
                beq GOSTIK              ; YES!

                lda POT0                ; GET PADDLE
                lsr A                   ; DIVIDE BY
                lsr A                   ; 16 TO GET
                lsr A                   ; USABLE VALUE
                lsr A
                cmp #15                 ; > 14?
                bmi STOPOS              ; NO, GO STORE

                lda #14                 ; MAX. IS 14
                bne STOPOS              ; AND GO STORE

GOSTIK          lda PMTIME              ; READY FOR STICK?
                beq RDSTIK              ; YES!

                dec PMTIME              ; DEC TIMER
JVBC            jmp VBCONT              ; JMP TO CONTINUE

RDSTIK          lda #2                  ; RESET STICK TIMER
                sta PMTIME              ; TO 2 JIFFIES
                ldx STICK               ; GET STICK
                lda PLRGRD              ; GET PLYR GRID #
                clc                     ; ADD THE
                adc STKADD,X            ; DIRECTION INC
                bmi SAMPOS              ; IF <0 REJECT

                cmp #15                 ; IF <15...
                bne STOPOS              ; USE IT!

SAMPOS          lda PLRGRD              ; GET GRID#
STOPOS          cmp PLRGRD              ; SAME AS LAST?
                beq NOPSTO              ; YES, DON'T STORE

                ldx #9                  ; START UP
                stx MOVSOU              ; MOVE SOUND
                sta PLRGRD              ; SAVE GRID#
NOPSTO          asl A                   ; MULTIPLY
                asl A                   ; BY 16 FOR
                asl A                   ; POSITION
                asl A                   ; INDEX
                tax
                lda P0PL
                and #$0C                ; HIT P2/P3?
                beq NOHSHO              ; NO!

                lda #1                  ; OOPS! HIT SHORT!
                sta KILPLR              ; KILL PLAYER
                jmp VBEND               ; AND EXIT VBLANK

NOHSHO          lda SEGX,X              ; GET PLAYER'S
                clc                     ; X POSITION AND
                adc #61                 ; ADJUST FOR P/M
                sta HPOSP0              ; AND SAVE
                ldy PLRY                ; HOLD OLD Y POS
                lda SEGY,X              ; GET NEW Y POS
                clc                     ; ADJUST FOR P/M
                adc #32                 ; BY ADDING 32
                sta PLRY                ; SET Y POS
                lda #0                  ; CLEAR OUT
                ldx #15                 ; OLD PLAYER
CLRPS           sta PL0-8,Y             ; IMAGE
                iny
                dex
                bpl CLRPS

                lda #15                 ; NOW COPY
                sta SPIX                ; 16-BYTE
SPLOOP          lda #0                  ; PLAYER IMAGE
                sta PLTBYT              ; TO PLAYER 0
                lda SP1IX
                and #15
                tax
                lda SPIX
                cmp SPTBL,X
                bcc NOSP1

                cmp EPTBL,X
                bcs NOSP1

                tax
                lda PN1,X               ; GET IMAGE 1
                sta PLTBYT              ; AND SAVE
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
                ora PLTBYT              ; ADD IMAGE 2
                sta PLTBYT              ; AND SAVE
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
                ora PLTBYT              ; ADD IMAGE 3
                sta PLTBYT              ; AND SAVE
NOSP3           lda PLRY
                clc
                adc SPIX
                sec
                sbc #8
                tay
                lda PLTBYT              ; GET IMAGE BYTE
                sta PL0,Y               ; PUT IN P/M AREA
                dec SPIX                ; MORE IMAGE?
                bpl SPLOOP              ; YES!

VBCONT          lda PRADV1              ; ADVANCE PROJ?
                beq SETPRA              ; YES!

                dec PRADV1              ; NO, DEC TIMER
                jmp FLIPIT              ; GO FLIP DISPLAY

SETPRA          inc PRADVT
                lda #1                  ; SET ADVANCE
                sta PRADV1              ; TIMER

; ------------------------------
; THIS SECTION FLIP-FLOPS THE 4
; MISSILES IN ORDER TO ALLOW THE
; DISPLAY OF 8 PROJECTILES.  AS
; A RESULT, SOME FLICKER CAN BE
; OBSERVED.
; ------------------------------

FLIPIT          inc PRFLIP              ; INC FLIP INDEX
                lda PRFLIP              ; GET INDEX
                and #1                  ; MAKE 0/1
                tay                     ; SAVE IN Y
                lda PREND,Y             ; GET # OF LAST
                sta ENDVAL              ; PROJECTILE
                ldx PRSTRT,Y            ; GET # OF FIRST
                stx VBXHLD              ; PROJECTILE
                lda #3                  ; START W/MISSILE
                sta MISNUM              ; NUMBER 3
PROJLP          lda PROJAC,X            ; IS PROJ. ACTIVE?
                bne GOTPRJ              ; YOU BET.

                jmp CKPEND              ; TRY ANOTHER

GOTPRJ          ldx MISNUM              ; GET MISSILE #
                ldy PRYHLD,X            ; GET LAST POSITION
                lda MISSLS-1,Y          ; ERASE OLD
                and MISLOF,X            ; PROJECTILE
                sta MISSLS-1,Y          ; IMAGE
                lda MISSLS,Y
                and MISLOF,X
                sta MISSLS,Y
                lda MISSLS+1,Y
                and MISLOF,X
                sta MISSLS+1,Y
                ldx VBXHLD
                lda PRADVT              ; READY TO
                and #1                  ; ADVANCE PROJ?
                bne NOPADV              ; NOT YET

                lda PROJSG,X            ; GET PROJ SEG#
                clc                     ; AND
                adc PROINC,X            ; ADD INCREMENT
                sta PROJSG,X            ; THEN SAVE
NOPADV          lda PROINC,X            ; ENEMY SHOT?
                bmi NOOHCK              ; NO OBJ HIT CHECK

                ldy #5
OBKILP          lda OBDEAD,Y            ; ALREADY DEAD?
                bne NXTOCK              ; YES!

                lda OBJPRS,Y            ; OBJECT THERE?
                beq NXTOCK              ; NO!

                lda OBJTYP,Y            ; TRANSIENT?
                cmp #4
                bne NOTRNC              ; NO!

                lda OBJHUE+4            ; INVISIBLE?
                beq NXTOCK              ; YES!

NOTRNC          lda OBJGRD,Y            ; SAME GRID #
                cmp PROGRD,X            ; AS PROJ?
                bne NXTOCK              ; NO!

                lda OBJSEG,Y            ; SAME SEG #
                lsr A
                sec
                sbc PROJSG,X            ; AS PROJ?
                beq HITOBJ

                cmp #254
                bcc NXTOCK              ; NO!

HITOBJ          lda OBJTYP,Y            ; RESISTOR?
                beq CGPRDR              ; YES!

                lda #1                  ; KILL OBJECT
                sta OBDEAD,Y
                jmp KILLPR              ; AND PROJ.

CGPRDR          lda #$FF                ; PROJ NOW HEADING
                sta PROINC,X            ; FOR PLAYER!
NXTOCK          dey                     ; NEXT OBJECT
                bpl OBKILP              ; MORE TO DO!

NOOHCK          lda PROJSG,X            ; IS PROJ SEG# =0?
                beq KILLPR              ; YES, KILL IT!

                cmp #16                 ; =16?
                beq KILLPR              ; YES, KILL IT!

                clc                     ; NOW ADD PROJ
                adc PROJGN,X            ; GRID INDEX
                tax                     ; AND GET
                lda SEGX,X              ; X COORD
                ldy SEGY,X              ; AND Y COORD
                clc                     ; ADD 64 TO
                adc #64                 ; X COORD FOR
                ldx MISNUM              ; P/M HORIZ
                sta HPOSM0,X            ; AND SAVE
                tya                     ; GET Y
                clc                     ; ADD 32 TO
                adc #32                 ; Y COORD FOR
                tay                     ; P/M VERT
                sty PRYHLD,X            ; AND SAVE.
                lda MISSLS-1,Y          ; NOW DRAW
                ora MISLON,X            ; PROJECTILE IN
                sta MISSLS-1,Y          ; NEW POSITION
                lda MISSLS,Y
                ora MISLON,X
                sta MISSLS,Y
                lda MISSLS+1,Y
                ora MISLON,X
                sta MISSLS+1,Y
CKPEND          dec MISNUM              ; NEXT MISSILE #
                dec VBXHLD              ; NEXT PROJ.
                ldx VBXHLD
                cpx ENDVAL              ; DONE?
                beq SHORTS              ; YES!

                jmp PROJLP              ; DO NEXT PROJ.

KILLPR          lda #0                  ; KILL PROJ.
                sta PROJAC,X
                cpx #2                  ; ENEMY PROJ?
                bcc NOAVIN              ; YES DON'T INC

                inc PAVAIL              ; ANOTHER AVAIL
NOAVIN          lda PROJSG,X            ; SEGMENT 0?
                bne NOKILP              ; NO!

                lda PROINC,X            ; TOWARD RIM?
                bpl NOKILP              ; NO!

                lda PROGRD,X            ; SAME GRID...
                cmp PLRGRD              ; AS PLAYER?
                bne NOKILP              ; NO!

                lda #1                  ; THE PLAYER
                sta KILPLR              ; IS DEAD!
NOKILP          jmp CKPEND              ; NEXT PROJ.


; ------------------------------
; THIS SECTION HANDLES SHORTS.
; 2 PLAYERS ARE USED TO SHOW A
; MAXIMUM OF 4 SHORTS, SO SOME
; FLICKER MAY BE OBSERVED.
; ------------------------------

SHORTS          inc SHFLIP              ; TOGGLE FLIP
                lda SHFLIP              ; MASK FLIP
                lsr A                   ; TO EITHER
                and #1                  ; 0 OR 1
                tay                     ; PUT IN Y
                lda CPYSTN,Y            ; AND GET IMAGE
                sta CPYST               ; TO USE (+/X)
                lda SHFLIP              ; GET FLIP,
                and #1                  ; MASK AND
                tay                     ; PUT IN Y
                lda #>PL3               ; PUT PLAYER 3
                sta DESTHI              ; IN DESTINATION
                lda #<PL3               ; ADDRESS
                sta DESTLO              ; HI & LO
                lda #1                  ; SET DEST #
                sta DESTNM
                lda SHSTRT,Y            ; GET START
                sta VBXHLD              ; SHORT #
SHORLP          lda #0
                ldx DESTNM
                ldy SHYHLD,X            ; GET LAST INDEX
                ldx #9                  ; NOW ERASE
ERSSHO          sta (DESTLO),Y          ; PREVIOUS
                iny                     ; SHORT
                dex
                bpl ERSSHO

                ldx VBXHLD
                lda SHORTF,X            ; SHORT ALIVE?
                beq NXTSHO              ; NO!

                lda SHORTX,X            ; GET INDEX OF
                tax                     ; SHORT'S POS.
                lda RIMX,X              ; GET X COORD
                ldy RIMY,X              ; AND Y COORD
                clc
                adc #62                 ; ADJUST X
                ldx DESTNM              ; GET PLAYER#
                sta HPOSP2,X            ; AND STORE
                tya
                clc
                adc #28                 ; ADJUST Y
                sta SHYHLD,X            ; SAVE IT
                tay
                ldx CPYST
                lda #4
                sta CPYCNT
SHOCOP          lda SHOIMG,X            ; NOW COPY
                sta (DESTLO),Y          ; SHORT IMAGE
                iny                     ; TO P/M
                sta (DESTLO),Y          ; AREA
                iny
                dex
                dec CPYCNT
                bpl SHOCOP

NXTSHO          dec DESTNM              ; MORE?
                bmi VBEND               ; NO, EXIT!

                dec DESTHI              ; NEXT PLAYER
                inc VBXHLD
                jmp SHORLP              ; LOOP BACK.

VBEND           sta HITCLR              ; CLEAR COLLISION
                jmp XITVBV              ; VBI DONE! (WHEW!)


;======================================
; CLEAR Player-MISSILES
;======================================
PMCLR           lda #0                  ; PUT 255
                tax                     ; ZEROS IN
PMCLP           sta MISSLS,X            ; EACH P/M
                sta PL0,X               ; AREA
                sta PL1,X
                sta PL2,X
                sta PL3,X
                dex
                bne PMCLP

                rts                     ; FINIS!


;======================================
; CLEAR SCREEN
;======================================
CLRSC           lda #>DISP              ; INITIAL
                sta HI                  ; DISPLAY
                lda #<DISP              ; ADDRESS
                sta LO                  ; WORK AREA
                ldx #20                 ; CLEAR 20 GROUPS
CLRSC2          ldy #0                  ; OF 256 BYTES
                tya                     ; (5120 BYTES)
CLRSC3          sta (LO),Y
                dey
                bne CLRSC3

                dex
                bne CLRSC4

                rts

CLRSC4          inc HI
                jmp CLRSC2


;======================================
; GR. 7+ PLOTTER ROUTINE
;--------------------------------------
; (SEE A.N.A.L.O.G. #11)
;======================================
PLOTCL          lda PLOTY               ; MULT. Y BY 32:
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
                lda #<DISP              ; ADD THE DISPLAY
                clc                     ; ADDRESS TO GET
                adc LO                  ; THE ACTUAL
                sta LO                  ; ADDRESS OF THE
                lda #>DISP              ; BYTE THAT WILL
                adc HI                  ; BE ALTERED FOR
                sta HI                  ; THE PLOT.
                lda PLOTX               ; MASK PLOTX FOR
                and #3                  ; PLOT INDEX,
                tax                     ; PLACE IN X.
                lda PLOTX               ; GET PLOTX AND
                lsr A                   ; DIVIDE
                lsr A                   ; BY 4,
                sta YOFSET
                tay
                lda (LO),Y
                and BMASK2,X
                cmp COLOR1,X
                beq PABORT

                ldy COLOR               ; GET COLOR
                lda BMASK2,X            ; AND MASK OFF
                and COLORS,Y            ; PIXEL POSITION
                sta HOLD                ; SAVE IT,
                lda BMASK1,X            ; MASK OFF PIXEL
                ldy YOFSET              ; OF THE ADDRESS
                and (LO),Y              ; TO BE ALTERED
                ora HOLD                ; SET THE PLOT
                sta (LO),Y              ; BITS AND STORE!
PABORT          rts                     ; FINIS!

;
; PLOT MASK TABLES
;

COLORS          .byte $00,$55,$AA,$FF
BMASK1          .byte $3F,$CF,$F3,$FC
BMASK2          .byte $C0,$30,$0C,$03
COLOR1          .byte $40,$10,$04,$01


;======================================
; DRAW HANDLER
;======================================
DRAW            lda DRAWY
                cmp PLOTY               ; IS DRAWY>PLOTY?
                bcc YMINUS              ; NO!

                sec                     ; SUBTRACT
                sbc PLOTY               ; PLOTY FROM DRAWY
                sta DELTAY              ; AND SAVE DIFFERENCE.
                lda #1                  ; Y INCREMENT
                sta INCY                ; = 1 (DOWN)
                bne XVEC                ; BRANCH!

YMINUS          lda PLOTY               ; SUBTRACT
                sec                     ; DRAWY
                sbc DRAWY               ; FROM PLOTY
                sta DELTAY              ; AND SAVE DIFFERENCE.
                lda #255                ; Y INCREMENT
                sta INCY                ; = -1 (UP)
XVEC            lda DRAWX               ; IS DRAWX
                cmp PLOTX               ; > PLOTX?
                bcc XMINUS              ; NO!

                sec                     ; SUBTRACT
                sbc PLOTX               ; PLOTX FROM DRAWX
                sta DELTAX              ; AND SAVE DIFFERENCE.
                lda #1                  ; X INCREMENT
                sta INCX                ; IS 1 (RIGHT)
                bne VECSET              ; BRANCH!

XMINUS          lda PLOTX               ; SUBTRACT
                sec                     ; DRAWX FROM
                sbc DRAWX               ; PLOTX
                sta DELTAX              ; AND SAVE DIFFERENCE.
                lda #255                ; X INCREMENT
                sta INCX                ; IS -1 (LEFT)
VECSET          lda #0                  ; ZERO OUT:
                sta ACCY                ; Y ACCUMULATOR
                sta ACCX                ; X ACCUMULATOR
                lda DELTAX              ; IS DELTAX>
                cmp DELTAY              ; DELTAY?
                bcc YMAX                ; NO!

                sta COUNTR              ; SAVE DELTAX
                sta ENDPT               ; IN COUNTR, ENDPT.
                lsr A                   ; DIVIDE BY 2 AND
                sta ACCY                ; STORE IN Y ACCUM.
                jmp DRAWGO              ; START DRAW

YMAX            lda DELTAY              ; DELTAY LARGER,
                sta COUNTR              ; STORE IT IN
                sta ENDPT               ; COUNTR, ENDPT.
                lsr A                   ; DIVIDE BY 2 AND
                sta ACCX                ; STORE IN X ACCUM.

; -----------------------
; NOW WE START THE ACTUAL
; DRAWTO FUNCTION!
; -----------------------

DRAWGO          lda COUNTR              ; IF COUNTR=0...
                beq DRWEND              ; NO DRAW!

BEGIN           lda ACCY                ; ADD DELTAY
                clc                     ; TO Y ACCUMULATOR
                adc DELTAY
                sta ACCY
                cmp ENDPT               ; AT ENDPOINT YET?
                bcc BEGIN2              ; NO, GO DO X.

                lda ACCY                ; SUBTRACT ENDPT
                sec                     ; FROM Y ACCUMULATOR
                sbc ENDPT
                sta ACCY
                lda PLOTY               ; AND INCREMENT
                clc                     ; THE Y POSITION!
                adc INCY
                sta PLOTY
BEGIN2          lda ACCX                ; ADD DELTAX TO
                clc                     ; X ACCUMULATOR
                adc DELTAX
                sta ACCX
                cmp ENDPT               ; AT ENDPOINT YET?
                bcc PLOTIT              ; NO, GO PLOT.

                lda ACCX                ; SUBTRACT ENDPT
                sec                     ; FROM X ACCUMULATOR
                sbc ENDPT
                sta ACCX
                lda PLOTX               ; AND INCREMENT
                clc                     ; PLOT X
                adc INCX
                sta PLOTX
PLOTIT          jsr PLOTCL              ; PLOT THE POINT!

                dec COUNTR              ; MORE TO DRAW?
                bne BEGIN               ; YES!

DRWEND          rts                     ; NO, EXIT!


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

PN1             .byte $10,$10,$10,$10,$10,$10,$10,$10
                .byte $08,$08,$08,$08,$08,$08,$08,$08
PN2             .byte $00,$00,$00,$00,$80,$40,$20,$10
                .byte $08,$04,$02,$01,$00,$00,$00,$00
PN3             .byte $00,$00,$01,$01,$02,$02,$04,$08
                .byte $10,$20,$40,$40,$80,$80,$00,$00

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

JPLO            .byte JOYMSG&255,PADMSG&255
JPHI            .byte JOYMSG/256,PADMSG/256

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

ADDSUB          .byte 2,$FE               ; ADD/SUB. 2
ADDSB1          .byte 1,$FF               ; ADD/SUB. 1

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
