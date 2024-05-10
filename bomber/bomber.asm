    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;    include the header files   ;;;;;;;;;;;;;;;

    include "vcs.h"
    include "macro.h"

;;;;;;;     define the variables    ;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80

JetXPos byte            ;X position of the player
JetYPos byte            ;Y position of the player
BomberXPos byte         ;X position of the bomber
BomberYPos byte         ;Y position of the bomber
JetSpritePtr word       ;pointer of the jet sprite
JetColorPtr word        ;pointer to the color of the jet sprite
BomberSpritePtr word    ;pointer to the bomb sprite
BomberColorPtr word     ;pointer to the color of the bomb sprite




;;;;;   Define Constants   ;;;;;;;;;;;;;;;;;;;;

JET_HEIGHT = 9
BOMBER_HEIGHT = 9





;;;;;;;     segementing the code      ;;;;;;;;;;;;;;;;;;;;;;;;

    seg Code
    org $F000

Reset:
    CLEAN_START      ; call macro to reset the memory and the registers

;;;;;;;;;;;;    initialize the TIA registers and the RAM variables  ;;;;;;;

    lda #10         ;randomly assigning the x position of the player1
    sta JetYPos
    lda #60         ;randomly assigning the y position of the player1
    sta JetXPos
    lda #83
    sta BomberYPos  ;assigning the bomber Y position
    lda #54
    sta BomberXPos  ;assigning the bomber X position

    ;;;;;   initialize the pointers to the correct lookup table addresses. ;;;;;
    lda #<JetSprite
    sta JetSpritePtr
    lda #>JetSprite 
    sta JetSpritePtr + 1

    lda #<JetColor
    sta JetColorPtr
    lda #>JetColor
    sta JetColorPtr + 1

    lda #<BomberSprite
    sta BomberSpritePtr
    lda #>BomberSprite
    sta BomberSpritePtr + 1

    lda #<BomberColor
    sta BomberColorPtr
    lda #>BomberColor
    sta BomberColorPtr + 1




StartFrame:
    lda #2
    sta VBLANK          ;turn on VBLANK
    sta VSYNC           ;turn on VYSNC

    REPEAT 3
        sta WSYNC       ;wait for the 3 VSYNC scanlines
    REPEND

    lda #0              ;turn off the VSYNC
    sta VSYNC
    
    REPEAT 37
        sta WSYNC       ;wait for the 37 vblank scanlines
    REPEND

    sta VBLANK           ;turn off the vblank

    
GameVisibleLoop:
    
    lda #$84
    sta COLUBK
    lda #$C2
    sta COLUPF

    lda #%00000001
    sta CTRLPF
    lda #$F0
    sta PF0
    lda #$FC
    sta PF1
    lda #0
    sta PF2

    ldx #96
.GameLoop:
.AreweinsidejetSprite:
    txa
    sec 
    sbc JetYPos
    cmp JET_HEIGHT
    bcc .DrawSpriteP0
    lda #0

.DrawSpriteP0:
    tay
    lda (JetSpritePtr),Y
    sta WSYNC
    sta GRP0
    lda (JetColorPtr),Y
    sta COLUP0

.AreweinsidebomberSprite:
    txa
    sec 
    sbc BomberYPos
    cmp BOMBER_HEIGHT
    bcc .DrawSpriteP1
    lda #0

.DrawSpriteP1:
    tay
    lda #%00000101
    sta NUSIZ1
    lda (BomberSpritePtr),Y
    sta WSYNC
    sta GRP1
    lda (BomberColorPtr),Y
    sta COLUP1

    dex
    bne .GameLoop

    


Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JetSprite:
    .byte #%00000000         ;
    .byte #%00010100         ;   # #
    .byte #%01111111         ; #######
    .byte #%00111110         ;  #####
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #

JetSpriteTurn:
    .byte #%00000000         ;
    .byte #%00001000         ;    #
    .byte #%00111110         ;  #####
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #

BomberSprite:
    .byte #%00000000         ;
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00101010         ;  # # #
    .byte #%00111110         ;  #####
    .byte #%01111111         ; #######
    .byte #%00101010         ;  # # #
    .byte #%00001000         ;    #
    .byte #%00011100         ;   ###

JetColor:
    .byte #$00
    .byte #$FE
    .byte #$0C
    .byte #$0E
    .byte #$0E
    .byte #$04
    .byte #$BA
    .byte #$0E
    .byte #$08

JetColorTurn:
    .byte #$00
    .byte #$FE
    .byte #$0C
    .byte #$0E
    .byte #$0E
    .byte #$04
    .byte #$0E
    .byte #$0E
    .byte #$08

BomberColor:
    .byte #$00
    .byte #$32
    .byte #$32
    .byte #$0E
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40

    org $FFFC
    .word Reset
    .word Reset


