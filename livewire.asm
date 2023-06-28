
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


                .cpu "65c02"

                .include "equates/system_f256jr.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/frs_jr_graphic.mac"
                .include "macros/frs_jr_mouse.mac"
                .include "macros/frs_jr_random.mac"
                .include "macros/frs_jr_sprite.mac"
                .include "macros/game.mac"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

                .byte $F2,$56           ; signature
                .byte $02               ; block count
                .byte $01               ; start at block1
                .addr BOOT              ; execute address
                .word $0000             ; version
                .word $0000             ; kernel
                                        ; binary name
                .text 'Livewire',$00


;--------------------------------------
;--------------------------------------

BOOT            cld
                ldx #$FF                ; initialize the stack
                txs
                jmp LIVE

; --------------------------------------
; --------------------------------------

                .include "main.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_f256jr.asm"

                .include "object.asm"
                .include "panel.asm"
                .include "miscellaneous.asm"
                .include "grid.asm"
                .include "render.asm"

                .include "DATA.inc"


;--------------------------------------
                .align $100
;--------------------------------------

GameFont        .include "FONT.inc"
GameFont_end

Palette         .include "PALETTE.inc"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "SPRITES.inc"
Stamps_end

Playfield       .fill 160*32,$00
                .fill 8*32,$00          ; overflow to prevent screen artifacts

;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

Video8K         .fill 8192,$00

                .end
