
;;calling the subroutine
lda #85      ;the parameter loading. the x position of the object
ldy #0.      ;the object we want to locate at the specific position
jsr SetObjectXPos

sta WSYNC
sta HMOVE





;;create a subroutine to set the X position of the objects with fine offset.
;; A register contains the desired X-coordinate
;;Y = 0 -> Player 0
;;Y = 1 -> Player 1
;; Y = 2 -> Player 2
;;Y = 3 -> Player 3
;;Y = 4 -> Player 4

SetObjectXPos subroutine
	sta WSYNC
	sec
	
.DivLoop
	sbc #15
	bcs .DivLoop
	eor #7
	asl
	asl
	asl
	asl
	sta HMP0, Y
	sta RESP0, Y
	
	rts