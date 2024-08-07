
;======================================
; Add to Score
;======================================
AddToScore      .proc
                ldy #0                  ; get zero
                sed                     ; set decimal mode

                lda SCORE+2             ; this section
                clc                     ; increments
                adc SCOADD+2            ; the 3-digit
                sta SCORE+2             ; score using
                sty SCOADD+2            ; the 3-digit

                lda SCORE+1             ; score add
                adc SCOADD+1            ; area, then
                sta SCORE+1             ; zeros out
                sty SCOADD+1            ; the

                lda SCORE               ; score add
                adc SCOADD              ; area using
                sta SCORE               ; the
                sty SCOADD              ; y register.

                cld                     ; clr decimal mode
                jsr ShowScore           ; show score

                lda SCORE               ; is score at
                cmp BONUS               ; bonus level?
                bne _XIT                ; sorry!

                jsr IncrementLives      ; bonus, add life!

                sed                     ; set decimal
                lda BONUS               ; get old bonus
                clc                     ; add 20000
                adc #2                  ; to it
                cld                     ; clr decimal
                sta BONUS               ; and save bonus

_XIT            rts
                .endproc


;======================================
; Show Score
;======================================
ShowScore       .proc
                lda #$30                ; set up color
                sta zpShowColor         ; byte for show

                ldx #0                  ; zero x
                ldy #0                  ; & y regs
_next1          lda SCORE,Y             ; get score byte
                jsr ShowBCD             ; show it

                inx                     ; increment show
                inx                     ; pos. by 2

                iny                     ; next score byte
                cpy #3                  ; done?
                bne _next1              ;   not yet!

                rts
                .endproc


;======================================
; Increment Lives
;======================================
IncrementLives  .proc
                lda LIVES               ; do we have
                cmp #5                  ; 5 lives now?
                beq _XIT                ;   yup, no inc!

                inc LIVES               ; one more life
                jsr ShowLives           ; show it

_XIT            rts
                .endproc


;======================================
; Decrement Lives
;======================================
DecrementLives  .proc
                jsr SoundOff            ; no sound

; ---------------------------
; wait for projectiles to end
; ---------------------------

_WAITPD         ldx #7                  ; 8 projectiles
                lda #0                  ; zero tally
_CKPRLV         ora isProjActive,X      ; check all projectiles for activity

                dex
                bne _CKPRLV

                cmp #0                  ; any active?
                bne _WAITPD             ;   yes! wait more!

; -----------
; stop shorts
; -----------

                ldx #3                  ; 4 shorts (0-3)
_STPSHO         sta SHORTF,X            ; turn off

                dex                     ; all of 'em
                bpl _STPSHO             ; loop until done

; --------------------------
; put objects at end of grid
; --------------------------

                lda #0                  ; erase
                sta COLOR               ; color

                lda #5                  ; erase all 6
                sta OBJNUM              ; objects
_ERSOBJ         jsr DrawObject          ; erase it!

                ldx OBJNUM              ; get object #
                lda #30                 ; place at
                sta OBJSEG,X            ; seg #30

                lda #1                  ; set up move
                sta OBJINC,X            ; increment

_RNDOBG         .frsRandomByte          ; get random
                and #$0F                ; sub-grid #
                cmp #$0F                ; 0-14
                beq _RNDOBG

                sta OBJGRD,X

                dec OBJNUM              ; more objects?
                bpl _ERSOBJ             ; yeah, do 'em

                lda #$0F                ; show player
                ;!!sta COLPM0             ; death here
                sta SID1_CTRL1          ; start sound

_MOREWT         .frsRandomByte          ; set random
                and #$1F                ; death sound
                sta SID1_FREQ1          ; frequency

                lda #6                  ; wait 0.1 sec
                jsr WAIT

                ;!!dec COLPM0             ; dec brightness
                ;!!lda COLPM0             ; now set
                ;!!sta SID1_CTRL1          ; death volume
                ;!!bne _MOREWT            ; more wait

                lda LIVES               ; more lives?
                beq _DEAD               ;   no more life!

                dec LIVES               ; one less life
                jsr ShowLives           ; show it

                lda #60                 ; wait 1 sec
                jsr WAIT

                lda #FALSE              ; reset player kill flag
                sta isPlayerDead

                ;!!lda #$16               ; and
                ;!!sta COLPM0             ; player color
                rts

_DEAD           pla                     ; all dead, pull
                pla                     ; return addr.
                jmp LIVE                ; and restart game

                .endproc


;======================================
; Show Lives
;======================================
ShowLives       .proc
                lda #$30                ; select display color
                sta zpShowColor

                lda LIVES               ; get lives
                ldx #7                  ; 7th char on line
                jsr ShowBCD             ; show it!

                rts
                .endproc


;======================================
; Show Level
;======================================
ShowLevel       .proc
                ldy #$30                ; select display color
                sty zpShowColor

                lda BCDLVL              ; get level#
                ldx #14                 ; 14th char

                .endproc

                ;[fall-through]


;======================================
; BCD Char Display
;--------------------------------------
; on entry
;   A           BCD value
;   X           display offset
;======================================
ShowBCD         .proc
                sta zpShowByte          ; save character

                and #$0F                ; get num 1
                ora zpShowColor         ; add color
                sta INFOLN+1,X          ; show it

                lda zpShowByte          ; restore character
                lsr                     ; /16 -- get num 0
                lsr
                lsr
                lsr
                ora zpShowColor         ; add color
                sta INFOLN,X            ; show it

                jsr RenderGamePanel

                rts
                .endproc
