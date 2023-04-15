;Definationer
.def	GammelL = R18
.def	GammelH = R19
;.def	Lap = R20
.def	NyL = R24
.def	NyH = R25

;Multiplicere R20 med 2 og
;kopiere Gammel over i Ny
		in		R16,SREG
		push	R16
		push	R22
		push  	R20
		push	R18
		push	R19
;		LSL		R20

		movw	NyH:NyL,GammelH:GammelL

;Sammenligner den gamleværdi
Sammenlign:
		ldi		R16,0x00					;Clear R16 for at sætte SREG-register
		out		SREG,R16

		cpi		GammelH,HIGH(700)			;Sammenligner med 400 og hvis den gamleværdi er højrer,
		BRSH	BL14						;så springer den til BL1, som senere springer til NBL1		

		cpi		GammelH,HIGH(600)			;Sammenligner med 400 og hvis den gamleværdi er højrer,
		BRSH	BL13						;så springer den til BL1, som senere springer til NBL1		

		cpi		GammelH,HIGH(500)			;Sammenligner med 400 og hvis den gamleværdi er højrer,
		BRSH	BL12						;så springer den til BL1, som senere springer til NBL1		

		cpi		GammelH,HIGH(400)			;Sammenligner med 400 og hvis den gamleværdi er højrer,
		BRSH	BL1							;så springer den til BL1, som senere springer til NBL1

		cpi		GammelH,HIGH(350)
		BRSH	BL2

		cpi		GammelH,HIGH(300)
		BRSH	BL3

		cpi		GammelL,250
		BRSH	BL4

		cpi		GammelL,200
		BRSH	BL5

		cpi		GammelL,150
		BRSH	BL6

		cpi		GammelL,100
		BRSH	BL7

		cpi		GammelL,75
		BRSH	BL8

		cpi		GammelL,50
		BRSH	BL9

		cpi		GammelL,25
		BRSH	BL10

		cpi		GammelL,0
		BRSH	BL11

		rjmp	END							;Springer til slutningen


;Ekstra spring for at Branchene kan følge med
;   -------------------------------------
BL1:	rjmp	NBL1
BL2:	rjmp	NBL2
BL3:	rjmp	NBL3
BL4:	rjmp	NBL4
BL5:	rjmp	NBL5
BL6:	rjmp	NBL6
BL7:	rjmp	NBL7
BL8:	rjmp	NBL8
BL9:	rjmp	NBL9
BL10:	rjmp	NBL10
BL11:	rjmp	NBL11
BL12:	rjmp	NBL12
BL13:	rjmp	NBL13
BL14:	rjmp	NBL14

NBL14:
		clc							;Clear carry for sikkerhedsskyld
		ldi		R16,	255
		sub		NyL,	R16
		clr		R16
		sbc		NyH,	R16
		subi	NyH,	1
				
		andi	R22,0x01			;Ser om den er lige eller ulige - lige så er vi på ligestykke
		BRBc	SREG_Z,Ligestykke14	;Hopper til lige stykke hvis R22 er lige

		clc							;Clear carry for sikkerhedsskykd
		sub		NyL,R20				;Trækker R20 fra ny
		sbc		NyH,R16				;Trækker R20 fra ny
		rjmp	END					;Hopper til slut

	Ligestykke14:
		clc							;Clear carry for sikkerhedsskyld
		Add		NyL,R20				;Lægger R20 til ny
		adc		NyH,R16				;Lægger R20 til ny
		rjmp	END					;Hopper til slut

NBL12:
		clc							;Clear carry for sikkerhedsskyld
		ldi		R16,	255
		sub		NyL,	R16
		clr		R16
		sbc		NyH,	R16
				
		andi	R22,0x01			;Ser om den er lige eller ulige - lige så er vi på ligestykke
		BRBc	SREG_Z,Ligestykke13	;Hopper til lige stykke hvis R22 er lige

		clc							;Clear carry for sikkerhedsskykd
		sub		NyL,R20				;Trækker R20 fra ny
		sbc		NyH,R16				;Trækker R20 fra ny
		rjmp	END					;Hopper til slut

	Ligestykke13:
		clc							;Clear carry for sikkerhedsskyld
		Add		NyL,R20				;Lægger R20 til ny
		adc		NyH,R16				;Lægger R20 til ny
		rjmp	END					;Hopper til slut

NBL13:
		clc							;Clear carry for sikkerhedsskyld
		ldi		R16,	150
		sub		NyL,	R16
		clr		R16
		sbc		NyH,	R16
		subi	NyH,	1
				
		andi	R22,0x01			;Ser om den er lige eller ulige - lige så er vi på ligestykke
		BRBc	SREG_Z,Ligestykke12	;Hopper til lige stykke hvis R22 er lige

		clc							;Clear carry for sikkerhedsskykd
		sub		NyL,R20				;Trækker R20 fra ny
		sbc		NyH,R16				;Trækker R20 fra ny
		rjmp	END					;Hopper til slut

	Ligestykke12:
		clc							;Clear carry for sikkerhedsskyld
		Add		NyL,R20				;Lægger R20 til ny
		adc		NyH,R16				;Lægger R20 til ny
		rjmp	END					;Hopper til slut

NBL1:
		clc							;Clear carry for sikkerhedsskyld
		ldi		R16,140				;Trækker 100 fra ny
		sub		NyL,R16				;Trækker 100 fra ny
		clr		R16					;Clear R16 til senere
		sbc		NyH,R16				;Trækker 100 fra ny
		
		andi	R22,0x01			;Ser om den er lige eller ulige - lige så er vi på ligestykke
		BRBc	SREG_Z,Ligestykke1	;Hopper til lige stykke hvis R22 er lige

		clc							;Clear carry for sikkerhedsskykd
		sub		NyL,R20				;Trækker R20 fra ny
		sbc		NyH,R16				;Trækker R20 fra ny
		rjmp	END					;Hopper til slut

	Ligestykke1:
		clc							;Clear carry for sikkerhedsskyld
		Add		NyL,R20				;Lægger R20 til ny
		adc		NyH,R16				;Lægger R20 til ny
		rjmp	END					;Hopper til slut

NBL2:
		clc
		ldi		R16,80
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke2

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke2:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL3:
		clc
		ldi		R16,60
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke3

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke3:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL4:
		clc
		ldi		R16,40
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke4

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke4:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL5:
		clc
		ldi		R16,30
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke5

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke5:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL6:
		clc
		ldi		R16,20
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke6

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke6:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL7:
		clc
		ldi		R16,20
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke7

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke7:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL8:
		clc
		ldi		R16,15
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke8

		clc
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke8:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL9:
		clc
		ldi		R16,5
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke9

		clc	
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke9:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL10:
		clc
		ldi		R16,4
		sub		NyL,R16
		clr		R16
		sbc		NyH,R16
	
		andi	R22,0x01
		BRBc	SREG_Z,Ligestykke10

		clc	
		sub		NyL,R20
		sbc		NyH,R16
		rjmp	END

	Ligestykke10:
		clc
		Add		NyL,R20
		adc		NyH,R16
		rjmp	END

NBL11:	
		ldi		R16,	1
		sub		NyL,	R16
		rjmp	END


;Slutter
END:
		pop		R19
		pop		R18
		pop		R20
		pop		R22
		pop		R16
		out		SREG,R16

	
