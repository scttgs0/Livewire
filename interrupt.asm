; ----------------------
; MAIN GAME DISPLAY LIST
; ----------------------

;DLIST          ;.byte AEMPTY8
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

;TITLDL         ;.byte AEMPTY8,AEMPTY8,AEMPTY8,AEMPTY8
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
;CONTRL         ;    .addr JoyMsg
                ;.byte AVB+AJMP
                ;    .addr TITLDL


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HandleIrq       .m16i16
                pha
                phx
                phy

                .m8i8
                lda @l INT_PENDING_REG1
                and #FNX1_INT00_KBD
                cmp #FNX1_INT00_KBD
                bne _1

                jsl KeyboardHandler

                lda @l INT_PENDING_REG1
                sta @l INT_PENDING_REG1

_1              lda @l INT_PENDING_REG0
                and #FNX0_INT00_SOF
                cmp #FNX0_INT00_SOF
                bne _XIT

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
; DISPLAY LIST INTERRUPTS - TAIL
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

;----------------
; SCREEN MESSAGES
;----------------

INFOLN          .text '          LVL   '
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

                cld                     ; clr decimal mode

                .m8i8
                .setbank $00

                lda JIFFYCLOCK
                inc A
                sta JIFFYCLOCK

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

                jmp VBEND               ; exit if intro

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

                lda #0                  ; turn off
                sta SID_CTRL1           ; all sounds
                sta SID_CTRL2           ; during
                sta SID_CTRL3           ; the
                ;sta AUDC4              ; pause
                jmp VBEND               ; then exit

NOPAU           lda FIRSOU              ; fire sound on?
                beq NOFSND              ; no!

                dec FIRSOU              ; dec counter
                ldx FIRSOU              ; put in index
                lda FIRFRQ,X            ; get frequency
                sta SID_FREQ2
                lda FIRCTL,X            ; get control
                sta SID_CTRL2
NOFSND          lda OBDSOU              ; obj death sound?
                beq NOOSND              ; no!

                dec OBDSOU              ; dec counter
                ldx OBDSOU              ; put in index
                lda OBDFRQ,X            ; get frequency
                sta SID_FREQ3
                lda OBDCTL,X            ; get control
                sta SID_CTRL3
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
                .randomByte
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

RDSTRG          lda InputFlags          ; get stick trigger
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

                ldx InputFlags          ; get stick
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

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl                     ; VBI done! (whew!)
                .endproc
