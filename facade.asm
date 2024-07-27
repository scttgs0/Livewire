
; SPDX-FileName: facade.asm
; SPDX-FileCopyrightText: Copyright 2023, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
;
;======================================
ClearScreenRAM  .proc
                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$11                ; [8000:9FFF]->[1_0000:1_1FFF]
                sta MMU_Block4
                inc A                   ; [A000:BFFF]->[1_2000:1_3FFF]
                sta MMU_Block5

                lda #<Screen16K         ; Set the source address
                sta zpDest
                lda #>Screen16K         ; Set the source address
                sta zpDest+1

                lda #$05                ; quantity of buffer fills (16k/interation)
                sta zpIndex1

                lda #$00
_next2          ldx #$40                ; quantity of pages (16k total)
                ldy #$00
_next1          sta (zpDest),Y

                dey
                bne _next1

                inc zpDest+1

                dex
                bne _next1

                dec zpIndex1
                beq _XIT

                inc MMU_Block4
                inc MMU_Block4
                inc MMU_Block5
                inc MMU_Block5

;   reset to the top of the screen buffer
                pha
                lda #<Screen16K         ; Set the source address
                sta zpDest
                lda #>Screen16K         ; Set the source address
                sta zpDest+1
                pla

                bra _next2

_XIT
;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================

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

                ; lda #<(SPRITES-VRAM)    ; Set the destination address
                ; sta zpDest
                ; lda #>(SPRITES-VRAM)
                ; sta zpDest+1
                ; lda #`(SPRITES-VRAM)
                ; sta zpDest+2

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
; Unpack the playfield into Screen RAM
;--------------------------------------
; 24 lines will fit within a slot
;   slot=$2000, 24-lines=$1E00
; double-lines w/in 2-slots
;   =$3C00 (of $4000)
; we then reset the Screen16K buffers
; (one position) to resume at:
;   =slot+($3C00-$2000)
;   =$6000+1C00... =$7C00
; space available is $A000-7C00=$2400
;   14 lines will fit within $2400 bytes
;   14*2*320=$2300
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 48 (=24*2)
;   =48*320, =$3C00
;   =$3C00-$2000,.. =$1C00
;   =$6000+$1C00... =$7C00
; - - - - - - - - - - - - - - - - - - -
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 76 (=48+14*2)
;   =76*320, =$5F00
;   =$5F00-$4000, =$1F00
;   =$6000+1F00... =$7F00
; space available is $A000-7F00=$2100
;   13 lines will fit within $2100 bytes
;   13*2*320=$2080
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 102 (=76+13*2)
;   =102*320, =$7F80
;   =$7F80-$6000, =$1F80
;   =$6000+1F80... =$7F80
; space available is $A000-7F80=$2080
;   13 lines will fit within $2080 bytes
;   13*2*320=$2080
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 128 (=102+13*2)
;   =128*320, =$A000
;   =$A000-$A000, =$0000
;   =$6000+0000... =$6000
; space available is $A000-6000=$4000
;   24 lines will fit within $4000 bytes
;   24*2*320=$3C00
;--------------------------------------
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 176 (=128+24*2)
;   =176*320, =$DC00
;   =$DC00-$C000, =$1C00
;   =$6000+1C00... =$7C00
; space available is $A000-7C00=$2400
;   14 lines will fit within $2400 bytes
;   14*2*320=$2300
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 204 (-176+14*2)
;   =204*320, =$FF00
;   =$FF00-$E000, =$1F00
;   =$6000+1F00... =$7F00
; space available is $A000-7F00=$2100
;   13 lines will fit within $2100 bytes
;   13*2*320=$2080
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 230 (=204+13*2)
;   =230*320, =$11F80
;   =$11F80-$10000, =$1F80
;   =$6000+1F80... =$7F80
; - - - - - - - - - - - - - - - - - - -
; we're done @ line 256
;======================================
SetScreenRAM    .proc
zpSRCidx        .var zpIndex1           ; source pointer, range[0:255]
zpDSTidx        .var zpIndex2           ; dest pointer, range[0:255]
zpRowBytes      .var zpIndex3           ; source byte counter, range[0:39]
;---

                pha
                phx
                phy

                lda zpPFDest
                sta zpPFDest_cache
                lda zpPFDest+1
                sta zpPFDest_cache+1
                lda zpPFDest2
                sta zpPFDest2_cache
                lda zpPFDest2+1
                sta zpPFDest2_cache+1

                stz zpSRCidx
                stz zpDSTidx
                stz zpRowBytes

_next1          ldy zpSRCidx
                lda (zpPFSource),Y
                inc zpRowBytes          ; increment the byte counter
                inc zpSRCidx            ; increment the source pointer
                bne _1

                inc zpPFSource+1

_1              ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl
                rol zpTemp1
                asl
                rol zpTemp1
                pha                     ; preserve

                lda zpTemp1
                ;lda nBlitLines  ; HACK:     color the line so we can analyze the render
                ;and #15         ; HACK:
                ;clc             ; HACK:
                ;adc #15         ; HACK:

                ldy zpDSTidx
                sta (zpPFDest),Y
                sta (zpPFDest2),Y         ; double-height

                iny
                sta (zpPFDest),Y          ; double-pixel
                sta (zpPFDest2),Y         ; double-height

                iny
                sty zpDSTidx            ; update the dest pointer
                bne _2

                inc zpPFDest+1
                inc zpPFDest2+1

_2              pla                     ; restore

                dex
                bpl _nextPixel

                ldx zpRowBytes
                cpx #40                 ; <40?
                bcc _next1              ;   yes

;   we completed a line
                stz zpRowBytes          ;   no, clear the byte counter
                dec nBlitLines          ; one less line to process
                beq _XIT                ; exit when zero lines remain

;   skip the next line since it is already rendered
                lda zpPFDest_cache
                clc
                adc #<$280
                sta zpPFDest
                sta zpPFDest_cache
                lda zpPFDest_cache+1
                adc #>$280
                sta zpPFDest+1
                sta zpPFDest_cache+1

                lda zpPFDest2_cache
                clc
                adc #<$280
                sta zpPFDest2
                sta zpPFDest2_cache
                lda zpPFDest2_cache+1
                adc #>$280
                sta zpPFDest2+1
                sta zpPFDest2_cache+1

                stz zpDSTidx
                bra _next1

_XIT            ply
                plx
                pla
                rts
                .endproc


;======================================
;
;======================================
BlitScreenRam   .proc
                ; pha

                ; lda #<$1E00             ; 24 lines (320 bytes/line)
                ; sta zpSize
                ; lda #>$1E00
                ; sta zpSize+1
                ; stz zpSize+2

                ; lda #<Screen16K         ; Set the source address
                ; sta zpSource
                ; lda #>Screen16K
                ; sta zpSource+1
                ; lda #'Screen16K
                ; sta zpSource+2

                ; jsr Copy2VRAM

                ; pla
                ; rts
                .endproc


;======================================
;
;======================================
BlitPlayfield   .proc
                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                ldy #$05                ; perform 5 block-copy operations
                stz _index

_nextBank       ldx _index
                inc _index

                lda _data_count,X
                sta nBlitLines

                lda _data_MMUslot,X
                sta MMU_Block4
                inc A
                sta MMU_Block5

                txa                     ; convert to WORD index
                asl
                tax

                lda _data_Source,X      ; set the source address
                sta zpPFSource
                lda _data_Source+1,X
                sta zpPFSource+1

                lda _data_Dest,X        ; set the destination address
                sta zpPFDest
                lda _data_Dest+1,X
                sta zpPFDest+1

                lda _data_Dest2,X        ; set the destination2 address (double-height lines)
                sta zpPFDest2
                lda _data_Dest2+1,X
                sta zpPFDest2+1

                jsr SetScreenRAM

                dey
                bne _nextBank

;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts

;--------------------------------------

_data_Source    .word Playfield
                .word Playfield+$03C0
                .word Playfield+$05F0
                .word Playfield+$07F8
                .word Playfield+$0A00

_data_Dest      .word Screen16K
                .word Screen16K+$1C00
                .word Screen16K+$1F00
                .word Screen16K+$1F80
                .word Screen16K

_data_Dest2     .word Screen16K+320
                .word Screen16K+320+$1C00
                .word Screen16K+320+$1F00
                .word Screen16K+320+$1F80
                .word Screen16K+320

_data_count     .byte 24,14,13,13,24        ; # of lines to draw

_data_MMUslot   .byte $10,$11,$12,$13,$15

_index          .byte ?

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
                ;!!phb
                ;!!.setbank `SDMA_SRC_ADDR
                ;!!.setdp zpSource
                ;!!.m8i8

    ; Set SDMA to go from system to video RAM, 1D copy
                ;!!lda #sdcSysRAM_Src|sdcEnable
                ;!!sta SDMA0_CTRL

    ; Set VDMA to go from system to video RAM, 1D copy
                ;!!lda #vdcSysRAM_Src|vdcEnable
                ;!!sta VDMA_CTRL

                ;!!.m16i8
                ;!!lda zpSource            ; Set the source address
                ;!!sta SDMA_SRC_ADDR
                ;!!ldx zpSource+2
                ;!!stx SDMA_SRC_ADDR+2

                ;!!lda zpDest              ; Set the destination address
                ;!!sta VDMA_DST_ADDR
                ;!!ldx zpDest+2
                ;!!stx VDMA_DST_ADDR+2

                lda zpSize              ; Set the size of the block
                ;!!sta SDMA_SIZE
                ;!!sta VDMA_SIZE
                lda zpSize+2
                ;!!sta SDMA_SIZE+2
                ;!!sta VDMA_SIZE+2

                ;!!.m8
                ;!!lda VDMA_CTRL           ; Start the VDMA
                ;!!ora #vdcStart_TRF
                ;!!sta VDMA_CTRL

                ;!!lda SDMA0_CTRL          ; Start the SDMA
                ;!!ora #sdcStart_TRF
                ;!!sta SDMA0_CTRL

                nop                     ; VDMA involving system RAM will stop the processor
                nop                     ; These NOPs give Vicky time to initiate the transfer and pause the processor
                nop                     ; Note: even interrupt handling will be stopped during the DMA
                nop

wait_vdma       ;!!lda VDMA_STATUS         ; Get the VDMA status
                ;!!bit #vdsSize_Err|vdsDst_Add_Err|vdsSrc_Add_Err
                bne vdma_err            ; Go to monitor if there is a VDMA error
                ;!!bit #vdsVDMA_IPS        ; Is it still in process?
                bne wait_vdma           ; Yes: keep waiting

                lda #0                  ; Make sure DMA registers are cleared
                ;!!sta SDMA0_CTRL
                ;!!sta VDMA_CTRL

                ;!!.setdp $0000
                ;!!.setbank $00
                ;!!.m8i8
                ;!!plb
                plp
                rts

vdma_err        lda #0                  ; Make sure DMA registers are cleared
                ;!!sta SDMA0_CTRL
                ;!!sta VDMA_CTRL

                ;!!.setdp $0000
                ;!!.setbank $00
                ;!!.m8i8
                ;!!plb
                plp

                jmp Copy2VRAM           ; retry
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

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda isIntro
                beq _cont

                jmp _XIT

_cont
;   reset color for the 40-char line
                ldx #$FF
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

_processText
;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

;   process the text
                ldx #$FF
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

_XIT
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
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
v_RenderLine    .var 11*CharResX
;---

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

                lda #$20
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

                lda MAGMSG,Y
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

_XIT            stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderTitle     .proc
v_RenderLine    .var 13*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for two 40-char lines
                ldx #$FF
                ldy #$FF
                lda #$80
_nextColor      inx
                iny
                cpy #$50
                beq _processText

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

_XIT            stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor    .proc
v_RenderLine    .var 16*CharResX
;---

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

                lda #$70
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

_XIT            stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect    .proc
v_RenderLine    .var 19*CharResX
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

                lda #$C0
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

                lda JoyMsg,Y
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
