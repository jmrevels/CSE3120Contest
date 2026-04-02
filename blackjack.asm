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
	Draw PROC
		; I don't believe this was taught in class. I found it on StackOverflow as a way to easily 
		; do psuedo-random number generation in asm using system time
		MOV AH, 00h
		INT 1Ah 

		MOV AX, DX
		XOR DX, DX
		MOV CX, 10
		DIV CX
		ADD DL, 2	; Only necessary when not using Deck array (shifts 0-9 range to 2-11)
		MOV AL, DL
		MOV AH, 00h

		RET
	Draw ENDP

Main PROC
	; Display opening message + controls
	; Input: Start accepting input for hit (H) or stand (empty)
Input:
	; Jump to respective code block depending on input
	;	Hit: Draws card -> adds card to score -> inc Aces if needed -> reduce Ace to 1 if needed
	;	Stand: Starts drawing for dealer, compares player/dealer score, jumps to ending (win/lose/draw)
	
Hit:
	CALL Draw
	ADD Score, AX

	CMP Score, 21	; Jumps to bust if above 21, Win if equal to 21, and asks for input again if less than 21
	JA Bust
	JE Win
	JB Input

Bust: 
	CMP Aces, 0
	JE Lose		; Loses if no aces can be reduced
	
	DEC Aces
	SUB Score, 10	; Reduces score by 10 (Changing Ace from 11 to 1)
	JMP Input

Stand:
	CALL Draw
	ADD DealerScore, AX

	CMP DealerScore, 17
	JB Stand		; Dealer stops drawing on 17 or above

	CMP DealerScore, 21
	JA Win			; If dealer busts, player wins

	MOV AX, Score
	CMP DealerScore, AX
	JB Win
	JE Tie
	JA Lose
	
	; Ending Cases
	;	Blackjack: Occurs when player score is 21 at dealing, instant win (or tie if dealer also has blackjack)
	;	Win: Occurs when player score is higher than dealer
	;	Lose: Occurs when player score is lower than dealer
	;	Tie: Occurs when scores are tied

Win:

Lose:

Tie:

GameEnd:
    ; INVOKE ExitProcess,0
	exit
main ENDP
END