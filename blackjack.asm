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

	; Although we've used strutures, I don't believe we've used system time in class.
	; I found everything related to system time in this program after searching on Google
	; for some way to generate random (or at least give the illuson of random) numbers.
	SYSTEMTIME STRUCT
		wYear		WORD ?
		wMonth		WORD ?
		wDayOfWeek	WORD ?
		wDay		WORD ?
		wHour		WORD ?
		wMinute		WORD ?
		wSecond		WORD ?
		wMilliseconds	WORD ?
	SYSTEMTIME ENDS

	time SYSTEMTIME <>

	; Strings
	OpeningMsg BYTE "Press H to hit, or S to stand, Score: ",0Dh,0Ah,0
	WinMsg BYTE "You win!",0Dh,0Ah,0
	LoseMsg BYTE "You lose.",0Dh,0Ah,0
	TieMsg BYTE "You tie!",0Dh,0Ah,0
	PlayAgainMsg BYTE "Press P to play again, or X to exit",0Dh,0Ah,0

.code
	; Proc Draw -- Draws card from Deck (generates value up to 51 & returns corresponding value in Deck)
	;	- Should also set corresponding value in deck to -1 to indicate it is used
	;	- Should jump back to start if -1 is drawn 
	Draw PROC
		; I don't believe this was taught in class. I found it on StackOverflow as a way to easily 
		; do psuedo-random number generation in asm using system time
		MOV AH, 00h
		INVOKE GetLocalTime, ADDR time

		MOV AX, DX
		XOR DX, DX
		MOV CX, 10
		DIV CX
		ADD DL, 2	; Only necessary when not using Deck array (shifts 0-9 range to 2-11)
		MOV AL, DL
		MOV AH, 00h

		RET
	Draw ENDP

	PrintScore PROC
		MOV EAX, 00000000h ; Clears EAX so Score can be moved in
		mov AX, 'S'
		CALL WriteChar
		mov AX, 'c'
		CALL WriteChar
		mov AX, 'o'
		CALL WriteChar
		mov AX, 'r'
		CALL WriteChar
		mov AX, 'e'
		CALL WriteChar
		mov AX, ':'
		CALL WriteChar
		mov AX, ' '
		CALL WriteChar
		MOV AX, Score
		CALL WriteDec ; Found in textbook, pg 157
		mov AX, 10
		CALL WriteChar
		ret
	PrintScore ENDP

	PrintDealerScore PROC
		MOV EAX, 00000000h ; Clears EAX so Score can be moved in
		mov AX, 'D'
		CALL WriteChar
		mov AX, 'e'
		CALL WriteChar
		mov AX, 'a'
		CALL WriteChar
		mov AX, 'l'
		CALL WriteChar
		mov AX, 'e'
		CALL WriteChar
		mov AX, 'r'
		CALL WriteChar
		mov AX, ' '
		CALL WriteChar
		mov AX, 'S'
		CALL WriteChar
		mov AX, 'c'
		CALL WriteChar
		mov AX, 'o'
		CALL WriteChar
		mov AX, 'r'
		CALL WriteChar
		mov AX, 'e'
		CALL WriteChar
		mov AX, ':'
		CALL WriteChar
		mov AX, ' '
		CALL WriteChar
		MOV AX, DealerScore
		CALL WriteDec ; Found in textbook, pg 157
		mov AX, 10
		CALL WriteChar
		ret
	PrintDealerScore ENDP

Main PROC
	; Input: Start accepting input for hit (H) or stand (S)
Input:
	; Display opening message + controls
	MOV  edx,OFFSET OpeningMsg
    CALL WriteString
	CALL PrintScore

	CALL ReadChar
	CALL WriteChar
	CMP AL, 'h'
	JE Hit
	CMP AL, 'H'
	JE Hit
	CMP AL, 's'
	JE Stand
	CMP AL, 'S'
	JE Stand
	JMP Input
	; Jump to respective code block depending on input
	;	Hit: Draws card -> adds card to score -> inc Aces if needed -> reduce Ace to 1 if needed
	;	Stand: Starts drawing for dealer, compares player/dealer score, jumps to ending (win/lose/draw)
	
Hit:
	; New line in output
	mov AX, 10
	CALL WriteChar

	CALL Draw
	ADD Score, AX
	CMP AX, 11
	JE AddAce
Hit2:

	CMP Score, 21	; Jumps to bust if above 21, Win if equal to 21, and asks for input again if less than 21
	JA Bust
	JE BJ
	JB Input

AddAce:
	inc Aces
	jmp Hit2

Bust: 
	CMP Aces, 0
	JE Lose		; Loses if no aces can be reduced
	
	DEC Aces
	SUB Score, 10	; Reduces score by 10 (Changing Ace from 11 to 1)
	JMP Input

BJ:
	CALL PrintScore
Stand:
	; New line in output
	mov AX, 10
	CALL WriteChar

	CALL Draw
	ADD DealerScore, AX
	CALL PrintDealerScore

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
	MOV  edx,OFFSET WinMsg
    CALL WriteString
	jmp PlayAgain

Lose:
	CALL PrintScore
	MOV  edx,OFFSET LoseMsg
    CALL WriteString
	jmp PlayAgain

Tie:
	MOV  edx,OFFSET TieMsg
    CALL WriteString
	jmp PlayAgain

Reset:
	MOV Score, 0
	MOV DealerScore, 0
	MOV Aces, 0
	JMP Input

PlayAgain:
	MOV  edx,OFFSET PlayAgainMsg
    CALL WriteString
PlayAgainInput:
	CALL ReadChar
	CMP AL, 'P'
	JE Reset
	CMP AL, 'p'
	JE Reset
	CMP AL, 'X'
	JE GameEnd
	CMP AL, 'x'
	JE GameEnd
	JMP PlayAgainInput

GameEnd:
    ; INVOKE ExitProcess,0
	exit
main ENDP
END main