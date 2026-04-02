INCLUDE Irvine32.inc

.data
	; Player score total: Word 0
	Score WORD 0
	; Dealer score total: Word 0
	DealerScore WORD 0
	; Deck: 52-long array, byte each [May be removed later for simplicity]
	Deck BYTE 52 DUP(?)
	; # of aces (11's) dealt: byte [needed for reducing 11's to 1's; may not be added for simplicity]
	Aces BYTE 0

.code
	; Proc Draw -- Draws card from Deck (generates value up to 51 & returns corresponding value in Deck)
	;	- Should also set corresponding value in deck to -1 to indicate it is used
	;	- Should jump back to start if -1 is drawn 
Main PROC
	; Display opening message + controls
	; Start accepting input for hit (H) or stand (empty)
	; Jump to respective code block depending on input
	;	Hit: Draws card -> adds card to score -> inc Aces if needed -> reduce Ace to 1 if needed
	;	Stand: Starts drawing for dealer, compares player/dealer score, jumps to ending (win/lose/draw)
	
	; Ending Cases
	;	Blackjack: Occurs when player score is 21 at dealing, instant win (or tie if dealer also has blackjack)
	;	Win: Occurs when player score is higher than dealer
	;	Lose: Occurs when player score is lower than dealer
	;	Push: Occurs when scores are tied

    ; INVOKE ExitProcess,0
	exit
main ENDP
END