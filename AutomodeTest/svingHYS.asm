.def		TurnFlag=R18
		cpi		TurnFlag, 1
		breq	InTurn1

		cpi		R16,124
		brsh	Turn

		cpi		R16,73
		brlo	Turn

		rjmp	EndHys

Turn:
		ldi 	TurnFlag, 1
		call	Counter1
		rjmp	EndHys

InTurn1:
		cpi		R16, 100
		brlo	InTurn2
		rjmp	EndHys
InTurn2:
		cpi		R16, 95
		brsh	InTurn3
		rjmp	EndHys

InTurn3:
		ldi		TurnFlag, 0
		call	Counter1
		rjmp	EndHys

EndHys:
