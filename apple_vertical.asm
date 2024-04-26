    processor 6502

    include "macro.h"
    include "vcs.h"

    seg.u Variables
    org $80
P0Height byte       ;player sprite height
PlayerYPos byte      ;player sprite Y coordinate

    ;;start our rom code segment;;

    seg Code
    org $F000

Reset:
    CLEAN_START

    ldx #$00          ;black background color
    stx COLUBK          ;store the background colour

    ;;initialize variables
    lda #180
    sta PlayerYPos       ;PlayerYPos = 180

    lda #9
    sta P0Height        ;P0Height = 9

    ;;start a new frame by configuring VBLANK VSYNC ;;

StartFrame:
    lda #2
    sta VBLANK
    sta VSYNC

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

    ldx #192

Scanline:
    txa         ;transfer x to a
    sec         ;set the carry flag
    sbc PlayerYPos     ;subtract sprite Y coordinate
    cmp P0Height      ;are we inside the spirit height bounds?
    bcc LoadBitMap     ;if result < SpriteHeight, call subroutine
    lda #0              ;else set the index to 0
LoadBitMap:
    tay 
    lda P0Bitmap,Y     ;load player bitmap slice of data
    sta WSYNC           ;wait for next scanline
    sta GRP0            ;set the graphics for player 0 slice
    lda P0Color,Y      ;load player color from lookup table
    sta COLUP0          ;set color for player 0 slice

    dex
    bne Scanline        ;repeat next until scanline is finished

Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

    dec PlayerYPos

    jmp StartFrame

P0Bitmap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lookup table for the player colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete ROM size adding reset addresses at $FFFC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    word Reset
    word Reset