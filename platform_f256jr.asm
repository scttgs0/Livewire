
; SPDX-FileName: platform_f256jr.asm
; SPDX-FileCopyrightText: Copyright 2023, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
; seed = quick and dirty
;======================================
RandomSeedQuick .proc
                lda RTC_MIN
                sta RNG_SEED+1

                lda RTC_SEC
                sta RNG_SEED

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL

                rts
                .endproc


;======================================
; seed = elapsed seconds this hour
;======================================
RandomSeed      .proc
                lda RTC_MIN
                jsr Bcd2Bin
                sta RND_MIN

                lda RTC_SEC
                jsr Bcd2Bin
                sta RND_SEC

;   elapsed minutes * 60
                lda RND_MIN
                asl
                asl
                pha
                asl
                pha
                asl
                pha
                asl
                sta RND_RESULT      ; *32

                pla
                clc
                adc RND_RESULT      ; *16
                sta RND_RESULT

                pla
                clc
                adc RND_RESULT      ; *8
                sta RND_RESULT

                pla
                clc
                adc RND_RESULT      ; *4
                sta RND_RESULT

;   add the elapsed seconds
                clc
                lda RND_SEC
                adc RND_RESULT

                sta RNG_SEED_LO
                stz RNG_SEED_HI

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL

                rts
                .endproc


;======================================
; Convert BCD to Binary
;======================================
Bcd2Bin         .proc
                pha

;   upper-nibble * 10
                lsr                     ; n*8
                pha
                lsr
                lsr
                sta zpTemp1             ; n*2

                pla
                clc
                adc zpTemp1
                sta zpTemp1

;   add the lower-nibble
                pla
                and #$0F
                clc
                adc zpTemp1

                .endproc


;======================================
; Initialize SID
;======================================
InitSID         .proc
                pha
                phx

                lda #0                  ; reset the SID registers
                ldx #$1F
_next1          sta SID1_BASE,X
                sta SID2_BASE,X

                dex
                bpl _next1

                lda #$09                ; Attack/Decay = 9
                sta SID1_ATDCY1
                sta SID1_ATDCY2
                sta SID1_ATDCY3
                sta SID2_ATDCY1

                stz SID1_SUREL1         ; Susatain/Release = 0 [square wave]
                stz SID1_SUREL2
                stz SID1_SUREL3
                stz SID2_SUREL1

                ;lda #$21
                ;sta SID1_CTRL1
                ;sta SID1_CTRL2
                ;sta SID1_CTRL3
                ;sta SID2_CTRL1

                lda #$08                ; Volume = 8 (mid-range)
                sta SID1_SIGVOL
                sta SID2_SIGVOL

                plx
                pla
                rts
                .endproc


;======================================
; Initialize PSG
;======================================
InitPSG         .proc
                pha
                phx

                lda #0                  ; reset the PSG registers
                ldx #$07
_next1          sta PSG1_BASE,X
                sta PSG2_BASE,X

                dex
                bpl _next1

                plx
                pla
                rts
                .endproc


;======================================
; Initialize the text-color LUT
;======================================
InitTextPalette .proc
                pha
                phy

;   switch to system map
                stz IOPAGE_CTRL

                ldy #$3F
_next1          lda _Text_CLUT,Y
                sta FG_CHAR_LUT_PTR,Y   ; same palette for foreground and background
                sta BG_CHAR_LUT_PTR,Y

                dey
                bpl _next1

                ply
                pla
                rts

;--------------------------------------

_Text_CLUT      .dword $00282828        ; 0: Dark Jungle Green
                .dword $00DDDDDD        ; 1: Gainsboro
                .dword $00143382        ; 2: Saint Patrick Blue
                .dword $006B89D7        ; 3: Blue Gray
                .dword $00693972        ; 4: Indigo
                .dword $00B561C2        ; 5: Deep Fuchsia
                .dword $00352BB0        ; 6: Blue Pigment
                .dword $007A7990        ; 7: Fern Green
                .dword $0074D169        ; 8: Moss Green
                .dword $00E6E600        ; 9: Peridot
                .dword $00C563BD        ; A: Pastel Violet
                .dword $005B8B46        ; B: Han Blue
                .dword $00BC605E        ; C: Medium Carmine
                .dword $00C9A765        ; D: Satin Sheen Gold
                .dword $0004750E        ; E: Hookers Green
                .dword $00BC605E        ; F: Medium Carmine

                .endproc


;======================================
; Initialize the graphic-color LUT
;======================================
InitGfxPalette  .proc
                pha
                phx
                phy

;   switch to graphic map
                lda #$01
                sta IOPAGE_CTRL

                lda #<Palette
                sta zpSource
                lda #>Palette
                sta zpSource+1

                lda #<GRPH_LUT0_PTR
                sta zpDest
                lda #>GRPH_LUT0_PTR
                sta zpDest+1

                ldx #$02                ; 128 colors * 4 = 512 bytes
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;======================================
InitSprites     .proc
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   setup player sprites (sprite-00 & sprint-01)
                .frsSpriteInit SPR_PLAYER, scEnable|scLUT0|scDEPTH0|scSIZE_16, 0
                .frsSpriteInit SPR_PLAYER, scEnable|scLUT0|scDEPTH0|scSIZE_16, 1

;   setup bomb sprites (sprite-02 & sprint-03)
                .frsSpriteInit SPR_PROJECTILE, scEnable|scLUT0|scDEPTH0|scSIZE_16, 2
                .frsSpriteInit SPR_PROJECTILE, scEnable|scLUT0|scDEPTH0|scSIZE_16, 3

                ; .frsSpriteClearX 4
                ; .frsSpriteClearY 4
                ; .frsSpriteClearX 5
                ; .frsSpriteClearY 5
                ; .frsSpriteClearX 6
                ; .frsSpriteClearY 6
                ; .frsSpriteClearX 7
                ; .frsSpriteClearY 7
                ; .frsSpriteClearX 8
                ; .frsSpriteClearY 8
                ; .frsSpriteClearX 9
                ; .frsSpriteClearY 9
                ; .frsSpriteClearX 10
                ; .frsSpriteClearY 10

                ; .resetSprite SP02
                ; .resetSprite SP03
                ; .resetSprite SP04
                ; .resetSprite SP05
                ; .resetSprite SP06
                ; .resetSprite SP07
                ; .resetSprite SP08
                ; .resetSprite SP09
                ; .resetSprite SP10
                ; .resetSprite SP11
                ; .resetSprite SP12
                ; .resetSprite SP13
                ; .resetSprite SP14
                ; .resetSprite SP15
                ; .resetSprite SP16
                ; .resetSprite SP17
                ; .resetSprite SP18
                ; .resetSprite SP19

                ; lda #scEnable|scLUT0|scDEPTH0|scSIZE_16
                ; sta SP00_CTRL
                ; sta SP02_CTRL
                ; sta SP03_CTRL

                ; lda #scEnable|scLUT1|scDEPTH0|scSIZE_16
                ; sta SP01_CTRL

                pla
                rts
                .endproc


;======================================
;
;======================================
SetPlayerRam    .proc
                php
                pha
                phx
                phy

                lda #<PlyrAnimFrame    ; Set the source address
                sta zpSource
                lda #>PlyrAnimFrame    ; Set the source address
                sta zpSource+1
                lda #`PlyrAnimFrame
                sta zpSource+2

                lda #<SPR_PLAYER       ; Set the destination address
                sta zpDest
                lda #>SPR_PLAYER       ; Set the destination address
                sta zpDest+1
                lda #`SPR_PLAYER
                sta zpDest+2

                ; .i16
                ldx #0
                stx zpIndex1            ; source offset         [0-960]
                stx zpIndex2            ; destination offset    [0-7680]
                stx zpIndex3            ; column offset         [0-39]

_nextByte       ldy zpIndex1
                lda (zpSource),Y

                inc zpIndex1            ; increment the byte counter (source pointer)

                ldx #7
_nextPixel      stz zpTemp1             ; extract 1-bit pixel
                asl
                rol zpTemp1
                beq _skipColor

                ldy #$09                ; change #1 to #9 for colored pixel
                sty zpTemp1

_skipColor      pha

                lda zpTemp1
                ldy zpIndex2
                sta (zpDest),Y
                iny
                sty zpIndex2
                pla

                dex
                bpl _nextPixel

                ; .m16
                lda zpIndex2            ; advance to next line
                clc
                adc #24
                sta zpIndex2
                ; .m8

_checkEnd       ldx zpIndex1
                cpx #16
                bcc _nextByte

_XIT            ; .i8

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
BlitPlayerRam   .proc
                php
                pha

                ; .m16

                lda #<$0400
                sta zpSize
                lda #>$0400
                sta zpSize+1
                lda #0
                sta zpSize+2

                lda #<SPR_PLAYER        ; Set the source address
                sta zpSource
                lda #>SPR_PLAYER
                sta zpSource+1
                lda #`SPR_PLAYER
                sta zpSource+2

                lda #<(SPRITES-VRAM)    ; Set the destination address
                sta zpDest
                lda #>(SPRITES-VRAM)
                sta zpDest+1
                lda #`(SPRITES-VRAM)
                sta zpDest+2

                ; .m8
                jsr Copy2VRAM

                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
BlitPlayerSprite .proc
                jsr SetPlayerRam
                jsr BlitPlayerRam
                .endproc


;======================================
;
;======================================
CheckCollision  .proc
                pha
                phx
                phy

                ldx #1                  ; Given: SP02_Y=112
_nextBomb       lda zpBombDrop,X        ; A=112
                beq _nextPlayer

                cmp #132
                bcs _withinRange
                bra _nextPlayer

_withinRange    sec
                sbc #132                ; A=8
                lsr             ; /2    ; A=4
                lsr             ; /4    ; A=2
                lsr             ; /8    ; A=1
                sta zpTemp1             ; zpTemp1=1 (row)

                lda PlayerPosX,X
                lsr             ; /4
                lsr
                sta zpTemp2             ; (column)

                lda #<CANYON
                sta zpSource
                lda #>CANYON
                sta zpSource+1

                ldy zpTemp1
_nextRow        beq _checkRock
                lda zpSource
                clc
                adc #40
                sta zpSource
                bcc _1

                inc zpSource+1
_1              dey
                bra _nextRow

_checkRock      ldy zpTemp2
                lda (zpSource),Y
                beq _nextPlayer

                ;cmp #4
                ;bcs _nextPlayer

                sta P2PF,X

                stz zpTemp1
                txa
                asl
                rol zpTemp1
                tay
                lda zpSource
                stz zpTemp2+1
                clc
                adc zpTemp2
                sta P2PFaddr,Y

_nextPlayer     dex
                bpl _nextBomb

                ply
                plx
                pla
                rts
                .endproc


;======================================
;
;======================================
InitBitmap      .proc
                php
                pha

                ; .m16i16
                lda #<$1E00             ; Set the size
                sta zpSize
                lda #>$1E00
                sta zpSize+1
                lda #$00
                sta zpSize+2

                lda #<Video8K           ; Set the source address
                sta zpSource
                lda #>Video8K
                sta zpSource+1
                lda #`Video8K
                sta zpSource+2

                lda #<(BITMAP-VRAM)     ; Set the destination address
                sta zpDest
                lda #>(BITMAP-VRAM)
                sta zpDest+1
                sta BITMAP0_START_ADDR  ; And set the Vicky register

                lda #`(BITMAP-VRAM)
                sta zpDest+2

                ; .m8
                sta BITMAP0_START_ADDR+2

                jsr Copy2VRAM

                lda #bmcEnable
                sta BITMAP0_CTRL

                pla
                plp
                rts
                .endproc


;======================================
; Unpack the playfield into Video RAM
;======================================
SetVideoRam     .proc
                php
                pha
                phx
                phy

                lda #<Video8K           ; Set the destination address
                sta zpDest
                lda #>Video8K
                sta zpDest+1
                lda #`Video8K
                sta zpDest+2

                ;stz zpTemp2     ; HACK:

                ; .i16
                ldx #0
                stx zpIndex1            ; source offset         [0-960]
                stx zpIndex2            ; destination offset    [0-7680]
                stx zpIndex3            ; column offset         [0-39]

;   32 pixel border
                lda #0
                ldx #31
                ldy #0
_nextBorder     sta (zpDest),Y
                iny
                dex
                bpl _nextBorder

                sty zpIndex2

_nextByte       ldy zpIndex1
                lda (zpSource),Y

                inc zpIndex1            ; increment the byte counter (source pointer)
                bne _1

                inc zpIndex1+1
_1              inc zpIndex3            ; increment the column counter

                ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl
                rol zpTemp1
                asl
                rol zpTemp1
                pha

                lda zpTemp1
                ldy zpIndex2
                sta (zpDest),Y
                iny
                sta (zpDest),Y          ; double-pixel
                iny
                sty zpIndex2
                pla

                dex
                bpl _nextPixel

                ldx zpIndex3
                cpx #32
                bcc _checkEnd

                ;inc zpTemp2     ; HACK: exit criterian
                ;lda zpTemp2
                ;cmp #24
                ;beq _XIT

;   32 pixel border (x2)
                lda #0
                ldx #63                 ; 32-byte right-edge border & 32-bytes left-edge border
                ldy zpIndex2
_nextBorder2    sta (zpDest),Y
                iny
                dex
                bpl _nextBorder2

                sty zpIndex2

                ldx #0
                stx zpIndex3            ; reset the column counter

_checkEnd       ldx zpIndex1
                cpx #$300               ; 24 source lines (32 bytes/line)... = 24 destination lines (~8K)
                bcc _nextByte

_XIT            ; .i8

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
BlitVideoRam    .proc
                php
                pha

                lda #<$1E00             ; 24 lines (320 bytes/line)
                sta zpSize
                lda #>$1E00
                sta zpSize+1
                lda #0
                sta zpSize+2

                lda #<Video8K           ; Set the source address
                sta zpSource
                lda #>Video8K
                sta zpSource+1
                lda #`Video8K
                sta zpSource+2

                jsr Copy2VRAM

                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
BlitPlayfield   .proc
                php
                pha
                phx
                phy

                ldy #6                  ; 7 chuncks of 24 lines
                ldx #0

_nextBank       ; .m16
                lda _data_Source,X      ; Set the source address
                sta zpSource
                lda _data_Source+2,X
                and #$FF
                sta zpSource+2
                ; .m8

                jsr SetVideoRam

                ; .m16
                lda _data_Dest,X        ; Set the destination address
                sta zpDest
                lda _data_Dest+2,X
                and #$FF
                sta zpDest+2
                ; .m8

                phx
                phy
                jsr BlitVideoRam
                ply
                plx

                inx
                inx
                inx
                dey
                bpl _nextBank

                ply
                plx
                pla
                plp
                rts

;--------------------------------------

_data_Source    .long Playfield+$0000,Playfield+$0300
                .long Playfield+$0600,Playfield+$0900
                .long Playfield+$0C00,Playfield+$0F00
                .long Playfield+$1200

_data_Dest      .long BITMAP0,BITMAP1
                .long BITMAP2,BITMAP3
                .long BITMAP4,BITMAP5
                .long BITMAP6,BITMAP7

                .endproc


;======================================
; Clear the play area of the screen
;======================================
ClearScreen     .proc
v_QtyPages      .var $04                ; 40x30 = $4B0... 4 pages + 176 bytes
                                        ; remaining 176 bytes cleared via ClearGamePanel

v_EmptyText     .var $00
v_TextColor     .var $40
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   clear color
                lda #<CS_COLOR_MEM_PTR
                sta zpDest
                lda #>CS_COLOR_MEM_PTR
                sta zpDest+1
                stz zpDest+2

                ldx #v_QtyPages
                lda #v_TextColor
_nextPageC      ldy #$00
_nextByteC      sta (zpDest),Y

                iny
                bne _nextByteC

                inc zpDest+1            ; advance to next memory page

                dex
                bne _nextPageC

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

;   clear text
                lda #<CS_TEXT_MEM_PTR
                sta zpDest
                lda #>CS_TEXT_MEM_PTR
                sta zpDest+1

                ldx #v_QtyPages
                lda #v_EmptyText
_nextPageT      ldy #$00
_nextByteT      sta (zpDest),Y

                iny
                bne _nextByteT

                inc zpDest+1            ; advance to next memory page

                dex
                bne _nextPageT

;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Clear the bottom of the screen
;======================================
ClearGamePanel  .proc
v_EmptyText     .var $00
v_TextColor     .var $40
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   text color
                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1
                stz zpDest+2

                lda #v_TextColor
                ldy #$00
_next1          sta (zpDest),Y

                iny
                cpy #$F0                ; 6 lines
                bne _next1

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+1
                stz zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta (zpDest),Y

                iny
                cpy #$F0                ; 6 lines
                bne _next2

;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Game Panel
;======================================
RenderGamePanel .proc
v_RenderLine    .var 23*CharResX+4
;---

                php
                pha
                phx
                phy

                lda isIntro
                beq _cont

                jmp _XIT

;   reset color for the 40-char line
_cont           ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$10
                beq _processText

                lda InfoLineColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_COLOR_MEM_PTR+v_RenderLine+40,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_COLOR_MEM_PTR+v_RenderLine+40,X
                bra _nextColor

;   process the text
_processText    ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$10
                beq _XIT

                lda INFOLN,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine+40,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine+40,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                phx
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                plx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine+40,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine+40,X
                bra _nextChar

_letter         cmp #$56
                beq _V

                lda #$D4
                bra _1

_V              lda #$DC

_1              sta CS_TEXT_MEM_PTR+v_RenderLine,X
                phx
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                plx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine+40,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine+40,X

                bra _nextChar

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render High Score
;======================================
RenderHiScore   .proc
v_RenderLine    .var 2*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda HighScoreColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda HighScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render High Score
;======================================
RenderHiScore2  .proc
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda HighScoreColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda HighScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Publisher
;======================================
RenderPublisher .proc
                .endproc


;======================================
; Render Title
;======================================
RenderTitle     .proc
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for two 40-char lines
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$50
                beq _processText

                lda TitleMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                bra _nextColor

;   process the text
_processText
;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor    .proc
v_RenderLine    .var 26*CharResX
;---

                php

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda AuthorColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda AuthorMsg,Y
                beq _space
                cmp #$20
                beq _space

                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                plp
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect    .proc
v_RenderLine    .var 27*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda PlyrQtyColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda PlyrQtyMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderPlayers   .proc
v_RenderLine    .var 26*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda PlayersMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda PlayersMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Player Scores & Bombs
;--------------------------------------
; preserves:
;   X Y
;======================================
RenderScore     .proc
v_RenderLine    .var 27*CharResX
;---

                php
                pha
                phx
                phy

;   if game is not in progress then exit
                lda zpWaitForPlay
                bne _XIT

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda ScoreMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda ScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$9B
                beq _bomb

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_bomb           sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Canyon
;--------------------------------------
; codes $01-$03 are boulders (destructible)
; codes $84-$85 are canyon (not destructible)
;======================================
RenderCanyon    .proc
v_RenderLine    .var 13*CharResX    ; skip 13 lines
v_QtyLines      = zpTemp1
;---

                php
                pha
                phy

                lda #11             ; 11 lines
                sta v_QtyLines

                lda #<CANYON
                sta zpSource
                lda #>CANYON
                sta zpSource+1

;   pointer to text-color memory
                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1

;   pointer to text-character memory
                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+2
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+3

                ldy #40             ; 40 characters per line
_nextChar       dey
                bpl _1

                dec v_QtyLines
                beq _XIT

                ldy #40             ; reset index

                lda zpSource
                clc
                adc #40
                sta zpSource
                lda zpSource+1
                adc #0
                sta zpSource+1

                lda zpDest
                clc
                adc #40
                sta zpDest
                lda zpDest+1
                adc #0
                sta zpDest+1

                lda zpDest+2
                clc
                adc #40
                sta zpDest+2
                lda zpDest+3
                adc #0
                sta zpDest+3

_1              lda (zpSource),Y
                beq _space          ; 0 or ' ' are processed as a space
                cmp #$20
                beq _space

                cmp #$84            ; is code < $84?
                bcc _boulder

_earth          eor #$80            ; clear the high-bit (to convert the data into the ascii code)
                pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda #$E0
                sta (zpDest),Y

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                pla
                sta (zpDest+2),Y

                bra _nextChar

_space          pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda #$00
                sta (zpDest),Y

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                pla
                sta (zpDest+2),Y

                bra _nextChar

_boulder        pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                pla
                phy
                tay
                lda CanyonColors,Y
                ply
                sta (zpDest),Y

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                lda #$01
                sta (zpDest+2),Y

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                pla
                plp
                rts
                .endproc


;======================================
; Render Player Scores & Bombs
;--------------------------------------
; preserves:
;   X Y
;======================================
RenderDebug     .proc
v_RenderLine    .var 0*CharResX
;---

                php
                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda DebugMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda DebugMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$9B
                beq _bomb

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_bomb           sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
;
;======================================
InitSystemVectors .proc
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei

                cld                     ; clear decimal

                ; lda #<DefaultHandler
                ; sta vecCOP
                ; lda #>DefaultHandler
                ; sta vecCOP+1

                lda #<DefaultHandler
                sta vecABORT
                lda #>DefaultHandler
                sta vecABORT+1

                ; lda #<DefaultHandler
                ; sta vecNMI
                ; lda #>DefaultHandler
                ; sta vecNMI+1

                lda #<BOOT
                sta vecRESET
                lda #>BOOT
                sta vecRESET+1

                lda #<DefaultHandler
                sta vecIRQ_BRK
                lda #>DefaultHandler
                sta vecIRQ_BRK+1

                cli
                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Default IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DefaultHandler  rti


;======================================
;
;======================================
InitMMU         .proc
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei

;   enable page0; modify page1
                lda #mmuEditMode|mmuEditPage1|mmuPage0
                sta MMU_CTRL

                lda #$00                ; [0000:1FFF]
                sta MMU_Block0
                inc A                   ; [2000:3FFF]
                sta MMU_Block1
                inc A                   ; [4000:5FFF]
                sta MMU_Block2
                inc A                   ; [6000:7FFF]
                sta MMU_Block3
                inc A                   ; [8000:9FFF]
                sta MMU_Block4
                inc A                   ; [A000:BFFF]
                sta MMU_Block5
                inc A                   ; [C000:DFFF]
                sta MMU_Block6
                inc A                   ; [E000:FFFF]
                sta MMU_Block7

;   disable edit mode
                lda MMU_CTRL
                and #~mmuEditMode
                sta MMU_CTRL

                cli
                pla
                rts
                .endproc


;======================================
;
;======================================
InitIRQs        .proc
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei                     ; disable IRQ

;   enable IRQ handler
                ;lda #<vecIRQ_BRK
                ;sta IRQ_PRIOR
                ;lda #>vecIRQ_BRK
                ;sta IRQ_PRIOR+1

                lda #<HandleIrq
                sta vecIRQ_BRK
                lda #>HandleIrq
                sta vecIRQ_BRK+1

;   initialize the console
                lda #$07
                sta CONSOL

;   initialize joystick/keyboard
                lda #$1F
                sta InputFlags
                stz InputType           ; =joystick

;   disable all IRQ
                lda #$FF
                sta INT_EDGE_REG0
                sta INT_EDGE_REG1
                sta INT_EDGE_REG2
                sta INT_MASK_REG0
                sta INT_MASK_REG1
                sta INT_MASK_REG2

;   clear pending interrupts
                lda INT_PENDING_REG0
                sta INT_PENDING_REG0
                lda INT_PENDING_REG1
                sta INT_PENDING_REG1
                lda INT_PENDING_REG2
                sta INT_PENDING_REG2

;   enable Start-of-Frame IRQ
                lda INT_MASK_REG0
                and #~INT00_SOF
                sta INT_MASK_REG0

;   enable Keyboard IRQ
                ; lda INT_MASK_REG1
                ; and #~INT01_VIA1
                ; sta INT_MASK_REG1

                cli                     ; enable IRQ
                pla
                rts
                .endproc


;======================================
;
;======================================
SetFont         .proc
                pha
                phx
                phy

;   DEBUG: helpful if you need to see the trace
                ; bra _XIT

;   switch to charset map
                lda #iopPage1
                sta IOPAGE_CTRL

;   Font #0
FONT0           lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1
                stz zpSource+2

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                stz zpDest+2

                ldx #$07                ; 7 pages
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

;   switch to system map
                stz IOPAGE_CTRL

_XIT            ply
                plx
                pla
                rts
                .endproc
