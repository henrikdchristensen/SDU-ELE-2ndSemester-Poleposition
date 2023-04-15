;Svinghys fungerer som en hysterese med jitter.
;Det vil sige at bilen først registrer et højre-sving når signalet kommer over 160,
;herefter må værdien godt gå ned til 130 før bilen ved at den er ude af svinget.
;På samme måde fungerer det for venstre-sving.
;Signal > 160: Højre-sving.
;Signal < 80: Venstre-sving.

.def	TurnFlag = R17
		cpi		TurnFlag, 1		;Tjekker om flaget er sat på forhånd
		breq	InTurn1			;Brancher hvis flaget er sat
		
		cpi		R16,160			;Compare Signalet med strain-gauge værdi 160
		brsh	Turn			;Brancher til Turn hvis strain-gauge værdien er over 160

		cpi		R16,80
		brlo	Turn			;Brancher til Turn hvis strain-gauge værdien er under 80

		reti					;Return interrupt

Turn:							;Sving
		ldi 	TurnFlag, 1		;Sætter sving flaget
		rjmp	Counter1		;Jumper til Counter1

InTurn1:						;InTurn1 bruges til High jitter
		cpi		R16, 130		;Tjekker om værdien er kommet under 130
		brlo	InTurn2			;Brancher hvis værdien er under
		
		reti					;Return interrupt

InTurn2:						;InTurn2 bruges til Low jitter
		cpi		R16, 80			;Tjekker om værdien er kommet over 80
		brsh	ClearTurnFlag	;Brancher hvis værdien er over
		
		reti					;Return interrupt

ClearTurnFlag:					;ClearTurnFlag clearer TurnFlag (ude af sving)
		ldi		TurnFlag, 0		;Clearer TurnFlag
		
		reti					;Return interrupt
