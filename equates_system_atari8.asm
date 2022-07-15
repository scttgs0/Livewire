;--------------------------------------
;   SYSTEM EQUATES
;--------------------------------------

ADLI            = $0080
AVB             = $0040
ALMS            = $0040
AJMP            = $0001
AEMPTY1         = $0000
AEMPTY4         = $0030
AEMPTY8         = $0070

ATTRAC          = $004D                 ; ATTRACT MODE

VDSLST          = $0200                 ; DLI VECTOR
DMACTL          = $022F                 ; DMA CONTROL
DLISTL          = $0230                 ; DISP. LIST
PRIOR           = $026F                 ; PRIORITY
POT0            = $0270                 ; PADDLE 0
STICK           = $0278                 ; JOYSTICK
PTRIG0          = $027C                 ; PADDLE TRIG.
STRIG           = $0284                 ; STICK TRIGGER

COLPM0          = $02C0                 ; PLAYER COLORS
COLPM1          = $02C1
COLPM2          = $02C2
COLPM3          = $02C3
COLPF0          = $02C4
COLPF1          = $02C5
COLPF2          = $02C6
COLPF3          = $02C7
COLBK           = $02C8                 ; COLORS

KEY             = $02FC                 ; KEYBOARD

HPOSP0          = $D000                 ; PLAYER POSITIONS
HPOSP1          = $D001
HPOSP2          = $D002
HPOSM0          = $D004                 ; MISSILE POSITIONS
P0PL            = $D00C                 ; PL0 TO PLAYER COLL.
GRACTL          = $D01D                 ; GRAPHICS CTRL.
HITCLR          = $D01E                 ; COLLISION CLEAR
CONSOL          = $D01F                 ; CONSOLE BUTTONS

AUDF1           = $D200                 ; AUDIO FREQUENCY
AUDC1           = $D201                 ; AUDIO CONTROL
AUDF2           = $D202
AUDC2           = $D203
AUDF3           = $D204
AUDC3           = $D205
AUDF4           = $D206
AUDC4           = $D207
AUDCTL          = $D208                 ; MAIN AUDIO CTRL.
RANDOM          = $D20A                 ; RANDOM #

PMBASE          = $D407                 ; P/M BASE ADDR
WSYNC           = $D40A                 ; WAIT/SYNC
NMIEN           = $D40E                 ; INTERRUPT ENABLE

SETVBV          = $E45C                 ; VBLANK SET
XITVBV          = $E462                 ; VBLANK EXIT
SIOINV          = $E465