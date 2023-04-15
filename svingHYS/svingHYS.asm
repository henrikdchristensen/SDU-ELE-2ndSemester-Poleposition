;Svinghys fungerer som en hysterese med jitter.
;Det vil sige at bilen f�rst registrer et h�jre-sving n�r signalet kommer over 160,
;herefter m� v�rdien godt g� ned til 130 f�r bilen ved at den er ude af svinget.
;P� samme m�de fungerer det for venstre-sving.
;Signal > 160: H�jre-sving.
;Signal < 80: Venstre-sving.

.def	TurnFlag = R17
		cpi		TurnFlag, 1		;Tjekker om flaget er sat p� forh�nd
		breq	InTurn1			;Brancher hvis flaget er sat
		
		cpi		R16,160			;Compare Signalet med strain-gauge v�rdi 160
		brsh	Turn			;Brancher til Turn hvis strain-gauge v�rdien er over 160

		cpi		R16,80
		brlo	Turn			;Brancher til Turn hvis strain-gauge v�rdien er under 80

		reti					;Return interrupt

Turn:							;Sving
		ldi 	TurnFlag, 1		;S�tter sving flaget
		rjmp	Counter1		;Jumper til Counter1

InTurn1:						;InTurn1 bruges til High jitter
		cpi		R16, 130		;Tjekker om v�rdien er kommet under 130
		brlo	InTurn2			;Brancher hvis v�rdien er under
		
		reti					;Return interrupt

InTurn2:						;InTurn2 bruges til Low jitter
		cpi		R16, 80			;Tjekker om v�rdien er kommet over 80
		brsh	ClearTurnFlag	;Brancher hvis v�rdien er over
		
		reti					;Return interrupt

ClearTurnFlag:					;ClearTurnFlag clearer TurnFlag (ude af sving)
		ldi		TurnFlag, 0		;Clearer TurnFlag
		
		reti					;Return interrupt
