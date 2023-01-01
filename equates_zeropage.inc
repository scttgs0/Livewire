
;--------------------------------------
;   Zero-page Equates
;--------------------------------------

;--------------------------------------
;--------------------------------------
                * = $80
;--------------------------------------

LO              .byte ?
HI              .byte ?
PLOTX           .byte ?                 ; PLOT X VALUE
PLOTY           .byte ?                 ; PLOT Y VALUE
COLOR           .byte ?                 ; PLOT COLOR
DRAWX           .byte ?                 ; DRAWTO X
DRAWY           .byte ?                 ; DRAWTO Y
ACCX            .byte ?                 ; X ACCUM.
ACCY            .byte ?                 ; Y ACCUM.
DELTAX          .byte ?                 ; DRAW WORK AREA
DELTAY          .byte ?                 ; DRAW WORK AREA
INCX            .byte ?                 ; DRAW X INCREMENT
INCY            .byte ?                 ; DRAW Y INCREMENT
COUNTR          .byte ?                 ; DRAWTO COUNTER
ENDPT           .byte ?                 ; DRAW ENDPOINT
HOLD            .byte ?                 ; WORK AREA
XWORK           .byte ?
YWORK           .byte ?
GRID            .byte ?                 ; GRID # WORK
OFFSET          .byte ?                 ; GRID OFFSET
PMTIME          .byte ?                 ; PLAYER MOVE TIMER
PLRGRD          .byte ?                 ; PLAYER GRID#
PLRY            .byte ?                 ; PLAYER Y POS.
GRIDNO          .byte ?                 ; GRID #
LAST            .byte ?                 ; GRID...
NEXT            .byte ?                 ; DIVIDE...
STEP            .byte ?                 ; WORK...
DEST            .byte ?                 ; AREAS
VBXHLD          .byte ?                 ; X HOLD
PFTIME          .byte ?                 ; PLAYER FIRE TIMER
ENDVAL          .byte ?                 ; WORK AREA
MISNUM          .byte ?                 ; MISSILE #
PRFLIP          .byte ?                 ; PROJ. FLIP FLAG
PRADVT          .byte ?                 ; PROJ. MOVE TIMER
PRADV1          .byte ?                 ; PROJ. TIMER
TIMER           .byte ?                 ; GENERAL TIMER
INTRFG          .byte ?                 ; INTRO FLAG
BCDLVL          .byte ?                 ; LEVEL #
SHCOLR          .byte ?                 ; CHAR. COLOR
SHOBYT          .byte ?                 ; CHAR. BYTE POS.
YOFSET          .byte ?                 ; PLOT Y OFFSET
OBTIM1          .byte ?                 ; OBJECT MOVE TIMER
OBJNUM          .byte ?                 ; OBJECT #
SHAPIX          .byte ?                 ; OBJ. SHAPE INDEX
LENGTH          .byte ?                 ; OBJ. LENGTH
XI              .byte ?                 ; OBJ. X INCREMENT
YI              .byte ?                 ; OBJ. Y INCREMENT
SHAPCT          .byte ?                 ; OBJ. SHAPE CNT.
HLDGRD          .byte ?                 ; OBJ. GRID WORK
PAUFLG          .byte ?                 ; PAUSE FLAG
ZAP             .byte ?                 ; ZAP FLAG
SAVEX           .byte ?                 ; WORK AREA
SAVEY           .byte ?                 ; WORK AREA
FLASHY          .byte ?                 ; OBJ. FLASH POS.
FLTIME          .byte ?                 ; FLASH TIME
SP1IX           .byte ?                 ; PLAYER...
SP2IX           .byte ?                 ; SHAPE...
SP3IX           .byte ?                 ; INDEX...
SPIX            .byte ?                 ; AREAS
PLTBYT          .byte ?                 ; PLYR. IMAGE BYTE
PSCNT           .byte ?                 ; PLYR. SHAPE COUNT
KILPLR          .byte ?                 ; KILL PLYR FLAG
PAVAIL          .byte ?                 ; # PROJ. AVAILABLE
TRANTM          .byte ?                 ; TRANSIENT TIMER
DESTLO          .byte ?                 ; DESTINATION...
DESTHI          .byte ?                 ; ADDRESS
SHFLIP          .byte ?                 ; SHORT FLIP FLAG
DESTNM          .byte ?                 ; SHORT PLYR #
CPYST           .byte ?                 ; SHORT IMAGE START
DMAC1           .byte ?                 ; DMA CTRL WORK
GRAC1           .byte ?                 ; GRAPHICS CTRL WK.
GRIDIX          .byte ?                 ; GRID INDEX
LIVES           .byte ?                 ; LIVES LEFT
GRDADJ          .byte ?                 ; GRID...
GRDWK           .byte ?                 ; DRAW...
GRDWK2          .byte ?                 ; WORK...
GRDNUM          .byte ?                 ; AREAS
OBJSPD          .byte ?                 ; OBJ. SPEED
JOYPAD          .byte ?                 ; STICK/PADDLE
CPYCNT          .byte ?                 ; SHORT COPY CNT.
BONUS           .byte ?                 ; BONUS VALUE
FIRSOU          .byte ?                 ; FIRE SOUND COUNT
OBDSOU          .byte ?                 ; OBJ. DEATH SOUND
MOVSOU          .byte ?                 ; PLYR MOVE SOUND
PRYHLD          .fill 4                 ; PROJ. Y HOLDS
SCORE           .fill 3                 ; SCORE
SCOADD          .fill 3                 ; SCORE ADD VALUE
MISCAD          .byte ?                 ; MISC. SCORE ADD
NUMOBJ          .fill 5                 ; OBJECTS LEFT
DIFF            .byte ?                 ; DIFFICULTY ADJUST
OBJPRS          .fill 6                 ; OBJ PRESENT FLAGS
