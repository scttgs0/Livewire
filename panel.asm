;======================================
; ADD TO SCORE
;======================================
ADDSCO          .proc
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
                jsr SHOSCO              ; show score

                lda SCORE               ; is score at
                cmp BONUS               ; bonus level?
                bne NOBONS              ; sorry!

                jsr INCLIV              ; bonus, add life!

                sed                     ; set decimal
                lda BONUS               ; get old bonus
                clc                     ; add 20000
                adc #2                  ; to it
                cld                     ; clr decimal
                sta BONUS               ; and save bonus
NOBONS          rts                     ; finis!
                .endproc


;======================================
; Show Score
;======================================
SHOSCO          .proc
                lda #$10                ; set up color
                sta SHCOLR              ; byte for show
                ldx #0                  ; zero x
                ldy #0                  ; & y regs
SSCOLP          lda SCORE,Y             ; get score byte
                jsr SHOBCD              ; show it

                inx                     ; increment show
                inx                     ; pos. by 2
                iny                     ; next score byte
                cpy #3                  ; done?
                bne SSCOLP              ; not yet!

                rts                     ; all done!
                .endproc


;======================================
; INCREMENT LIVES
;======================================
INCLIV          .proc
                lda LIVES               ; do we have
                cmp #5                  ; 5 lives now?
                beq NOMOLV              ; yup, no inc!

                inc LIVES               ; one more life
                jsr SHOLIV              ; show it

NOMOLV          rts                     ; and exit!
                .endproc


;======================================
; DECREMENT LIVES
;======================================
DECLIV          .proc
                jsr SNDOFF              ; no sound


; ---------------------------
; WAIT FOR PROJECTILES TO END
; ---------------------------

WAITPD          ldx #7                  ; 8 projectiles
                lda #0                  ; zero tally
CKPRLV          ora PROJAC,X            ; check all
                dex                     ; projectiles
                bne CKPRLV              ; for activity

                cmp #0                  ; any active?
                bne WAITPD              ; yes! wait more!

;
; STOP SHORTS
;

                ldx #3                  ; 4 shorts (0-3)
STPSHO          sta SHORTF,X            ; turn off
                dex                     ; all of 'em
                bpl STPSHO              ; loop until done

;
; PUT OBJECTS AT END OF GRID
;

                lda #0                  ; erase
                sta COLOR               ; color
                lda #5                  ; erase all 6
                sta OBJNUM              ; objects
ERSOBJ          jsr DRWOBJ              ; erase it!

                ldx OBJNUM              ; get object #
                lda #30                 ; place at
                sta OBJSEG,X            ; seg #30
                lda #1                  ; set up move
                sta OBJINC,X            ; increment
RNDOBG          .randomByte             ; get random
                and #$0F                ; sub-grid #
                cmp #$0F                ; 0-14
                beq RNDOBG

                sta OBJGRD,X
                dec OBJNUM              ; more objects?
                bpl ERSOBJ              ; yeah, do 'em

                lda #$0F                ; show player
                ;sta COLPM0             ; death here
                sta SID_CTRL1           ; start sound
MOREWT          .randomByte             ; set random
                and #$1F                ; death sound
                sta SID_FREQ1           ; frequency
                lda #6                  ; wait 0.1 sec
                jsr WAIT

                ;dec COLPM0             ; dec brightness
                ;lda COLPM0             ; now set
                ;sta SID_CTRL1              ; death volume
                ;bne MOREWT             ; more wait

                lda LIVES               ; more lives?
                beq DEAD                ; no more life!

                dec LIVES               ; one less life
                jsr SHOLIV              ; show it

                lda #60                 ; wait 1 sec
                jsr WAIT

                lda #0                  ; reset player
                sta KILPLR              ; kill flag
                ;lda #$16               ; and
                ;sta COLPM0             ; player color
                rts                     ; and exit!

DEAD            pla                     ; all dead, pull
                pla                     ; return addr.
                jmp LIVE                ; and restart game

                .endproc


;======================================
; SHOW LIVES
;======================================
SHOLIV          .proc
                lda #$90                ; select display
                sta SHCOLR              ; color
                lda LIVES               ; get lives
                ldx #7                  ; 7th char on line
                jsr SHOBCD              ; show it!

                rts                     ; and exit
                .endproc


;======================================
; SHOW LEVEL
;======================================
SHOLVL          .proc
                ldy #$50                ; select display
                sty SHCOLR              ; color
                lda BCDLVL              ; get level#
                ldx #14                 ; 14th char

                .endproc

                ;[fall-through]


;======================================
; BCD CHAR DISPLAY
;======================================
SHOBCD          .proc
                sta SHOBYT              ; save character
                and #$0F                ; get num 1
                ora SHCOLR              ; add color
                sta INFOLN+1,X          ; show it
                lda SHOBYT              ; get char.
                lsr A                   ; shift right
                lsr A                   ; to get
                lsr A                   ; num 2
                lsr A
                ora SHCOLR              ; add color
                sta INFOLN,X            ; show it
                rts                     ; and exit!
                .endproc
