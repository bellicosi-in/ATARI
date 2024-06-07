    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with VCS register memory mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare the variables starting from memory address $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80

JetXPos         byte         ; player0 x-position
JetYPos         byte         ; player0 y-position
BomberXPos      byte         ; player1 x-position
BomberYPos      byte         ; player1 y-position
Score           byte         ; 2 digit
Timer            byte         ; 2 digit stored as bcd
Temp            byte            ; to store temporary scores
OnesDigitOffset word
TensDigitOffset word
JetSpritePtr    word         ; pointer to player0 sprite lookup table
JetColorPtr     word         ; pointer to player0 color lookup table
BomberSpritePtr word         ; pointer to player1 sprite lookup table
BomberColorPtr  word         ; pointer to player1 color lookup table
JetAnimOffset   byte         ; player0 frame offset for sprite animation
Random          byte         ; used to generate random bomber x-position
ScoreSprite     byte
TimerSprite     byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9               ; player0 sprite height (# rows in lookup table)
BOMBER_HEIGHT = 9            ; player1 sprite height (# rows in lookup table)
DIGIT_HEIGHT = 5             ;scoreboard height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM code at memory address $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000

Reset:
    CLEAN_START              ; call macro to reset memory and registers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize RAM variables and TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #68
    sta JetXPos              ; JetXPos = 68
    lda #10
    sta JetYPos              ; JetYPos = 10
    lda #62
    sta BomberXPos           ; BomberXPos = 62
    lda #83
    sta BomberYPos           ; BomberYPos = 83
    lda #%11010100
    sta Random               ; Random = $D4
    lda #0
    sta Score
    sta Timer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize the pointers to the correct lookup table adresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<JetSprite
    sta JetSpritePtr         ; lo-byte pointer for jet sprite lookup table
    lda #>JetSprite
    sta JetSpritePtr+1       ; hi-byte pointer for jet sprite lookup table

    lda #<JetColor
    sta JetColorPtr          ; lo-byte pointer for jet color lookup table
    lda #>JetColor
    sta JetColorPtr+1        ; hi-byte pointer for jet color lookup table

    lda #<BomberSprite
    sta BomberSpritePtr      ; lo-byte pointer for bomber sprite lookup table
    lda #>BomberSprite
    sta BomberSpritePtr+1    ; hi-byte pointer for bomber sprite lookup table

    lda #<BomberColor
    sta BomberColorPtr       ; lo-byte pointer for bomber color lookup table
    lda #>BomberColor
    sta BomberColorPtr+1     ; hi-byte pointer for bomber color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the main display loop and frame rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations and tasks performed in the pre-VBlank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                   ; apply the horizontal offsets previously set

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display VSYNC and VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK               ; turn on VBLANK
    sta VSYNC                ; turn on VSYNC
    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC                ; turn off VSYNC
    REPEAT 33
        sta WSYNC            ; display the 37 recommended lines of VBLANK
    REPEND
    lda JetXPos
    ldy #0
    jsr SetObjectXPos        ; set player0 horizontal position

    lda BomberXPos
    ldy #1
    jsr SetObjectXPos        ; set player1 horizontal position

    jsr CalculateDigitOffset    ;calculate digit offset

    sta WSYNC
    sta HMOVE 
    lda #0
    sta VBLANK               ; turn off VBLANK

;;;Display the scoreboard
    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    ; lda #$1C            ;set colorfield to white
    ; sta COLUPF
    ; lda #00
    ; sta CTRLPF          ;disable playfield reflection
    ; REPEAT 20
    ;     sta WSYNC
    ; REPEND

    ldx #DIGIT_HEIGHT
.ScoreDigitLoop:
    ldy TensDigitOffset
    lda Digits,y
    and #$F0
    sta ScoreSprite

    ldy OnesDigitOffset
    lda Digits,Y
    and #$0F
    ora ScoreSprite
    sta ScoreSprite

    sta WSYNC
    sta PF1


;;TIMER
    ldy TensDigitOffset + 1             ; +1 because score and timer are stored sequentially in the memory:w

    lda Digits,Y
    and #$F0
    sta TimerSprite

    ldy OnesDigitOffset + 1
    lda Digits,Y
    and #$0F
    ora TimerSprite
    sta TimerSprite

    jsr Sleep12Cycles
    sta PF1
    ldy ScoreSprite
    sta WSYNC

    sty PF1                  ; update playfield for the score display
    inc TensDigitOffset
    inc TensDigitOffset+1
    inc OnesDigitOffset
    inc OnesDigitOffset+1    ; increment all digits for the next line of data

    jsr Sleep12Cycles        ; waste some cycles

    dex
    sta PF1
    bne .ScoreDigitLoop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display 192 visible scanlines of our game (96 lines because 2-line kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleLine:
    lda #$85
    sta COLUBK               ; set background/river color to blue
    lda #$C2
    sta COLUPF               ; set playfield/grass color to green
    lda #%00000001
    sta CTRLPF               ; enable playfield reflection
    lda #$F0
    sta PF0                  ; setting PF0 bit pattern
    lda #$FC
    sta PF1                  ; setting PF1 bit pattern
    lda #0
    sta PF2                  ; setting PF2 bit pattern

    ldx #95                  ; X counts the number of remaining scanlines
.GameLineLoop:
.AreWeInsideJetSprite:
    txa                      ; transfer X to A
    sec                      ; make sure carry flag is set before subtraction
    sbc JetYPos              ; subtract sprite Y-coordinate
    cmp JET_HEIGHT           ; are we inside the sprite height bounds?
    bcc .DrawSpriteP0        ; if result < SpriteHeight, call the draw routine
    lda #0                   ; else, set lookup index to zero
.DrawSpriteP0:
    clc                      ; clear carry flag before addition
    adc JetAnimOffset        ; jump to correct sprite frame address in memory
    tay                      ; load Y so we can work with the pointer
    lda (JetSpritePtr),Y     ; load player0 bitmap data from lookup table
    sta WSYNC                ; wait for scanline
    sta GRP0                 ; set graphics for player0
    lda (JetColorPtr),Y      ; load player color from lookup table
    sta COLUP0               ; set color of player 0

.AreWeInsideBomberSprite:
    txa                      ; transfer X to A
    sec                      ; make sure carry flag is set before subtraction
    sbc BomberYPos           ; subtract sprite Y-coordinate
    cmp BOMBER_HEIGHT        ; are we inside the sprite height bounds?
    bcc .DrawSpriteP1        ; if result < SpriteHeight, call the draw routine
    lda #0                   ; else, set lookup index to zero
.DrawSpriteP1:
    tay                      ; load Y so we can work with the pointer

    lda #%00000101
    sta NUSIZ1               ; stretch player 1 sprite

    lda (BomberSpritePtr),Y  ; load player1 bitmap data from lookup table
    sta WSYNC                ; wait for scanline
    sta GRP1                 ; set graphics for player1
    lda (BomberColorPtr),Y   ; load player color from lookup table
    sta COLUP1               ; set color of player 1

    dex                      ; X--
    bne .GameLineLoop        ; repeat next main game scanline until finished

    lda #0
    sta JetAnimOffset        ; reset jet animation frame to zero each frame

    sta WSYNC                ; wait for a scanline
    sta WSYNC
   
    
;; Display Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK               ; turn on VBLANK again
    REPEAT 30
        sta WSYNC            ; display 30 recommended lines of VBlank Overscan
    REPEND
    lda #0
    sta VBLANK               ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process joystick input for player0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000           ; player0 joystick up
    bit SWCHA
    bne CheckP0Down          ; if bit pattern doesnt match, bypass Up block
    inc JetYPos
    lda #0
    sta JetAnimOffset        ; reset sprite animation to first frame

CheckP0Down:
    lda #%00100000           ; player0 joystick down
    bit SWCHA
    bne CheckP0Left          ; if bit pattern doesnt match, bypass Down block
    dec JetYPos
    lda #0
    sta JetAnimOffset        ; reset sprite animation to first frame

CheckP0Left:
    lda #%01000000           ; player0 joystick left
    bit SWCHA
    bne CheckP0Right         ; if bit pattern doesnt match, bypass Left block
    dec JetXPos
    lda JET_HEIGHT           ; 9
    sta JetAnimOffset        ; set animation offset to the second frame

CheckP0Right:
    lda #%10000000           ; player0 joystick right
    bit SWCHA
    bne EndInputCheck        ; if bit pattern doesnt match, bypass Right block
    inc JetXPos
    lda JET_HEIGHT           ; 9
    sta JetAnimOffset        ; set animation offset to the second frame

EndInputCheck:               ; fallback when no input was performed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations to update position for next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateBomberPosition:
    lda BomberYPos
    clc
    cmp #0                   ; compare bomber y-position with 0
    bmi .ResetBomberPosition ; if it is < 0, then reset y-position to the top
    dec BomberYPos           ; else, decrement enemy y-position for next frame
    jmp EndPositionUpdate
.ResetBomberPosition
    jsr GetRandomBomberPos   ; call subroutine for random bomber positio

EndPositionUpdate:           ; fallback for the position update code


CheckCollisionP0P1:
    lda #%10000000
    bit CXPPMM
    bne .CollisionP0P1
    jmp CheckCollisionP0PF

.CollisionP0P1
    jsr GameOver

CheckCollisionP0PF:
    lda #%10000000
    bit CXP0FB
    bne .CollisionP0PF
    jmp EndCollisionCheck

.CollisionP0PF
    jsr GameOver

EndCollisionCheck:
    sta CXCLR





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop back to start a brand new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame           ; continue to display the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle object horizontal position with fine offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A is the target x-coordinate position in pixels of our object
;; Y is the object type (0:player0, 1:player1, 2:missile0, 3:missile1, 4:ball)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetObjectXPos subroutine
    sta WSYNC                ; start a fresh new scanline
    sec                      ; make sure carry-flag is set before subtracion
.Div15Loop
    sbc #15                  ; subtract 15 from accumulator
    bcs .Div15Loop           ; loop until carry-flag is clear
    eor #7                   ; handle offset range from -8 to 7
    asl
    asl
    asl
    asl                      ; four shift lefts to get only the top 4 bits
    sta HMP0,Y               ; store the fine offset to the correct HMxx
    sta RESP0,Y              ; fix object position in 15-step increment
    rts


GameOver subroutine
    lda #$30
    sta COLUBK
    sta COLUPF
    rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to generate a Linear-Feedback Shift Register random number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate a LFSR random number for the X-position of the bomber.
;; Divide the random value by 4 to limit the size of the result to match river.
;; Add 30 to compensate for the left green playfield
;; The routine also sets the Y-position of the bomber to the top of the screen.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandomBomberPos subroutine
    lda Random
    asl
    eor Random
    asl
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random               ; performs a series of shifts and bit operations

    lsr
    lsr                      ; divide the value by 4 with 2 right shifts
    sta BomberXPos           ; save it to the variable BomberXPos
    lda #30
    adc BomberXPos           ; adds 30 + BomberXPos to compensate for left PF
    sta BomberXPos           ; and sets the new value to the bomber x-position

    lda #96
    sta BomberYPos           ; set the y-position to the top of the screen

    rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle scoreboard digits to be displayed on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The scoreboard is stored using BCD, so the display shows hex numbers.
;; This converts the high and low nibbles of the variable Score and Timer
;; into the offsets of digits lookup table so the values can be displayed.
;; Each digit has a height of 5 bytes in the lookup table.
;;
;; For the low nibble we need to multiply by 5
;;   - we can use left shifts to perform multiplication by 2
;;   - for any number N, the value of N*5 = (N*2*2)+N
;;
;; For the upper nibble, since its already times 16, we need to divide it
;; and then multiply by 5:
;;   - we can use right shifts to perform division by 2
;;   - for any number N, the value of (N/16)*5 is equal to (N/4)+(N/16)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalculateDigitOffset subroutine

    ldx #1          ; X register is the loop counter 
.PrepareScoreLoop   ; this will loop twice, fist X - 1 and the x -0

    lda Score,X     ;load the acc with timer (X=1) and Score(X=0)
    and #%00001111  ; $0F remvoe the tens digit by masking 4 bits
    sta Temp        ;save the value of A into temp
    asl             ;shift left (N*2)
    asl             ;SHIFT LEFT (n*4)    
    adc Temp        ;(add the value saved in Temp) (+N)
    sta OnesDigitOffset,X   ;

    lda Score,X
    and #$F0
    lsr
    lsr
    sta Temp
    lsr
    lsr 
    adc Temp
    sta TensDigitOffset,X
    dex 
    bpl .PrepareScoreLoop
    rts

   
;;;sleep 12 cycles
;;;;jsr = 6 cycles
;;;; rts = 6 cycless

Sleep12Cycles subroutine
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Digits:
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00110011          ;  ##  ##
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %00100010          ;  #   #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01100110          ; ##  ##
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #






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
