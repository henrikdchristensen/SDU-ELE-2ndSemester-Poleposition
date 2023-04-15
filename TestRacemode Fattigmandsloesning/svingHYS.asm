;Svinghys fungerer som en hysterese med jitter.
;Det vil sige at bilen først registrer et højre-sving når signalet kommer over 160,
;herefter må værdien godt gå ned til 130 før bilen ved at den er ude af svinget.
;På samme måde fungerer det for venstre-sving.
;Signal > 160: Højre-sving.
;Signal < 80: Venstre-sving.

		cpi		R18, 1		;Tjekker om flaget er sat på forhånd
		breq	InTurn1			;Brancher hvis flaget er sat
		
		cp		R16,R22			;Compare Signalet med strain-gauge værdi 160
		brsh	Turn			;Brancher til Turn hvis strain-gauge værdien er over 160

		cp		R16,R23
		brlo	Turn			;Brancher til Turn hvis strain-gauge værdien er under 80

		rjmp	EndHys			;Return interrupt

Turn:							;Sving
		ldi 	R18, 1		;Sætter sving flaget
		call	Counter1		;Jumper til Counter1
		rjmp	EndHys

InTurn1:						;InTurn1 bruges til High jitter
		cp		R16, R24		;Tjekker om værdien er kommet under 130
		brlo	InTurn2			;Brancher hvis værdien er under
		
		rjmp	EndHys			;Return interrupt

InTurn2:						;InTurn2 bruges til Low jitter
		cp		R16, R25			;Tjekker om værdien er kommet over 80
		brsh	ClearTurnFlag	;Brancher hvis værdien er over
		
		rjmp	EndHys			;Return interrupt

ClearTurnFlag:					;ClearTurnFlag clearer TurnFlag (ude af sving)
		ldi		R18, 0		;Clearer TurnFlag
		
		call	Counter1					;Return interrupt
		rjmp	EndHys

EndHys:
