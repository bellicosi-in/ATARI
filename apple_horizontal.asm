    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80
P0XPos byte

    seg Code
    org $F000

Reset:
    CLEAN_START

    ldx #$00            ;load the background color
    stx COLUBK          ;store it in the register

    lda #$50            
    sta P0XPos          ;initialize player x pos

StartFrame:

    lda #2              
    sta VSYNC
    sta VBLANK

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    ;; starting VBLANK;;

    lda P0XPos          ;load register A with desired X position
    and #$7F
    sec                 ;set carry flag before subtraction
    sta WSYNC           ;wait for next scanline
    sta HMCLR           ;clear old horizontal position values

DivideLoop:
    sbc #15             ;subtract 15 from A
    bcs DivideLoop      ;loop until carry flag is set

    eor #7              ;keep the reaminder in A between -8 and 7

    asl
    asl
    asl
    asl

    sta HMP0            ;set fine position value
    sta RESP0           ;reset the rough position
    sta WSYNC           ;wait for the next scanline
    sta HMOVE           ;apply for the fine position offset.

    REPEAT 35
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

    ;;; 192 SCANLINES ;;;
    REPEAT 60
        sta WSYNC
    REPEND

    ldy 8
DrawBitmap:
    lda P0Bitmap,Y          ;load player bitmap slice of data
    sta GRP0

    lda P0Color,Y          ;load player of color from lookup table
    sta COLUP0

    sta WSYNC               ;WAIT FRO NEXT SCANLINe

    dey
    bne DrawBitmap          ;branch if y!=0


    lda #0
    sta GRP0                ;disable P0 bitmap graphics

    REPEAT 124
        sta WSYNC
    REPEND

Overscan:
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

    inc P0XPos

    jmp StartFrame

P0Bitmap:
    byte #%00000000
    byte #%00010000
    byte #%00001000
    byte #%00011100
    byte #%00110110
    byte #%00101110
    byte #%00101110
    byte #%00111110
    byte #%00011100

P0Color:
    byte #$00
    byte #$02
    byte #$02
    byte #$52
    byte #$52
    byte #$52
    byte #$52
    byte #$52
    byte #$52

;;complete rom size
    org $FFFC
    .word Reset
    .word Reset