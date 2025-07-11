
; ===========================
;         LIVEWIRE
; ===========================
; ===========================
;   WRITTEN BY: TOM HUDSON
; A.N.A.L.O.G. COMPUTING #12
; ===========================

;   SP00        player
;   SP01        flash (object death)
;   SP02-05     short
;   SP06-11     object
;   SP12-19     projectile

;   Graphics    160x234                 ; 160 graphic; 26 blanks; 48 text
;       ours    320x240                 ; 76,800 bytes [$12C00 = 300 pages]
;  Playfield    128x160
;       ours    256x160                 ; 256 + 32(border) + 32(border) = 320


                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
                .include "macros/f256_text.mac"
                .include "macros/game.mac"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

.if PGX=1
                .text "PGX"
                .byte $03
                .dword BOOT
;--------------------------------------
.else
                .byte $F2,$56           ; signature
                .byte $03               ; slot count
                .byte $01               ; start slot
                .addr BOOT              ; execute address
                .word $0001             ; version
                .word $0000             ; kernel
                .null 'Livewire'        ; binary name
.endif

;--------------------------------------

BOOT            ldx #$FF                ; initialize the stack
                txs

                stz IOPAGE_CTRL

                stz BACKGROUND_COLOR_R
                stz BACKGROUND_COLOR_G
                stz BACKGROUND_COLOR_B

                jmp LIVE


; --------------------------------------
; --------------------------------------

                .include "main.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_f256.asm"
                .include "facade.asm"

                .include "object.asm"
                .include "panel.asm"
                .include "miscellaneous.asm"
                .include "grid.asm"
                .include "render.asm"

                .include "data/DATA.inc"


;--------------------------------------
                .align $400
;--------------------------------------

GameFont        .include "data/FONT.inc"
GameFont_end


;--------------------------------------
                .align $100
;--------------------------------------

Palette         .include "data/PALETTE.inc"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "data/SPRITES.inc"
Stamps_end

Playfield       .fill 160*32,$00
                .fill 8*32,$00          ; overflow to prevent screen artifacts
