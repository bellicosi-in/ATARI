    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code
    org $f000       ;defines the origin of the ROM at $F0000

START:
    CLEAN_START     ;Macro to safely clear the memory
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; set the color luminosity backgorund to yellow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda $1E         ;load the color into A ($1E is NTSC yellow)
    sta COLUBK      ; store A to background color address $09

    jmp START       ;repeat from start

    org $FFFC       ;foll rom size to exactly 4kb
    .word START     ;RESET vector at $FFFC (where program starts)
    .word START     ;interrupt vector at $FFFE (unused in the VCS)