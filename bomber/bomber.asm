    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;    include the header files   ;;;;;;;;;;;;;;;

    include "vcs.h"
    include "macro.h"

;;;;;;;     define the variables    ;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80

JetXPos byte        ;X position of the player
JetYPos byte        ;Y position of the player
BomberXPos byte     ;X position of the bomber
BomberYPos byte     ;Y position of the bomber

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

    ldy #192
.GameLoop:
    sta WSYNC
    dey 
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

    org $FFFC
    .word Reset
    .word Reset


