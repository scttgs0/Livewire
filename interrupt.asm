;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HandleIrq       .proc
                .m16i16
                pha
                phx
                phy

                .m8i8
                lda @l INT_PENDING_REG1
                bit #FNX1_INT00_KBD
                beq _1

                jsl KeyboardHandler

                lda @l INT_PENDING_REG1
                sta @l INT_PENDING_REG1

_1              lda @l INT_PENDING_REG0
                bit #FNX0_INT00_SOF
                beq _XIT

                jsl VbiHandler

                lda @l INT_PENDING_REG0
                sta @l INT_PENDING_REG0

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
HandleIrq_END   rti
                ;jmp IRQ_PRIOR

                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Handle Key notifications
;--------------------------------------
;   ESC         $01/$81  press/release
;   R-Ctrl      $1D/$9D
;   Space       $39/$B9
;   F2          $3C/$BC
;   F3          $3D/$BD
;   F4          $3E/$BE
;   Up          $48/$C8
;   Left        $4B/$CB
;   Right       $4D/$CD
;   Down        $50/$D0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KeyboardHandler .proc
KEY_F2          = $3C                   ; Option
KEY_F3          = $3D                   ; Select
KEY_F4          = $3E                   ; Start
KEY_UP          = $48                   ; joystick alternative
KEY_LEFT        = $4B
KEY_RIGHT       = $4D
KEY_DOWN        = $50
KEY_CTRL        = $1D                   ; fire button
;---

                .m16i16
                pha
                phx
                phy

                .m8i8
                .setbank $00

                lda KBD_INPT_BUF
                pha
                sta KEYCHAR

                and #$80                ; is it a key release?
                bne _1r                 ;   yes

_1              pla                     ;   no
                pha
                cmp #KEY_F2
                bne _2

                lda CONSOL
                eor #$04
                sta CONSOL

                jmp _CleanUpXIT

_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                bit #$01
                beq _4a

                eor #$01
                ora #$02                ; cancel KEY_DOWN
                sta InputFlags

_4a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #$01
                sta InputFlags

                jmp _CleanUpXIT

_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                bit #$02
                beq _5a

                eor #$02
                ora #$01                ; cancel KEY_UP
                sta InputFlags

_5a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #$02
                sta InputFlags

                jmp _CleanUpXIT

_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                bit #$04
                beq _6a

                eor #$04
                ora #$08                ; cancel KEY_RIGHT
                sta InputFlags

_6a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #$04
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                bit #$08
                beq _7a

                eor #$08
                ora #$04                ; cancel KEY_LEFT
                sta InputFlags

_7a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #$08
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #$10
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #$10
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     stz KEYCHAR
                pla

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DISPLAY LIST INTERRUPTS - HEAD
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI1  .proc
                ;pha                     ; save accum

                ;lda GRAC1              ; get gr. ctrl [0,3]
                ;sta WSYNC              ; wait for sync
                ;sta GRACTL             ; store it

                ;lda DMAC1              ; get and save
                ;sta DMACTL             ; DMA ctrl

                ;lda #<Interrupt_DLI2   ; point...
                ;sta VDSLST             ; to...
                ;lda #>Interrupt_DLI2   ; next...
                ;sta VDSLST+1           ; DLI!

                ;pla                     ; get accum
                rti                     ; and exit!
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DISPLAY LIST INTERRUPTS - TAIL
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI2  .proc
                ;pha                     ; save accum
                ;.m16

                ;lda #$e4e4              ; get white
                ;sta PfColor0            ; put in color 0
                ;lda #$00e4
                ;sta PfColor0+2

                ;lda #$4cdc              ; put blue...
                ;sta PfColor1            ; in color 1
                ;lda #$0044
                ;sta PfColor1+2

                ;lda #$982c              ; put orange...
                ;sta PfColor2            ; in color 2
                ;lda #$00fc
                ;sta PfColor2+2

                ;.m8
                ;pla                     ; get accum.
                rti                     ; and exit
                .endproc


;--------------------------------------

;----------------
; SCREEN MESSAGES
;----------------

INFOLN          .text '000000 00 LVL 01'
InfoLineColor   .byte $10,$10,$10,$10
                .byte $10,$10,$00,$20
                .byte $20,$00,$30,$30
                .byte $30,$00,$30,$30

MAGMSG          .text '  ANALOG COMPUTING  '
TitleMsg        ;.text '      LIVEWIRE      '
;   top
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $D4,$D5,$D0,$D1,$DC,$DD,$CC,$CD
                .byte $E0,$E1,$D0,$D1,$D8,$D9,$CC,$CD
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;   bottom
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $D6,$D7,$D2,$D3,$DE,$DF,$CE,$CF
                .byte $E2,$E3,$D2,$D3,$DA,$DB,$CE,$CF
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

AuthorMsg       .text '    BY TOM HUDSON   '
JoyMsg          .text '      JOYSTICK      '
PadMsg          .text '       PADDLE       '
LASTSC          .text '                '


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VERTICAL BLANK ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VbiHandler      .proc
                .m16i16
                pha
                phx
                phy
                ;cld                     ; clr decimal mode

                .m8i8
                .setbank $00

                inc JIFFYCLOCK

                lda JOYSTICK0           ; read joystick0
                and #$1F
                cmp #$1F
                beq _1                  ; when no activity, keyboard is alternative

                sta InputFlags          ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType

_1              ldx InputType
                bne _2                  ; keyboard, move on

                sta InputFlags

_2              ;lda #<Interrupt_DLI1   ; point to
                ;sta VDSLST             ; first
                ;lda #>Interrupt_DLI1   ; display list
                ;sta VDSLST+1           ; interrupt

;   this section processes all timers
                lda ObjectMoveTmr
                beq _3

                dec ObjectMoveTmr

_3              lda DelayTimer
                beq _4

                dec DelayTimer

_4              lda FlashTimer
                beq _5

                dec FlashTimer

_5              lda isPlayerDead        ; player dead?
                beq _6                  ;   no, continue!

                jmp _VBCONT             ; skip player stuff

_6              lda isIntro             ; in intro?
                beq _7                  ;   no, continue!

                jmp VBEND               ; exit if intro

_7              lda KEYCHAR             ; get keyboard
                cmp #$1C                ; pause (esc)?
                bne _8                  ;   no

                lda isPaused            ; toggle pause state
                eor #$FF
                sta isPaused
                jmp _endKeys            ; done w/key

_8              cmp #$39                ; space bar?
                bne _endKeys            ;   naw, done w/key

                lda ZAP                 ; used zap yet?
                beq _endKeys            ;   yes, no zap

                dec ZAP                 ; zap now used

                ldx #5                  ; time to kill all objects
                lda #TRUE
_next1          sta isObjDead,X
                dex
                bpl _next1

                ldx #3                  ; and kill all shorts
_next2          lda SHORTF,X
                beq _9

                lda MISCAD              ; also set miscellaneous score add
                sed
                clc
                adc #4                  ; 400 points for each short
                sta MISCAD
                cld

                lda #0                  ; kill short
                sta SHORTF,X
_9              dex
                bpl _next2

_endKeys        lda #0                  ; clear keypress
                sta KEYCHAR

;   sound processing
                lda isPaused            ; paused?
                beq _notPaused          ;   no, continue

                lda #0                  ; turn off
                sta SID_CTRL1           ; all sounds
                sta SID_CTRL2           ; during
                sta SID_CTRL3           ; the
                ;sta AUDC4              ; pause

                jmp VBEND               ; then exit

_notPaused ;      lda FIRSOU              ; fire sound on?
;                 beq _10                 ;   no!

;                 dec FIRSOU              ; dec counter
;                 ldx FIRSOU              ; put in index
;                 lda FIRFRQ,X            ; get frequency
;                 sta SID_FREQ2
;                 lda FIRCTL,X            ; get control
;                 sta SID_CTRL2

; _10             lda OBDSOU              ; obj death sound?
;                 beq _11                 ;   no!

;                 dec OBDSOU              ; dec counter
;                 ldx OBDSOU              ; put in index
;                 lda OBDFRQ,X            ; get frequency
;                 sta SID_FREQ3
;                 lda OBDCTL,X            ; get control
;                 sta SID_CTRL3

; _11             lda MOVSOU              ; move sound?
;                 beq _12                 ;   no!

;                 dec MOVSOU              ; dec counter
;                 ldx MOVSOU              ; put in index
                ;lda MOVFRQ,X           ; get frequency
                ;sta AUDF4
                ;lda MOVCTL,X           ; get control
                ;sta AUDC4

_12             ;lda COLPM2             ; cycle player 2 color
                ;clc
                ;adc #16
                ;sta COLPM2             ; save in p/m 2
                ;sta COLPM3             ; and in p/m 3
                ;and #$FC               ; also put in pf3 for missiles
                ;sta COLPF3

;   transient processing
                dec TransientTmr        ; transient time
                bne _15                 ;   no change

                lda OBJHUE+4            ; flip transient
                bne _13

                lda #2                  ; hue to either
                bne _14

_13             lda #0                  ; 0 or 2
_14             sta OBJHUE+4

                .randomByte
                ora #$1F                ; reset the transient time
                and #$3F
                sta TransientTmr

;   player processing
_15             inc PlyrShapeCnt        ; inc plyr timer
                lda PlyrShapeCnt        ; ready to change shape?
                cmp #3
                bne _16                 ;   not yet!

                lda #0                  ; better reset index
                sta PlyrShapeCnt

                inc SPoint1_Index       ; and increment all shape indexes!
                inc SPoint2_Index
                inc SPoint3_Index

_16             lda PlyrShootTmr        ; check if player is shooting
                beq _17

                dec PlyrShootTmr
                bra _chkPlyrMove

_17             lda #4                  ; reset fire timer
                sta PlyrShootTmr

                lda JOYPAD              ; using stick?
                beq _readTrigger        ;   yes!

                ;lda PTRIG0             ; get padl trigger
                ;jmp _cmpTrigger        ; check it

_readTrigger    lda InputFlags          ; get stick trigger
                and #$10
_cmpTrigger     bne _chkPlyrMove        ; not firing!

                lda ProjAvail           ; any proj avail?
                beq _chkPlyrMove        ;   no!

                ldx #7                  ; find an available projectile
_projScan       lda isProjActive,X
                beq _gotProj

                dex
                bne _projScan

_gotProj        dec ProjAvail           ; 1 less available
                lda #TRUE               ; it's now active
                sta isProjActive,X

                ; lda #21                 ; start up
                ; sta FIRSOU              ; fire sound

                lda #0                  ; initialize segment # to 0
                sta PROJSG,X

                lda PlyrGridPos         ; set up proj grid #
                sta ProjGridPos,X
                asl A                   ; *16
                asl A
                asl A
                asl A
                sta ProjGridIndex,X     ; for index

                lda #1                  ; initialize proj increment
                sta ProjIncrement,X

_chkPlyrMove    lda JOYPAD              ; using stick?
                beq _goStick              ;   yes!

                ;lda POT0               ; get paddle
                ;lsr A                  ; divide by
                ;lsr A                  ; 16 to get
                ;lsr A                  ; usable value
                ;lsr A
                ;cmp #15                ; > 14?
                ;bmi _storePos          ;   no, go store
                ;bra _storePos  ; HACK:

                ;lda #14                 ; max. is 14
                ;bne _storePos           ; and go store

_goStick        lda PlyrMoveTmr         ; ready for stick?
                beq _readStick          ;   yes!

                dec PlyrMoveTmr         ; dec timer
                jmp _VBCONT             ; jmp to continue

_readStick      lda #3                  ; reset stick timer
                sta PlyrMoveTmr         ; to 3 jiffies

                lda InputFlags          ; get stick
                and #$0F
                tax

                lda PlyrGridPos         ; get plyr grid #
                clc                     ; add the
                adc DeflectionValue,X   ; direction inc
                bmi _samePos            ; if <0.. reject

                cmp #15                 ; if <15.. use it!
                bne _storePos

_samePos        lda PlyrGridPos         ; get grid #
_storePos       cmp PlyrGridPos         ; same as last?
                beq _noStore            ;   yes, don't store

                ; ldx #9                  ; start up
                ; stx MOVSOU              ; move sound

                sta PlyrGridPos         ; save grid #

_noStore        asl A                   ; *16 (position index)
                asl A
                asl A
                asl A
                tax

                ;lda P0PL
                ;and #$0C               ; hit p2/p3?
                ;beq _noHitShort        ;   no!
                ; bra _noHitShort  ; HACK:

                ; lda #TRUE               ; oops! hit short!
                ; sta isPlayerDead        ; kill player
                ; jmp VBEND               ; and exit vblank

_noHitShort     lda SEGX,X              ; get player's
                .m16
                and #$FF
                asl A                   ; *2
                clc                     ; x position and
                adc #61                 ; adjust for p/m
                sta SP00_X_POS          ; and save
                .m8

                ldy PLRY                ; hold old y pos

                lda SEGY,X              ; get new y pos
                clc                     ; adjust for p/m
                adc #32                 ; by adding 32
                sta PLRY                ; set y pos

;   create the animated player sprite
                lda #0                  ; clear out old player image
                ldx #15
_clrPS          sta PlyrAnimFrame,X
                dex
                bpl _clrPS

;   generate the new animated player frame
                lda #15                 ; copy 16-byte
                sta StartPointIndex

_startPointLoop lda #0                  ; player image to player 0
                sta PlayerTempByte

                lda SPoint1_Index
                and #15
                tax
                lda StartPointIndex
                cmp StartPointTbl,X
                bcc _skipSP1

                cmp EndPointTbl,X
                bcs _skipSP1

                tax
                lda PN1,X               ; get image 1 and save
                sta PlayerTempByte

_skipSP1        lda SPoint2_Index
                and #15
                tax
                lda StartPointIndex
                cmp StartPointTbl,X
                bcc _skipSP2

                cmp EndPointTbl,X
                bcs _skipSP2

                tax
                lda PN2,X
                ora PlayerTempByte      ; add image 2 and save
                sta PlayerTempByte

_skipSP2        lda SPoint3_Index
                and #15
                tax
                lda StartPointIndex
                cmp StartPointTbl,X
                bcc _skipSP3

                cmp EndPointTbl,X
                bcs _skipSP3

                tax
                lda PN3,X
                ora PlayerTempByte      ; add image 3 and save
                sta PlayerTempByte

_skipSP3        lda PLRY
                clc
                adc StartPointIndex
                sec
                sbc #16
                clc
                adc #32
                sta SP00_Y_POS

                ldy StartPointIndex
                lda PlayerTempByte      ; get image byte
                sta PlyrAnimFrame,Y     ; put in p/m area

                dec StartPointIndex     ; more image?
                bpl _startPointLoop     ;   yes!

                lda #TRUE
                sta isDirtyPlayer

_VBCONT         lda ProjAdvToggle       ; advance proj?
                beq _setProjAdv         ;   yes!

                dec ProjAdvToggle       ;   no, dec timer
                bra FLIPIT              ; go flip display

_setProjAdv     inc ProjAdvTimer

                lda #1                  ; set advance timer
                sta ProjAdvToggle

; ------------------------------
; This section flip-flops the 4
; missiles in order to allow the
; display of 8 projectiles.  As
; a result, some flicker can be
; observed.
; ------------------------------

FLIPIT          inc PRFLIP              ; inc flip index
                lda PRFLIP              ; get index
                and #1                  ; make 0/1
                tay                     ; save in y
                lda PREND,Y             ; get # of last
                sta ENDVAL              ; projectile
                ldx PRSTRT,Y            ; get # of first
                stx VBXHLD              ; projectile

                lda #3                  ; start w/missile #3
                sta MISNUM
_projLoop       lda isProjActive,X      ; is proj. active?
                bne _gotActProj         ;     you bet

                jmp _chkProjEnd         ;     try another

_gotActProj     ldx MISNUM              ; get missile #
                ldy PRYHLD,X            ; get last position

                ldx VBXHLD
                lda ProjAdvTimer        ; ready to advance proj?
                and #1
                bne _noProjAdv          ;   not yet

                lda PROJSG,X            ; get proj seg #
                clc                     ; and
                adc ProjIncrement,X     ; add increment
                sta PROJSG,X            ; then save

_noProjAdv      lda ProjIncrement,X     ; enemy shot?
                bmi _noObjHitChk        ;   no obj hit check

                ldy #5
_objKillLoop    lda isObjDead,Y         ; already dead?
                bne _nextObjChk         ;   yes!

                lda isObjPresent,Y      ; object there?
                beq _nextObjChk         ;   no!

                lda ObjectType,Y        ; is object type 4 (transient)?
                cmp #4
                bne _NOTRNC             ;   no!

                lda OBJHUE+4            ; invisible?
                beq _nextObjChk         ;   yes!

_NOTRNC         lda OBJGRD,Y            ; same grid # as proj?
                cmp ProjGridPos,X
                bne _nextObjChk         ;   no!

                lda OBJSEG,Y            ; same seg #
                lsr A
                sec
                sbc PROJSG,X            ; as proj?
                beq _hitObj

                cmp #254
                bcc _nextObjChk         ;   no!

_hitObj         lda ObjectType,Y        ; is object type 0 (resistor)?
                beq _cgprdr             ;   yes!

                lda #TRUE               ; kill object
                sta isObjDead,Y
                jmp _killProj           ; and proj.

_cgprdr         lda #$FF                ; proj now heading for player!
                sta ProjIncrement,X

_nextObjChk     dey                     ; next object
                bpl _objKillLoop

_noObjHitChk    lda PROJSG,X            ; is proj seg# =0?
                beq _killProj           ;   yes, kill it!

                cmp #16                 ; =16?
                beq _killProj           ;   yes, kill it!

                clc                     ; now add proj grid index
                adc ProjGridIndex,X
                tax                     ; and get
                lda SEGX,X              ; x coord and y coord
                asl A                   ; *2
                ldy SEGY,X
                clc                     ; add 64 to x coord for p/m horiz
                adc #64

;   now draw projectile in new position
                pha
                lda MISNUM
                asl A                   ; *8
                asl A
                asl A
                tax
                pla
                sta SP12_X_POS,X        ; and save

                phx
                ldx MISNUM
                tya                     ; get y
                clc                     ; add 32 to y coord for p/m vert
                adc #56
                tay
                sty PRYHLD,X            ; and save.
                plx
                sta SP12_Y_POS,X

_chkProjEnd     dec MISNUM              ; next missile #
                dec VBXHLD              ; next proj.
                ldx VBXHLD
                cpx ENDVAL              ; done?
                beq SHORTS              ;   yes!

                jmp _projLoop           ; do next proj.

_killProj       lda #FALSE              ; kill proj.
                sta isProjActive,X

                phx
                txa
                asl A                   ; *8
                asl A
                asl A
                tax
                lda #0                  ; hide the sprite
                sta SP12_X_POS,X
                sta SP12_Y_POS,X
                plx

                cpx #2                  ; enemy proj?
                bcc _noavin             ;   yes, don't inc

                inc ProjAvail           ; another avail

;   determine whether player was hit by projectile
_noavin         lda PROJSG,X            ; segment 0?
                bne _nokilp             ;   no!

                lda ProjIncrement,X     ; toward rim?
                bpl _nokilp             ;   no!

                lda ProjGridPos,X       ; same grid as player?
                cmp PlyrGridPos
                bne _nokilp             ;   no!

                lda #TRUE               ; the player is dead!
                sta isPlayerDead

_nokilp         jmp _chkProjEnd         ; next proj.


; ------------------------------
; This section handles shorts.
; 2 players are used to show a
; maximum of 4 shorts, so some
; flicker may be observed.
; ------------------------------

SHORTS  ;         inc SHFLIP              ; toggle flip
;                 lda SHFLIP              ; mask flip
;                 lsr A                   ; to either
;                 and #1                  ; 0 or 1
;                 tay                     ; put in y
;                 lda ShortStartIdx,Y     ; and get image
;                 sta CPYST               ; to use (+/x)
;                 lda SHFLIP              ; get flip,
;                 and #1                  ; mask and
;                 tay                     ; put in y
;                 lda #>PL3               ; put player 3
;                 sta DESTHI              ; in destination
;                 lda #<PL3               ; address
;                 sta DESTLO              ; hi & lo
;                 lda #1                  ; set dest #
;                 sta DESTNM

;                 lda ShortStart,Y        ; get start
;                 sta VBXHLD              ; short #
; SHORLP          lda #0
;                 ldx DESTNM
;                 ldy ShortHoldY,X        ; get last index

;                 ldx #9
; ERSSHO          sta (DESTLO),Y          ; erase previous short
;                 iny
;                 dex
;                 bpl ERSSHO

;                 ldx VBXHLD
;                 lda SHORTF,X            ; short alive?
;                 beq NXTSHO              ;   no!

;                 lda SHORTX,X            ; get index of
;                 tax                     ; short's pos.
;                 lda RIMX,X              ; get x coord
;                 ldy RIMY,X              ; and y coord
;                 clc
;                 adc #62                 ; adjust x
;                 ldx DESTNM              ; get player#
;                 sta SP02_X_POS,X        ; and store
;                 tya
;                 clc
;                 adc #28                 ; adjust y
;                 sta ShortHoldY,X        ; save it
;                 tay
;                 ldx CPYST
;                 lda #4
;                 sta CPYCNT
; SHOCOP          lda ShortImage,X        ; now copy short image
;                 sta (DESTLO),Y          ; to p/m area
;                 iny
;                 sta (DESTLO),Y
;                 iny
;                 dex
;                 dec CPYCNT
;                 bpl SHOCOP

; NXTSHO          dec DESTNM              ; more?
;                 bmi VBEND               ;   no, exit!

;                 dec DESTHI              ; next player
;                 inc VBXHLD
;                 jmp SHORLP              ; loop back.

VBEND           ;sta HITCLR             ; clear collision

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl
                .endproc
