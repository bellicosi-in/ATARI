    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code       ;segmenting the code
    org $F000       ;the origin of the RAM

START:
    CLEAN_START ;clears the RAM

StartFrame:
    lda #2      ;load the binary value %0000010
    sta VBLANK  ; activate the VBLANK
    sta VSYNC   ; activate the VSYNC

;;;;;;;; VERTICAL SYNC ;;;;;;;;;;;;;;;;;;;;

    sta WSYNC   ;first scanline
    sta WSYNC   ;second scanline
    sta WSYNC   ;third scanline

    lda #0
    sta VSYNC   ;turn off VSYNC



    ldx #37
VBLANKLOOP:
    sta WSYNC   ;scalines of the vertical blank
    dex         ;X--
    bne VBLANKLOOP  ;branch if X!=0

    lda #0
    sta VBLANK  ;turn off the vblank




    ldx #192
VHORIZONTALREAD:
    stx COLUBK  ;transfer the index to the background luminosity
    sta WSYNC
    dex
    bne VHORIZONTALREAD

    lda #2          
    sta VBLANK      ;turn on VBLANK again



    ldx #30
OVERSCAN:
    sta WSYNC   ;wait for the scanline to handover control
    dex         ;X--
    bne OVERSCAN    ;branch if X!=0

    jmp StartFrame

    org $FFFC
    .word START
    .word START


