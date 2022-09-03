VRAM            = $B00000               ; First byte of video RAM

SPRITES         = VRAM

BITMAP          = VRAM+$2000
BITMAP0         = $2000+$1E00
BITMAP1         = BITMAP0+$1E00
BITMAP2         = BITMAP1+$1E00
BITMAP3         = BITMAP2+$1E00
BITMAP4         = BITMAP3+$1E00
BITMAP5         = BITMAP4+$1E00
BITMAP6         = BITMAP5+$1E00
BITMAP7         = BITMAP6+$1E00


;======================================
; seed = elapsed seconds this hour
;======================================
Random_Seed     .proc
                .m8
                lda RTC_MIN
                sta RND_MIN
                lda RTC_SEC
                sta RND_SEC

                .m16
;   elapsed minutes * 60
                lda RND_MIN
                asl A
                asl A
                pha
                asl A
                pha
                asl A
                pha
                asl A
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

;   + elapsed seconds
                lda RND_SEC
                adc RND_RESULT

                sta GABE_RNG_SEED_LO

                .m8
                lda #grcEnable|grcDV
                sta GABE_RNG_CTRL
                lda #grcEnable
                sta GABE_RNG_CTRL
                .endproc


;======================================
; Initialize SID
;======================================
InitSID         .proc
                pha
                phx
                .m8i8

;   reset the SID
                lda #$00
                ldx #$18
_next1          sta $AF_E400,X
                dex
                bpl _next1

                lda #$09                ; Attack/Decay = 9
                sta SID_ATDCY1
                sta SID_ATDCY2
                sta SID_ATDCY3

                lda #$00                ; Susatain/Release = 0
                sta SID_SUREL1
                sta SID_SUREL2
                sta SID_SUREL3

                ;lda #$21
                ;sta SID_CTRL1
                ;sta SID_CTRL2
                ;sta SID_CTRL3

                lda #$0F                ; Volume = 15 (max)
                sta SID_SIGVOL

                plx
                pla
                rts
                .endproc


;======================================
; Create the lookup table (LUT)
;======================================
InitLUT         .proc
                php
                phb                     ; required for mvn
                pha
                phx
                phy

                .m16i16
                lda #Palette_end-Palette ; Copy the palette to LUT0
                ldx #<>Palette
                ldy #<>GRPH_LUT0_PTR
                mvn `Palette,`GRPH_LUT0_PTR

                .m8i8
                ply
                plx
                pla
                plb
                plp
                rts
                .endproc


;======================================
; Initialize the CHAR_LUT tables
;======================================
InitCharLUT     .proc
v_LUTSize       .var 64                 ; 4-byte color * 16 colors
;---

                pha
                phx
                .m8i8

                ldx #$00
_next1          lda Custom_LUT,x
                sta FG_CHAR_LUT_PTR,x
                sta BG_CHAR_LUT_PTR,x

                inx
                cpx #v_LUTSize
                bne _next1

                plx
                pla
                rts

;--------------------------------------

Custom_LUT      .dword $00282828        ; 0: Dark Jungle Green  
                .dword $00DDDDDD        ; 1: Gainsboro          
                .dword $00fc901c        ; 2: Orange
                .dword $00082cc8        ; 3: Blue Gray          
                .dword $00693972        ; 4: Indigo             
                .dword $00B561C2        ; 5: Deep Fuchsia       
                .dword $0076ADEB        ; 6: Maya Blue          
                .dword $007A7990        ; 7: Fern Green         
                .dword $0074D169        ; 8: Moss Green         
                .dword $00D5CD6B        ; 9: Medium Spring Bud  
                .dword $00C563BD        ; A: Pastel Violet      
                .dword $005B8B46        ; B: Han Blue           
                .dword $00BC605E        ; C: Medium Carmine     
                .dword $00C9A765        ; D: Satin Sheen Gold   
                .dword $0062C36B        ; E: Mantis Green       
                .dword $00BC605E        ; F: Medium Carmine     

                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;======================================
InitSprites     .proc
                php
                pha

                .m16i16
                lda #Stamps_end-Stamps  ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>Stamps           ; Set the source address
                sta zpSource
                lda #`Stamps
                sta zpSource+2

                lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta zpDest
                sta SP00_ADDR           ; And set the Vicky register

                clc
                adc #$400               ; 1024
                sta SP12_ADDR           ; projectiles
                sta SP13_ADDR
                sta SP14_ADDR
                sta SP15_ADDR
                sta SP16_ADDR
                sta SP17_ADDR
                sta SP18_ADDR
                sta SP19_ADDR

                ;clc
                ;adc #$1000              ; 1024*4
                ;sta SP02_ADDR

                lda #`(SPRITES-VRAM)
                sta zpDest+2

                .m8
                sta SP00_ADDR+2         ; player

                ;sta SP01_ADDR+2
                ;sta SP02_ADDR+2

                sta SP12_ADDR+2         ; projectiles
                sta SP13_ADDR+2
                sta SP14_ADDR+2
                sta SP15_ADDR+2
                sta SP16_ADDR+2
                sta SP17_ADDR+2
                sta SP18_ADDR+2
                sta SP19_ADDR+2

                jsr Copy2VRAM

                .m16
                lda #0
                sta SP00_X_POS          ; player
                sta SP00_Y_POS

                ;sta SP01_X_POS
                ;sta SP01_Y_POS
                ;sta SP02_X_POS
                ;sta SP02_Y_POS

                sta SP12_X_POS          ; projectiles
                sta SP12_Y_POS
                sta SP13_X_POS
                sta SP13_Y_POS
                sta SP14_X_POS
                sta SP14_Y_POS
                sta SP15_X_POS
                sta SP15_Y_POS
                sta SP16_X_POS
                sta SP16_Y_POS
                sta SP17_X_POS
                sta SP17_Y_POS
                sta SP18_X_POS
                sta SP18_Y_POS
                sta SP19_X_POS
                sta SP19_Y_POS

                .m8
                lda #scEnable
                sta SP00_CTRL           ; player

                ;sta SP01_CTRL
                ;sta SP02_CTRL

                sta SP12_CTRL           ; projectiles
                sta SP13_CTRL
                sta SP14_CTRL
                sta SP15_CTRL
                sta SP16_CTRL
                sta SP17_CTRL
                sta SP18_CTRL
                sta SP19_CTRL

                pla
                plp
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

                .m16
                lda #<>PlyrAnimFrame    ; Set the source address
                sta zpSource
                lda #`PlyrAnimFrame
                sta zpSource+2

                lda #<>SPR_PLAYER       ; Set the destination address
                sta zpDest
                lda #`SPR_PLAYER
                sta zpDest+2
                .m8

                .i16
                ldx #0
                stx zpIndex1            ; source offset         [0-960]
                stx zpIndex2            ; destination offset    [0-7680]
                stx zpIndex3            ; column offset         [0-39]

_nextByte       ldy zpIndex1
                lda [zpSource],Y

                inc zpIndex1            ; increment the byte counter (source pointer)

                ldx #7
_nextPixel      stz zpTemp1             ; extract 1-bit pixel
                asl A
                rol zpTemp1
                beq _skipColor

                ldy #$09                ; change #1 to #9 for colored pixel
                sty zpTemp1

_skipColor      pha

                lda zpTemp1
                ldy zpIndex2
                sta [zpDest],Y
                iny
                sty zpIndex2
                pla

                dex
                bpl _nextPixel

                .m16
                lda zpIndex2            ; advance to next line
                clc
                adc #24
                sta zpIndex2
                .m8

_checkEnd       ldx zpIndex1
                cpx #16
                bcc _nextByte

_XIT            .i8

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

                .m16

                lda #$0400
                sta zpSize
                lda #0
                sta zpSize+2

                lda #<>SPR_PLAYER       ; Set the source address
                sta zpSource
                lda #`SPR_PLAYER
                sta zpSource+2

                lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta zpDest
                lda #`(SPRITES-VRAM)
                sta zpDest+2

                .m8
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
InitBitmap      .proc
                php
                pha

                .m16i16
                lda #$1E00              ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>Video8K          ; Set the source address
                sta zpSource
                lda #`Video8K
                sta zpSource+2

                lda #<>(BITMAP-VRAM)    ; Set the destination address
                sta zpDest
                sta BITMAP0_START_ADDR  ; And set the Vicky register

                lda #`(BITMAP-VRAM)
                sta zpDest+2

                .m8
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

                .m16
                lda #<>Video8K          ; Set the destination address
                sta zpDest
                lda #`Video8K
                sta zpDest+2
                .m8

                ;stz zpTemp2     ; HACK:

                .i16
                ldx #0
                stx zpIndex1            ; source offset         [0-960]
                stx zpIndex2            ; destination offset    [0-7680]
                stx zpIndex3            ; column offset         [0-39]

;   32 pixel border
                lda #0
                ldx #31
                ldy #0
_nextBorder     sta [zpDest],Y
                iny
                dex
                bpl _nextBorder

                sty zpIndex2

_nextByte       ldy zpIndex1
                lda [zpSource],Y

                inc zpIndex1            ; increment the byte counter (source pointer)
                bne _1

                inc zpIndex1+1
_1              inc zpIndex3            ; increment the column counter

                ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl A
                rol zpTemp1
                asl A
                rol zpTemp1
                pha

                lda zpTemp1
                ldy zpIndex2
                sta [zpDest],Y
                iny
                sta [zpDest],Y          ; double-pixel
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
_nextBorder2    sta [zpDest],Y
                iny
                dex
                bpl _nextBorder2

                sty zpIndex2

                ldx #0
                stx zpIndex3            ; reset the column counter

_checkEnd       ldx zpIndex1
                cpx #$300               ; 24 source lines (32 bytes/line)... = 24 destination lines (~8K)
                bcc _nextByte

_XIT            .i8

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

                .m16

                lda #$1E00              ; 24 lines (320 bytes/line)
                sta zpSize
                lda #0
                sta zpSize+2

                lda #<>Video8K          ; Set the source address
                sta zpSource
                lda #`Video8K
                sta zpSource+2

                .m8
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

_nextBank       .m16
                lda _data_Source,X      ; Set the source address
                sta zpSource
                lda _data_Source+2,X
                and #$FF
                sta zpSource+2
                .m8

                jsr SetVideoRam

                .m16
                lda _data_Dest,X        ; Set the destination address
                sta zpDest
                lda _data_Dest+2,X
                and #$FF
                sta zpDest+2
                .m8

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
                .m8i8

;   clear color
                lda #<CS_COLOR_MEM_PTR
                sta zpDest
                lda #>CS_COLOR_MEM_PTR
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR
                sta zpDest+2

                ldx #v_QtyPages
                lda #v_TextColor
_nextPageC      ldy #$00
_next1C         sta [zpDest],Y

                iny
                bne _next1C

                inc zpDest+1            ; advance to next memory page
                dex
                bne _nextPageC

;   clear text
                lda #<CS_TEXT_MEM_PTR
                sta zpDest
                lda #>CS_TEXT_MEM_PTR
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR
                sta zpDest+2

                ldx #v_QtyPages
                lda #v_EmptyText
_nextPageT      ldy #$00
_next1T         sta [zpDest],Y

                iny
                bne _next1T

                inc zpDest+1            ; advance to next memory page
                dex
                bne _nextPageT

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
v_RenderLine    .var 23*CharResX
;---

                php
                pha
                phy
                .m8i8

                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+2

                .i16
                lda #v_TextColor
                ldy #$00
_next1          sta [zpDest],Y

                iny
                cpy #$118                ; 7 lines
                bne _next1

                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta [zpDest],Y

                iny
                cpy #$118                ; 7 lines
                bne _next2

                .i8
                ply
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
                asl A
                asl A

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
; Render Publisher
;======================================
RenderPublisher .proc
v_RenderLine    .var 11*CharResX
;---

                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda MAGMSG,Y
                cmp #$20
                beq _space

                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         pha
                phx
                lda #$40
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderTitle     .proc
v_RenderLine    .var 13*CharResX
;---

                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda #$80
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor    .proc
v_RenderLine    .var 16*CharResX
;---

                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda AuthorMsg,Y
                cmp #$20
                beq _space

                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         pha
                phx
                lda #$70
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect    .proc
v_RenderLine    .var 19*CharResX
;---

                php
                .m8i8

                lda JOYPAD
                bne _paddle

                lda #<JoyMsg
                sta zpSource
                lda #>JoyMsg
                sta zpSource+1
                bra _1

_paddle         lda #<PadMsg
                sta zpSource
                lda #>PadMsg
                sta zpSource+1

_1              ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda (zpSource),Y
                cmp #$20
                beq _space

                bra _letter

_space          lda #$00
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         pha
                phx
                lda #$C0
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Copying data from system RAM to VRAM
;--------------------------------------
; Inputs (pushed to stack, listed top down)
;   zpSource = address of source data (should be system RAM)
;   zpDest = address of destination (should be in video RAM)
;   zpSize = number of bytes to transfer
;
; Outputs:
;   None
;======================================
Copy2VRAM       .proc
                php
                phb
                .setbank `SDMA_SRC_ADDR
                .setdp zpSource
                .m8

    ; Set SDMA to go from system to video RAM, 1D copy
                lda #sdcSysRAM_Src|sdcEnable
                sta SDMA0_CTRL

    ; Set VDMA to go from system to video RAM, 1D copy
                lda #vdcSysRAM_Src|vdcEnable
                sta VDMA_CTRL

                .m16i8
                lda zpSource            ; Set the source address
                sta SDMA_SRC_ADDR
                ldx zpSource+2
                stx SDMA_SRC_ADDR+2

                lda zpDest              ; Set the destination address
                sta VDMA_DST_ADDR
                ldx zpDest+2
                stx VDMA_DST_ADDR+2

                .m16
                lda zpSize              ; Set the size of the block
                sta SDMA_SIZE
                sta VDMA_SIZE
                lda zpSize+2
                sta SDMA_SIZE+2
                sta VDMA_SIZE+2

                .m8
                lda VDMA_CTRL           ; Start the VDMA
                ora #vdcStart_TRF
                sta VDMA_CTRL

                lda SDMA0_CTRL          ; Start the SDMA
                ora #sdcStart_TRF
                sta SDMA0_CTRL

                nop                     ; VDMA involving system RAM will stop the processor
                nop                     ; These NOPs give Vicky time to initiate the transfer and pause the processor
                nop                     ; Note: even interrupt handling will be stopped during the DMA
                nop

wait_vdma       lda VDMA_STATUS         ; Get the VDMA status
                bit #vdsSize_Err|vdsDst_Add_Err|vdsSrc_Add_Err
                bne vdma_err            ; Go to monitor if there is a VDMA error
                bit #vdsVDMA_IPS        ; Is it still in process?
                bne wait_vdma           ; Yes: keep waiting

                lda #0                  ; Make sure DMA registers are cleared
                sta SDMA0_CTRL
                sta VDMA_CTRL

                .setdp $0000
                .setbank $00
                .m8i8
                plb
                plp
                rts

vdma_err        brk
                .endproc


;======================================
;
;======================================
InitIRQs        .proc
                pha

;   enable vertical blank interrupt

                .m8i8
                ldx #HandleIrq.HandleIrq_END-HandleIrq
_relocate       ;lda @l $024000,X        ; HandleIrq address
                ;sta @l $002000,X        ; new address within Bank 00
                ;dex
                ;bpl _relocate

                sei                     ; disable IRQ

                .m16
                ;lda @l vecIRQ
                ;sta IRQ_PRIOR

                lda #<>HandleIrq
                sta @l vecIRQ

                .m8
                lda #$07                ; reset consol
                sta CONSOL

                lda #$1F
                sta InputFlags
                stz InputType           ; joystick

                lda @l INT_MASK_REG0
                and #~FNX0_INT00_SOF    ; enable Start-of-Frame IRQ
                sta @l INT_MASK_REG0

                lda @l INT_MASK_REG1
                and #~FNX1_INT00_KBD    ; enable Keyboard IRQ
                sta @l INT_MASK_REG1

                cli                     ; enable IRQ

                pla
                rts
                .endproc


;======================================
;
;======================================
SetFont         .proc
                php
                pha
                phx
                phy

                ; bra _XIT  ; DEBUG: helpful if you need to see the trace

                .m8i8
                lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1
                lda #`GameFont
                sta zpSource+2

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                lda #`FONT_MEMORY_BANK0
                sta zpDest+2

                ldx #$08                ; 8 pages
_nextPage       ldy #$00
_next1          lda [zpSource],Y
                sta [zpDest],Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc
