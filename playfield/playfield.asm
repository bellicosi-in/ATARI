    processor 6502
    

    include "macro.h"
    include "vcs.h"

    seg Code
    org $F000
Start:
    CLEAN_START         ;macro to safely clear the RAM
    ldx #$80            ;enter the background ground
    stx COLUBK         ;transfer the value back to the background colour register

    ldx #$1C            ;enter the playfield color
    stx COLUPF          ;transfer the value back to the playfield colour

StartFrame:

    lda #2              ;the decimal value 2
    sta VSYNC           ;turn on the vsync
    sta VBLANK          ;turn on the vblank

    
    REPEAT 3
        sta WSYNC
    REPEND

    ldx #0
    stx VSYNC           ;turn off the vsync

    REPEAT 37
        sta WSYNC
    REPEND

    ldx #0
    stx VBLANK          ;turn off the VBLANK

    ldx #%00000001
    stx CTRLPF          ;set the playfield to reflect

    ;;7 SCANLINES WITH NO PF COLOR ;;
    ldx #0
    stx PF0
    stx PF1
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ;;7 scanlines with yellow pf color ;;
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ;; 164 scanlines with yellow  border line color ;;

    ldx #%00100000
    stx PF0
    ldx #0
    stx PF1
    ldx #%10000000
    stx PF2

    REPEAT 164
        sta WSYNC
    REPEND

    ;;7 scanlines with yellow pf color ;;
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ;;7 SCANLINES WITH NO PF COLOR ;;
    ldx #0
    stx PF0
    stx PF1
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ;;OVERSCAN FOR 30 LINES

    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

    jmp StartFrame
    ;; FIT THE 4KB ROM

    org $FFFC
    .word Start
    .word Start