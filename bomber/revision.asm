    processor 6502

    ;;for memory mapping and macros

    include "macro.h"
    include "vcs.h"

    ;;; segmenting where the code starts
    seg code
    org $F000

Reset:
    CLEAN_START

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
Loop:    
    stx COLUBK
    sta WSYNC
    dex
    bne Loop
    

    lda #2 
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

    jmp START_FRAME

    org $FFFC 
    .word Reset
    .word Reset