;Svinghys fungerer som en hysterese med jitter.
;Det vil sige at bilen f�rst registrer et h�jre-sving n�r signalet kommer over 160,
;herefter m� v�rdien godt g� ned til 130 f�r bilen ved at den er ude af svinget.
;P� samme m�de fungerer det for venstre-sving.
;Signal > 160: H�jre-sving.
;Signal < 80: Venstre-sving.

		cpi		R18, 1		;Tjekker om flaget er sat p� forh�nd
		breq	InTurn1			;Brancher hvis flaget er sat
		
		cp		R16,R22			;Compare Signalet med strain-gauge v�rdi 160
		brsh	Turn			;Brancher til Turn hvis strain-gauge v�rdien er over 160

		cp		R16,R23
		brlo	Turn			;Brancher til Turn hvis strain-gauge v�rdien er under 80

		rjmp	EndHys			;Return interrupt

Turn:							;Sving
		ldi 	R18, 1		;S�tter sving flaget
		call	Counter1		;Jumper til Counter1
		rjmp	EndHys

InTurn1:						;InTurn1 bruges til High jitter
		cp		R16, R24		;Tjekker om v�rdien er kommet under 130
		brlo	InTurn2			;Brancher hvis v�rdien er under
		
		rjmp	EndHys			;Return interrupt

InTurn2:						;InTurn2 bruges til Low jitter
		cp		R16, R25			;Tjekker om v�rdien er kommet over 80
		brsh	ClearTurnFlag	;Brancher hvis v�rdien er over
		
		rjmp	EndHys			;Return interrupt

ClearTurnFlag:					;ClearTurnFlag clearer TurnFlag (ude af sving)
		ldi		R18, 0		;Clearer TurnFlag
		
		call	Counter1					;Return interrupt
		rjmp	EndHys

EndHys:
