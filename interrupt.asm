
; SPDX-FileName: interrupt.asm
; SPDX-FileCopyrightText: Copyright 2025, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Main IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqMain         .proc
                pha
                phx
                phy

                cld

; - - - - - - - - - - - - - - - - - - -
;   switch to system map
                lda IOPAGE_CTRL
                pha                     ; preserve
                stz IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ; lda INT_PENDING_REG1
                ; bit #INT01_VIA1
                ; beq _1

                ; lda INT_PENDING_REG1
                ; sta INT_PENDING_REG1

                ; jsr KeyboardHandler

_1              lda INT_PENDING_REG0
                bit #INT00_SOF
                beq _XIT

                lda INT_PENDING_REG0
                sta INT_PENDING_REG0

                jsr irqVBIHandler

; - - - - - - - - - - - - - - - - - - -
_XIT            pla                     ; restore
                sta IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ply
                plx
                pla

irqMain_END     ;jmp IRQ_PRIOR
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Key Notifications
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

                pha
                phx
                phy

                lda PS2_KEYBD_IN
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

; - - - - - - - - - - - - - - - - - - -
_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                bit #joyUP
                beq _4a

                eor #joyUP
                ora #joyDOWN            ; cancel KEY_DOWN
                sta InputFlags

_4a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #joyUP
                sta InputFlags

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                bit #joyDOWN
                beq _5a

                eor #joyDOWN
                ora #joyUP              ; cancel KEY_UP
                sta InputFlags

_5a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #joyDOWN
                sta InputFlags

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                bit #joyLEFT
                beq _6a

                eor #joyLEFT
                ora #joyRIGHT           ; cancel KEY_RIGHT
                sta InputFlags

_6a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #joyLEFT
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                bit #joyRIGHT
                beq _7a

                eor #joyRIGHT
                ora #joyLEFT            ; cancel KEY_LEFT
                sta InputFlags

_7a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #joyRIGHT
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #joyButton0
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #joyButton0
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     stz KEYCHAR
                pla

_XIT            ply
                plx
                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DISPLAY LIST INTERRUPTS - HEAD
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI1  .proc
                ;!!pha                     ; save accum

                ;!!lda GRAC1              ; get gr. ctrl [0,3]
                ;!!sta WSYNC              ; wait for sync
                ;!!sta GRACTL             ; store it

                ;!!lda DMAC1              ; get and save
                ;!!sta DMACTL             ; DMA ctrl

                ;!!lda #<Interrupt_DLI2   ; point...
                ;!!sta VDSLST             ; to...
                ;!!lda #>Interrupt_DLI2   ; next...
                ;!!sta VDSLST+1           ; DLI!

                ;!!pla                     ; get accum
                rti                     ; and exit!
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; DISPLAY LIST INTERRUPTS - TAIL
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_DLI2  .proc
                ;!!pha                     ; save accum
                ;!!.m16

                ;!!lda #$e4e4              ; get white
                ;!!sta PfColor0            ; put in color 0
                ;!!lda #$00e4
                ;!!sta PfColor0+2

                ;!!lda #$4cdc              ; put blue...
                ;!!sta PfColor1            ; in color 1
                ;!!lda #$0044
                ;!!sta PfColor1+2

                ;!!lda #$982c              ; put orange...
                ;!!sta PfColor2            ; in color 2
                ;!!lda #$00fc
                ;!!sta PfColor2+2

                ;!!.m8
                ;!!pla                     ; get accum.
                rti                     ; and exit
                .endproc


;--------------------------------------

;----------------
; SCREEN MESSAGES
;----------------

INFOLN          .text '000000 00 LVL 01'

InfoLineColor   .byte $10,$10,$10,$10,$10,$10
                .byte $00
                .byte $20,$20
                .byte $00
                .byte $30,$30,$30
                .byte $00
                .byte $30,$30

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
; Vertical Blank Interrupt (SOF)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqVBIHandler   .proc
                pha
                phx
                phy

                inc JIFFYCLOCK          ; increment the jiffy clock each VBI

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

_2              ;!!lda #<Interrupt_DLI1   ; point to
                ;!!sta VDSLST             ; first
                ;!!lda #>Interrupt_DLI1   ; display list
                ;!!sta VDSLST+1           ; interrupt

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
                jmp _VBcont             ; skip player stuff

_6              lda isIntro             ; in intro?
                beq _7                  ;   no, continue!
                jmp _VBend               ; exit if intro

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
                sta SID1_CTRL1          ; all sounds
                sta SID1_CTRL2          ; during
                sta SID1_CTRL3          ; the
                sta SID2_CTRL1          ; pause

                jmp _VBend               ; then exit

_notPaused      lda FIRSOU              ; fire sound on?
                beq _10                 ;   no!

                dec FIRSOU              ; dec counter
                ldx FIRSOU              ; put in index
                lda FIRFRQ,X            ; get frequency
                sta SID1_FREQ2
                lda FIRCTL,X            ; get control
                sta SID1_CTRL2

_10             lda OBDSOU              ; obj death sound?
                beq _11                 ;   no!

                dec OBDSOU              ; dec counter
                ldx OBDSOU              ; put in index
                lda OBDFRQ,X            ; get frequency
                sta SID1_FREQ3
                lda OBDCTL,X            ; get control
                sta SID1_CTRL3

_11             lda MOVSOU              ; move sound?
                beq _12                 ;   no!

                dec MOVSOU              ; dec counter
                ldx MOVSOU              ; put in index
                lda MOVFRQ,X            ; get frequency
                sta SID2_FREQ1
                lda MOVCTL,X            ; get control
                sta SID2_CTRL1

_12             ;!!lda COLPM2              ; cycle player 2 color
                ;!!clc
                ;!!adc #16
                ;!!sta COLPM2              ; save in p/m 2
                ;!!sta COLPM3              ; and in p/m 3
                ;!!and #$FC                ; also put in pf3 for missiles
                ;!!sta COLPF3

;   transient processing
                dec TransientTmr        ; transient time
                bne _15                 ;   no change

                lda OBJHUE+4            ; flip transient
                bne _13

                lda #2                  ; hue to either
                bne _14

_13             lda #0                  ; 0 or 2
_14             sta OBJHUE+4

                .frsRandomByte
                ora #$1F                ; reset the transient time
                and #$3F
                sta TransientTmr

;   player processing
_15             inc playerShapeTmr      ; inc player timer
                lda playerShapeTmr      ; ready to change shape?
                cmp #3
                bne _16                 ;   not yet!

                stz playerShapeTmr      ; better reset index

                inc idxSPoint1          ; and increment all shape indexes!
                inc idxSPoint2
                inc idxSPoint3

_16             lda playerShootTmr      ; check if player is shooting
                beq _17

                dec playerShootTmr
                bra _chkPlyrMove

_17             lda #4                  ; reset fire timer
                sta playerShootTmr

                lda JOYPAD              ; using stick?
                beq _readTrigger        ;   yes!

                ;!!lda PTRIG0             ; get padl trigger
                ;!!jmp _cmpTrigger        ; check it

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

                lda #21                 ; start up
                sta FIRSOU              ; fire sound

                lda #0                  ; initialize segment # to 0
                sta PROJSG,X

                lda playerGridPos       ; set up proj grid #
                sta ProjGridPos,X
                asl                     ; *16
                asl
                asl
                asl
                sta ProjGridIndex,X     ; for index

                lda #1                  ; initialize proj increment
                sta ProjIncrement,X

_chkPlyrMove    lda JOYPAD              ; using stick?
                beq _goStick            ;   yes!

                ;!!lda POT0                ; get paddle
                ;!!lsr                     ; divide by
                ;!!lsr                     ; 16 to get
                ;!!lsr                     ; usable value
                ;!!lsr
                ;!!cmp #15                 ; > 14?
                ;!!bmi _storePos           ;   no, go store

                ;!!lda #14                 ; max. is 14
                ;!!bne _storePos           ; and go store

_goStick        lda playerMoveTmr       ; ready for stick?
                beq _readStick          ;   yes!

                dec playerMoveTmr       ; dec timer
                jmp _VBcont             ; jmp to continue

_readStick      lda #3                  ; reset stick timer
                sta playerMoveTmr       ; to 3 jiffies

                lda InputFlags          ; get stick
                and #$0F
                tax

                lda playerGridPos       ; get plyr grid #
                clc                     ; add the
                adc DeflectionValue,X   ; direction inc
                bmi _samePos            ; if <0.. reject

                cmp #15                 ; if <15.. use it!
                bne _storePos

_samePos        lda playerGridPos       ; get grid #
_storePos       cmp playerGridPos       ; same as last?
                beq _noStore            ;   yes, don't store

                ldx #9                  ; start up
                stx MOVSOU              ; move sound

                sta playerGridPos       ; save grid #

_noStore        asl                     ; *16 (position index)
                asl
                asl
                asl
                tax

                ;!!lda P0PL
                ;!!and #$0C               ; hit p2/p3?
                ;!!beq _noHitShort        ;   no!

                ;!!lda #TRUE               ; oops! hit short!
                ;!!sta isPlayerDead        ; kill player
                ;!!jmp _VBend              ; and exit vblank

_noHitShort     lda SEGX,X              ; get player's
                ;!! .m16
                ;!! and #$FF
                asl                     ; *2
                clc                     ; x position and
                adc #61                 ; adjust for p/m
                sta SPR(sprite_t.X, 0)  ; and save
                ;!! .m8

;   [DEBUG] $2469
                ldy playerYPos          ; hold old y pos

                lda SEGY,X              ; get new y pos
                clc                     ; adjust for p/m
                adc #32                 ; by adding 32
                sta playerYPos          ; set y pos

;   create the animated player sprite
                lda #0                  ; clear out old player image
                ldx #15
_clrPS          sta tblPlayerAnimFrame,X

                dex
                bpl _clrPS

;   generate the new animated player frame
                lda #15                 ; copy 16-byte
                sta idxStartPoint

_startPointLoop lda #0                  ; player image to player 0
                sta playerTempByte      ; composite work area

                lda idxSPoint1
                and #15                 ; clamp to [0:15]
                tax
                lda idxStartPoint
                cmp tblStartPoint,X     ; draw this scanline?
                bcc _skipSP1            ;   no

                cmp tblEndPoint,X       ; draw this scanline?
                bcs _skipSP1            ;   no

                tax
                lda imgPlayerNS,X       ; get image 1 and save
                sta playerTempByte      ; composite work area

_skipSP1        lda idxSPoint2
                and #15                 ; clamp to [0:15]
                tax
                lda idxStartPoint
                cmp tblStartPoint,X     ; draw this scanline?
                bcc _skipSP2            ;   no

                cmp tblEndPoint,X       ; draw this scanline?
                bcs _skipSP2            ;   no

                tax
                lda imgPlayerNWSE,X
                ora playerTempByte      ; merge image 2 and save
                sta playerTempByte

_skipSP2        lda idxSPoint3
                and #15                 ; clamp to [0:15]
                tax
                lda idxStartPoint
                cmp tblStartPoint,X     ; draw this scanline?
                bcc _skipSP3            ;   no

                cmp tblEndPoint,X       ; draw this scanline?
                bcs _skipSP3            ;   no

                tax
                lda imgPlayerNESW,X
                ora playerTempByte      ; merge image 3 and save
                sta playerTempByte

_skipSP3        lda playerYPos
                ;clc
                ;adc idxStartPoint
                ;sec
                ;sbc #16
                ;clc
                ;adc #32
                sta SPR(sprite_t.Y, 0)

                ldy idxStartPoint
                lda playerTempByte          ; get image byte
                sta tblPlayerAnimFrame,Y    ; put in p/m area

                dec idxStartPoint       ; more image?
                bpl _startPointLoop     ;   yes!

                lda #TRUE
                sta isDirtyPlayer

_VBcont         lda ProjAdvToggle       ; advance proj?
                beq _setProjAdv         ;   yes!

                dec ProjAdvToggle       ;   no, dec timer
                bra _missiles           ; go flip display

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

_missiles       inc PRFLIP              ; inc flip index
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
                lsr
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
                asl                     ; *2
                ldy SEGY,X
                clc                     ; add 64 to x coord for p/m horiz
                adc #64

;   now draw projectile in new position
                pha
                lda MISNUM
                asl                     ; *8
                asl
                asl
                tax
                pla
                ;!!.frsSpriteSetX_ix
                ;!!sta SPR(sprite_t.X, 12),X ; and save

                phx
                ldx MISNUM
                tya                     ; get y
                clc                     ; add 32 to y coord for p/m vert
                adc #56
                tay
                sty PRYHLD,X            ; and save.
                plx
                ;!!sta SPR(sprite_t.Y, 12),X

_chkProjEnd     dec MISNUM              ; next missile #
                dec VBXHLD              ; next proj.
                ldx VBXHLD
                cpx ENDVAL              ; done?
                beq _Shorts             ;   yes!

                jmp _projLoop           ; do next proj.

_killProj       lda #FALSE              ; kill proj.
                sta isProjActive,X

                phx
                txa
                asl                     ; *8
                asl
                asl
                tax
                lda #0                  ; hide the sprite
                ;!!.frsSpriteSetX_ix
                ;!!sta SPR(sprite_t.X, 12),X
                ;!!.frsSpriteSetY_ix
                ;!!sta SPR(sprite_t.Y, 12),X
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
                cmp playerGridPos
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

_Shorts         inc SHFLIP              ; toggle flip
                lda SHFLIP              ; mask flip to either 0 or 1
                lsr
                and #1
                tay
                lda ShortStartIdx,Y     ; and get image to use (+/x)
                sta CPYST

                lda SHFLIP              ; get flip, mask
                and #1
                tay

                lda #>SHORT_WK3         ; put short 3 in destination address
                sta DESTHI
                lda #<SHORT_WK3
                sta DESTLO

                lda #1                  ; set dest #
                sta DESTNM

                lda ShortStart,Y        ; get start short #
                sta VBXHLD

_shortLoop      lda #0
                ldx DESTNM
                ldy ShortHoldY,X        ; get last index

                ldx #9
_eraseShort     sta (DESTLO),Y          ; erase previous short
                iny
                dex
                bpl _eraseShort

                ldx VBXHLD
                lda SHORTF,X            ; short alive?
                beq _nextShort          ;   no!

                lda SHORTX,X            ; get index of short's pos.
                tax
                lda RIMX,X              ; get x coord and y coord
                ldy RIMY,X
                clc
                adc #62                 ; adjust x

                pha
                lda DESTNM              ; get player #
                asl                     ; *8
                asl
                asl
                tax
                pla
                ;!!.frsSpriteSetX_ix
                ;!!sta SPR(sprite_t.X, 2),X ; and store
                tya
                clc
                adc #28                 ; adjust y
                ldx DESTNM
                sta ShortHoldY,X        ; save it
                tay

                ldx CPYST
                lda #4
                sta CPYCNT
_shortCopy      lda ShortImage,X        ; now copy short image
                sta (DESTLO),Y          ; to p/m area
                iny
                sta (DESTLO),Y
                iny
                dex
                dec CPYCNT
                bpl _shortCopy

_nextShort      dec DESTNM              ; more?
                bmi _VBend              ;   no, exit!

                dec DESTHI              ; next player
                inc VBXHLD
                jmp _shortLoop          ; loop back.

_VBend          ;!! TODO: blit to SP02+
                ;!!sta HITCLR             ; clear collision

_XIT            ply
                plx
                pla
                rts
                .endproc
