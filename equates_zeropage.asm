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
PMTIME              .byte ?             ; player move timer
PLRGRD              .byte ?             ; player grid#
PLRY                .byte ?             ; player y pos.
GRIDNO              .byte ?             ; grid #
LAST                .byte ?             ; grid...
NEXT                .byte ?             ; divide...
STEP                .byte ?             ; work...
DEST                .byte ?             ; areas
VBXHLD              .byte ?             ; x hold
PFTIME              .byte ?             ; player fire timer
ENDVAL              .byte ?             ; work area
MISNUM              .byte ?             ; missile #
PRFLIP              .byte ?             ; proj. flip flag
PRADVT              .byte ?             ; proj. move timer
PRADV1              .byte ?             ; proj. timer
TIMER               .byte ?             ; general timer
isIntro             .byte ?             ; intro flag
BCDLVL              .byte ?             ; level #
zpShowColor         .byte ?             ; char. color [placed in high nibble]
zpShowByte          .byte ?             ; char. byte pos.
YOFSET              .byte ?             ; plot y offset
OBTIM1              .byte ?             ; object move timer
OBJNUM              .byte ?             ; object #
SHAPIX              .byte ?             ; obj. shape index
LENGTH              .byte ?             ; obj. length
XI                  .byte ?             ; obj. x increment
YI                  .byte ?             ; obj. y increment
SHAPCT              .byte ?             ; obj. shape cnt.
HLDGRD              .byte ?             ; obj. grid work
PAUFLG              .byte ?             ; pause flag
ZAP                 .byte ?             ; zap flag
SAVEX               .byte ?             ; work area
SAVEY               .byte ?             ; work area
FLASHY              .byte ?             ; obj. flash pos.
FLTIME              .byte ?             ; flash time
SP1IX               .byte ?             ; player...
SP2IX               .byte ?             ; shape...
SP3IX               .byte ?             ; index...
SPIX                .byte ?             ; areas
PLTBYT              .byte ?             ; plyr. image byte
PSCNT               .byte ?             ; plyr. shape count
KILPLR              .byte ?             ; kill plyr flag
ProjAvail           .byte ?             ; # proj. available
TRANTM              .byte ?             ; transient timer
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
JOYPAD              .byte ?             ; stick/paddle
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
OBJPRS              .fill 6             ; obj present flags

isDirtyPlayfield    .byte ?

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
