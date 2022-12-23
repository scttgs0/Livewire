
;--------------------------------------
;   Zero-page Equates
;--------------------------------------

;--------------------------------------
;--------------------------------------
                * = $60
;--------------------------------------

LO                  .byte ?
HI                  .byte ?
PLOTX               .byte ?             ; plot x value
PLOTY               .byte ?             ; plot y value
COLOR               .byte ?             ; plot color
DRAWX               .byte ?             ; drawto x
DRAWY               .byte ?             ; drawto y
ACCX                .byte ?             ; x accum.
ACCY                .byte ?             ; y accum.
DELTAX              .byte ?             ; draw work area
DELTAY              .byte ?             ; draw work area
INCX                .byte ?             ; draw x increment
INCY                .byte ?             ; draw y increment
COUNTR              .byte ?             ; drawto counter
ENDPT               .byte ?             ; draw endpoint
HOLD                .byte ?             ; work area
XWORK               .byte ?
YWORK               .byte ?
GRID                .byte ?             ; grid # work
OFFSET              .byte ?             ; grid offset
PlyrMoveTmr         .byte ?             ; player move timer
PlyrGridPos         .byte ?             ; player grid #
PLRY                .byte ?             ; player y pos.
GRIDNO              .byte ?             ; grid #
LAST                .byte ?             ; grid...
NEXT                .byte ?             ; divide...
STEP                .byte ?             ; work...
DEST                .byte ?             ; areas
VBXHLD              .byte ?             ; x hold
PlyrShootTmr        .byte ?             ; player fire timer
ENDVAL              .byte ?             ; work area
MISNUM              .byte ?             ; missile #
PRFLIP              .byte ?             ; proj. flip flag
ProjAdvTimer        .byte ?             ; proj. move timer
ProjAdvToggle       .byte ?             ; proj. timer (every other frame)
DelayTimer          .byte ?             ; general timer
isIntro             .byte ?             ; intro flag
BCDLVL              .byte ?             ; level #
zpShowColor         .byte ?             ; char. color [placed in high nibble]
zpShowByte          .byte ?             ; char. byte pos.
YOFSET              .byte ?             ; plot y offset
ObjectMoveTmr       .byte ?             ; object move timer
OBJNUM              .byte ?             ; object #
SHAPIX              .byte ?             ; obj. shape index
LENGTH              .byte ?             ; obj. length
XI                  .byte ?             ; obj. x increment
YI                  .byte ?             ; obj. y increment
SHAPCT              .byte ?             ; obj. shape cnt.
HLDGRD              .byte ?             ; obj. grid work
isPaused            .byte ?             ; pause flag
ZAP                 .byte ?             ; zap flag
SAVEX               .byte ?             ; work area
SAVEY               .byte ?             ; work area
FLASHY              .byte ?             ; obj. flash pos.
FlashTimer          .byte ?             ; flash time
SPoint1_Index       .byte ?             ; player...
SPoint2_Index       .byte ?             ; shape...
SPoint3_Index       .byte ?             ; index...
StartPointIndex     .byte ?             ; areas
PlayerTempByte      .byte ?             ; plyr. image byte
PlyrShapeCnt        .byte ?             ; plyr. shape count
isPlayerDead        .byte ?             ; kill plyr flag
ProjAvail           .byte ?             ; # proj. available
TransientTmr        .byte ?             ; transient timer
DESTLO              .byte ?             ; destination...
DESTHI              .byte ?             ; address
SHFLIP              .byte ?             ; short flip flag
DESTNM              .byte ?             ; short plyr #
CPYST               .byte ?             ; short image start
DMAC1               .byte ?             ; dma ctrl work
GRAC1               .byte ?             ; graphics ctrl wk.
GridIndex           .byte ?             ; grid index; range[0-63]
LIVES               .byte ?             ; lives left
GRDADJ              .byte ?             ; grid...
GRDWK               .byte ?             ; draw...
GRDWK2              .byte ?             ; work...
GRDNUM              .byte ?             ; areas
ObjectSpeed         .byte ?             ; obj. speed
JOYPAD              .byte ?             ; 0=stick; 1=paddle
CPYCNT              .byte ?             ; short copy cnt.
BONUS               .byte ?             ; bonus value
FIRSOU              .byte ?             ; fire sound count
OBDSOU              .byte ?             ; obj. death sound
MOVSOU              .byte ?             ; plyr move sound
PRYHLD              .fill 4             ; proj. y holds
SCORE               .fill 3             ; score
SCOADD              .fill 3             ; score add value
MISCAD              .byte ?             ; misc. score add
NUMOBJ              .fill 5             ; objects left
DIFF                .byte ?             ; difficulty adjust
isObjPresent        .fill 6             ; obj present flags

isDirtyPlayfield    .byte ?
isDirtyPlayer       .byte ?

JIFFYCLOCK          .byte ?
InputFlags          .byte ?
InputType           .byte ?
itJoystick      = 0
itKeyboard      = 1
KEYCHAR             .byte ?             ; last key pressed
CONSOL              .byte ?             ; state of OPTION,SELECT,START

zpSource            .dword ?            ; Starting address for the source data (4 bytes)
zpDest              .dword ?            ; Starting address for the destination block (4 bytes)
zpSize              .dword ?            ; Number of bytes to copy (4 bytes)

zpTemp1             .byte ?
zpTemp2             .byte ?

zpIndex1            .word ?
zpIndex2            .word ?
zpIndex3            .word ?

RND_MIN             .byte ?
RND_SEC             .byte ?
RND_RESULT          .word ?
