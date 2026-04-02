INCLUDE Irvine32.inc

.data
	; Player score total: Word 0
	Score WORD 0
	; Deck: 52-long array, byte each [May be removed later for simplicity]
	Deck BYTE 52 DUP(?)
	; # of aces (11's) dealt: byte [needed for reducing 11's to 1's; may not be added for simplicity]
	Aces BYTE 0

.code
Main PROC

    ; INVOKE ExitProcess,0
	exit
main ENDP
END