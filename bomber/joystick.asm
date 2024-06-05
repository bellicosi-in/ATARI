    processor 6502

    include "vcs.h"
    include "macro.h"


    seg.u Variables
    org $80
PlayerXPos byte

    seg Code
    org $F000

Reset:
    CLEAN_START

    lda #$80
    sta COLUBK    
    lda #$3E
    sta COLUPF

    lda #10
    sta PlayerXPos

Start:
    
    ;;; VSYNC AND VBLANK

    lda #2
    sta VSYNC
    sta VBLANK

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    ;;determing the x pos of the player sprite

    lda PlayerXPos
    and #$7F
    sta WSYNC
    sta HMCLR
    sec
Divide:
    sbc #15
    bcs Divide

    eor #7
    asl
    asl
    asl
    asl

    sta HMP0
    sta RESP0
    sta WSYNC
    sta HMOVE

    REPEAT 35
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

    REPEAT 140
        sta WSYNC
    REPEND


    ldy #17
DrawBitmap:

    lda P0Bitmap,y
    sta GRP0
    lda P0Color,y
    sta COLUP0
    sta WSYNC
    dey 
    bne DrawBitmap

    lda #0
    sta GRP0

    lda #$FF
    sta PF0
    sta PF1
    sta PF2

    REPEAT 35
        sta WSYNC
    REPEND

    lda #0
    sta PF0
    sta PF1
    sta PF2

Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK



    



CheckUp:
    lda #%00010000
    bit SWCHA
    bne CheckDown
    inc PlayerXPos

CheckDown:
    lda #%00100000
    bit SWCHA
    bne CheckRight
    dec PlayerXPos

CheckRight
    lda #%10000000
    bit SWCHA
    bne CheckLeft
    inc PlayerXPos

CheckLeft:
    lda #%01000000
    bit SWCHA
    bne NoInput
    dec PlayerXPos


NoInput:
    jmp Start





P0Bitmap:
    byte #%00000000
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00011100
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01111111
    byte #%00111110
    byte #%00010000
    byte #%00011100
    byte #%00011100
    byte #%00011100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lookup table for the player colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    byte #$00
    byte #$F6
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$3E
    byte #$3E
    byte #$3E
    byte #$24


    org $FFFC
    .word Reset
    .word Reset