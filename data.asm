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