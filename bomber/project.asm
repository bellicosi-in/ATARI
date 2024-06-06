    processor 6502

    include "macro.h"
    include "vcs.h"

    seg.u Variable
    org $80

JetXPos byte
JetYPos byte

    seg Code
    org $F000


    
Reset:
    CLEAN_START


    lda #$84
    sta COLUBK
    lda #$C2
    sta COLUPF

    lda #%00000001
    sta CTRLPF

    lda #40
    sta JetXPos

    lda #10
    sta JetYPos


Start:
    lda #2
    sta VSYNC
    sta VBLANK

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    lda JetXPos
    and #$7F
    sta WSYNC
    sta HMCLR
    sec
SetXPos:
    sbc #15
    bcs SetXPos
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


    REPEAT 20
        sta WSYNC
    REPEND

    lda #$FF
    sta PF0
    lda #%11000000
    sta PF1
    lda #%00000000
    sta PF2

    

    ldx #140
Scanline:   
    txa
    sec
    sbc JetYPos
    cmp #9
    bcc DisplaySprite
    lda #0


DisplaySprite:
    tay
    lda JetSprite,y
    sta WSYNC
    sta GRP0
    lda JetColor,y
    sta COLUP0


    ; lda #0
    ; sta GRP0

    dex
    bne Scanline
    
    REPEAT 30
        sta WSYNC
    REPEND

    lda #0
    sta GRP0
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
    ; lda #$0F           ; Debug: Set color to indicate Up is pressed
    ; sta COLUBK
    inc JetYPos

CheckDown:
    lda #%00100000
    bit SWCHA
    bne CheckRight
    ; lda #$F0           ; Debug: Set color to indicate Down is pressed
    ; sta COLUBK
    dec JetYPos

CheckRight:
    lda #%10000000
    bit SWCHA
    bne CheckLeft
    ; lda #$0A           ; Debug: Set color to indicate Right is pressed
    ; sta COLUBK
    inc JetXPos

CheckLeft:
    lda #%01000000
    bit SWCHA
    bne NoInput
    ; lda #$A0           ; Debug: Set color to indicate Left is pressed
    ; sta COLUBK
    dec JetXPos

NoInput:
    jmp Start












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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete ROM size with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC                ; move to position $FFFC
    word Reset               ; write 2 bytes with the program reset address
    word Reset               ; write 2 bytes with the interruption vector