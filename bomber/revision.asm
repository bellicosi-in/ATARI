    processor 6502

    ;;for memory mapping and macros

    include "macro.h"
    include "vcs.h"

    seg.u Variables
    org $80
P0Height byte
PlayerPos byte

    ;;; segmenting where the code starts
    seg code
    org $F000

Reset:
    CLEAN_START
    ldx #00
    stx COLUBK

    ;;initialize the players
    lda #130
    sta PlayerPos
    lda #9
    sta P0Height



START_FRAME:
    ;;;vsync and vblank
    lda #2
    sta VSYNC
    sta VBLANK

    ;; 3 LINES OF VSYNC
    REPEAT 3
        sta WSYNC
    REPEND

    ;;turn off VSYNC
    lda #0
    sta VSYNC

    ;;VBLANK
    REPEAT 37
        sta WSYNC
    REPEND


    ;turn off VBLANK
    lda #0
    sta VBLANK

    ldx #192
Scanline:
    
    txa
    sec
    sbc PlayerPos
    cmp P0Height
    bcc LoadBitMap
    lda #0

LoadBitMap:
    tay
    lda JetSprite,y
    sta WSYNC
    sta GRP0
    lda JetColor,y
    sta COLUP0
    dex
    bne Scanline

;;OVERSCAN
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

    inc PlayerPos

    jmp START_FRAME

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
JetColor:
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