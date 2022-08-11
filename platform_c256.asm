VRAM            = $B00000               ; First byte of video RAM

TILESET         = VRAM
TILEMAP         = $B20000
TILEMAPUNITS    = $B22000
SPRITES         = $B24000
BITMAP          = $B30000
BITMAPTXT0      = $B6F200
BITMAPTXT1      = $B71A00
BITMAPTXT2      = $B74C00
BITMAPTXT3      = $B31400


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
                phb

                .m16i16
                lda #Palette_end-Palette ; Copy the palette to LUT0
                ldx #<>Palette
                ldy #<>GRPH_LUT0_PTR
                mvn `Palette,`GRPH_LUT0_PTR

                .m8i8
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

Custom_LUT      .dword $00282828        ; 0: Dark Jungle Green  [Editor Text bg]
                .dword $00DDDDDD        ; 1: Gainsboro          [Editor Text fg]
                .dword $00143382        ; 2: Saint Patrick Blue [Editor Info bg][Dialog bg]
                .dword $006B89D7        ; 3: Blue Gray          [Editor Info fg][Dialog fg]
                .dword $00693972        ; 4: Indigo             [Monitor Info bg]
                .dword $00B561C2        ; 5: Deep Fuchsia       [Monitor Info fg][Window Split]
                .dword $0076ADEB        ; 6: Maya Blue          [Reserved Word]
                .dword $007A7990        ; 7: Fern Green         [Comment]
                .dword $0074D169        ; 8: Moss Green         [Constant]
                .dword $00D5CD6B        ; 9: Medium Spring Bud  [String]
                .dword $00C563BD        ; A: Pastel Violet      [Loop Control]
                .dword $005B8B46        ; B: Han Blue           [ProcFunc Name]
                .dword $00BC605E        ; C: Medium Carmine     [Define]
                .dword $00C9A765        ; D: Satin Sheen Gold   [Type]
                .dword $0062C36B        ; E: Mantis Green       [Highlight]
                .dword $00BC605E        ; F: Medium Carmine     [Warning]

                .endproc


;======================================
; Load the tiles into VRAM
;======================================
InitTiles       .proc
                php
                phb

                .m16i16
                lda #$FFFF              ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>tiles            ; Set the source address
                sta zpSource
                lda #`tiles
                sta zpSource+2

                lda #<>(TILESET-VRAM)   ; Set the destination address
                sta zpDest
                sta TILESET0_ADDR       ; And set the Vicky register
                lda #`(TILESET-VRAM)
                sta zpDest+2
                .m8
                sta TILESET0_ADDR+2

                jsr Copy2VRAM

                ; set tileset layout to linear-vertical (16x4096)
                .m8
                lda #tclVertical
                sta TILESET0_ADDR_CFG

                plb
                plp
                rts
                .endproc


;======================================
; Initialize the Title Screen layer
;======================================
InitTitleScreen .proc
                php
                phb

                jsr RefreshTitleScreen

                .m16
                lda #<>(TILEMAP-VRAM)   ; Set the pointer to the tile map
                sta TILE3_START_ADDR
                .m8
                lda #`(TILEMAP-VRAM)
                sta TILE3_START_ADDR+2

                .m16
                lda #MAPWIDTH                ; Set the size of the tile map
                sta TILE3_X_SIZE
                lda #MAPHEIGHT
                sta TILE3_Y_SIZE

                lda #$00
                sta TILE3_WINDOW_X_POS
                sta TILE3_WINDOW_Y_POS

                .m8
                lda #tcEnable           ; Enable the tileset, LUT0
                sta TILE3_CTRL

                plb
                plp
                rts
                .endproc


;======================================
;
;======================================
RefreshTitleScreen .proc
                php
                .setbank `TitleScreenData

                .m8i16
                ldx #0
                ldy #0
_nextTile       lda TitleScreenData,Y   ; Get the tile code
                and #$7F
                sta TILEMAP,X           ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                sta TILEMAP,X

                inx                     ; move to the next tile
                iny
                cpy #MAPWIDTH*18        ; top 18 lines are graphic
                bne _nextTile

_nextGlyph      lda TitleScreenData,Y   ; Get the tile code
                ora #$80
                sta TILEMAP,X           ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                sta TILEMAP,X

                inx                     ; move to the next tile
                iny
                cpy #MAPWIDTH*MAPHEIGHT-18  ; bottom lines are text
                bne _nextGlyph

                .setbank $00
                plp
                rts
                .endproc


;======================================
; Initialize the Unit layer (troops)
;======================================
InitUnitOverlay .proc
                php

                jsr RefreshUnitOverlay

                .m16
                lda #<>(TILEMAPUNITS-VRAM)   ; Set the pointer to the tile map
                sta TILE2_START_ADDR
                .m8
                lda #`(TILEMAPUNITS-VRAM)
                sta TILE2_START_ADDR+2

                .m16
                lda #MAPWIDTH           ; Set the size of the tile map
                sta TILE2_X_SIZE
                lda #MAPHEIGHT
                sta TILE2_Y_SIZE

                lda #$00
                sta TILE2_WINDOW_X_POS
                sta TILE2_WINDOW_Y_POS

                .m8
                lda #tcEnable           ; Enable the tileset, LUT0
                sta TILE2_CTRL

                plp
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;======================================
InitSprites     .proc
                php
                phb

                .m16i16
                lda #$1800              ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>PLYR0            ; Set the source address
                sta zpSource
                lda #`PLYR0
                sta zpSource+2

                lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta zpDest
                sta SP00_ADDR           ; And set the Vicky register
                clc
                adc #$400               ; 1024
                sta SP01_ADDR
                clc
                adc #$1000              ; 1024*4
                sta SP02_ADDR

                lda #`(SPRITES-VRAM)
                sta zpDest+2

                .m8
                sta SP00_ADDR+2
                sta SP01_ADDR+2
                sta SP02_ADDR+2

                jsr Copy2VRAM

                .m16
                lda #$00
                sta SP00_X_POS
                sta SP00_Y_POS
                sta SP01_X_POS
                sta SP01_Y_POS
                sta SP02_X_POS
                sta SP02_Y_POS

                .m8
                lda #scEnable
                sta SP00_CTRL
                sta SP01_CTRL
                sta SP02_CTRL

                plb
                plp
                rts
                .endproc


;======================================
;
;======================================
InitBitmap      .proc
                php
                phb

                .m16i16
                lda #$B000              ; Set the size
                sta zpSize
                lda #$04
                sta zpSize+2

                lda #<>HeaderPanel      ; Set the source address
                sta zpSource
                lda #`HeaderPanel
                sta zpSource+2

                lda #<>(BITMAP-VRAM)   ; Set the destination address
                sta zpDest
                sta BITMAP0_START_ADDR ; And set the Vicky register

                lda #`(BITMAP-VRAM)
                sta zpDest+2

                .m8
                sta BITMAP0_START_ADDR+2

                jsr Copy2VRAM

                lda #bmcEnable
                sta BITMAP0_CTRL

                plb
                plp
                rts
                .endproc


;======================================
; Clear the play area of the screen
;======================================
ClearScreen     .proc
v_QtyPages      .var $05                ; 40x30 = $4B0... 4 pages + 176 bytes
                                        ; remaining 176 bytes cleared via ClearGamePanel

v_EmptyText     .var $00
v_TextColor     .var $40
;---

                php
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

                plp
                rts
                .endproc


;======================================
; Clear the bottom of the screen
;======================================
ClearGamePanel  .proc
v_EmptyText     .var $00
v_TextColor     .var $40
;---

                php
                .m8i8

                lda #<CS_COLOR_MEM_PTR+24*CharResX
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+24*CharResX
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR+24*CharResX
                sta zpDest+2

                lda #v_TextColor
                ldy #$00
_next1          sta [zpDest],Y

                iny
                cpy #$F0                ; 6 lines
                bne _next1

                lda #<CS_TEXT_MEM_PTR+24*CharResX
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+24*CharResX
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR+24*CharResX
                sta zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta [zpDest],Y

                iny
                cpy #$F0                ; 6 lines
                bne _next2

                plp
                rts
                .endproc


;======================================
; Render Publisher
;======================================
RenderPublisher .proc
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
                sta CS_COLOR_MEM_PTR+11*CharResX,X
                sta CS_TEXT_MEM_PTR+11*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+11*CharResX,X
                sta CS_TEXT_MEM_PTR+11*CharResX,X

                bra _nextChar

_letter         pha
                phx
                lda #$40
                sta CS_COLOR_MEM_PTR+11*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+11*CharResX,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+11*CharResX,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+11*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderTitle     .proc
                php
                .m8i8

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda #$80
                sta CS_COLOR_MEM_PTR+13*CharResX,X
                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+13*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor    .proc
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
                sta CS_COLOR_MEM_PTR+16*CharResX,X
                sta CS_TEXT_MEM_PTR+16*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+16*CharResX,X
                sta CS_TEXT_MEM_PTR+16*CharResX,X

                bra _nextChar

_letter         pha
                phx
                lda #$70
                sta CS_COLOR_MEM_PTR+16*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+16*CharResX,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+16*CharResX,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+16*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect    .proc
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
                sta CS_COLOR_MEM_PTR+19*CharResX,X
                sta CS_TEXT_MEM_PTR+19*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+19*CharResX,X
                sta CS_TEXT_MEM_PTR+19*CharResX,X

                bra _nextChar

_letter         pha
                phx
                lda #$C0
                sta CS_COLOR_MEM_PTR+19*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+19*CharResX,X

                plx
                pla
                sta CS_TEXT_MEM_PTR+19*CharResX,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+19*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc


;======================================
; Blit bitmap text to VRAM
;--------------------------------------
; on entry:
;   zpDest      set by caller
;======================================
BlitText        .proc
                php
                phb
                .m16i16

                lda #640*16             ; Set the size
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>Text2Bitmap      ; Set the source address
                sta zpSource
                lda #`Text2Bitmap
                sta zpSource+2

                jsr Copy2VRAM

                plb
                plp
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
                ldx #HandleIrq_END-HandleIrq
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

                ply
                plx
                pla
                plp
                rts
                .endproc
