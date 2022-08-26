; ===========================
;         LIVEWIRE
; ===========================
; ===========================
;   WRITTEN BY: TOM HUDSON
; A.N.A.L.O.G. COMPUTING #12
; ===========================

                .cpu "65816"

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"
                .include "macros_frs_random.asm"


;--------------------------------------
;--------------------------------------
                * = LIVE-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00
                cld

                jmp LIVE


; --------------------------------------
; --------------------------------------
                * = $2000
; --------------------------------------

                .include "main.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_c256.asm"

                .include "object.asm"
                .include "panel.asm"
                .include "miscellaneous.asm"
                .include "grid.asm"
                .include "render.asm"
                .include "data.asm"


;--------------------------------------
                .align $100
;--------------------------------------

GameFont        .include "FONT.asm"
GameFont_end

Palette         .include "PALETTE.asm"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "SPRITES.asm"
Stamps_end

Playfield       .fill 86*40,$00
                .fill 10*40,$00         ; overflow to prevent screen artifacts

;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

Video8K         .fill 8192,$00

                .end
