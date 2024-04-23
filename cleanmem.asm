    processor 6502

    seg code    ; start a segment of the code.
    org $F000   ; define the code origin at $F000

Start:
    sei         ; disable interrupts
    cld         ; disable the BCD decimal math mode
    ldx #$FF    ; Loads the X register with #$FF
    txs         ; transfer the X register to the stack pointer


;; clear the page zero region ;;
;;meaning the entire ram and also the entire tia registers ;;
    lda #0      ; A = 0
    ldx #$FF    ; X = $FF
    sta $FF     ; make sure $FF is zeroed before the loop starts
MemLoop:   
    dex         ; X--
    sta $0,X    ; store the value of A inside memory address $0 + X
    bne MemLoop ;Loop until X is equal to Zero( z- flag is set)

;;fill the rom size to exactly 4kb

    org $FFFC   ;
    .word Start ; reset vector at $FFFC (where the program starts)
    .word Start ; interrupt vector at $FFFE (unused in the VCS)
