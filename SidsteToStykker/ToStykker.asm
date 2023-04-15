;----------------------------------------------------------------------------
;	Main.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp		RESET

;.org	0x000C
;		rjmp		Matchinterrupt		

;.org	0x000E							; Adresse til timer1/counter1 compare match A
;		rjmp		MatchA

;.org	0x0010							; Adresse til timer1/counter1 compare match B
;		rjmp		MatchB				


.dseg;- Variabler -------------------

Table:	.byte 50						; Opretter Table fylder 2 adresser per plads

.cseg;-------------------------------

.org	0x008E							; Adresse = 42 + sum(Variabler) 
RESET:

.include "Setup.asm"

Race:
;------ Register forbrug ------------

;		R20								; Lap Counter
;		R26-R30							; Pointers

		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens h�je adressen

		ldi		XL,		low(Table)		; Henter tabellens lave adressen
		ldi		XH,		high(Table)		; Henter tebellens h�je adressen


		LDI		R16,0x00
		out		SREG,R16

		ldi		R16,0x11
		ldi		R17,0x22
		ldi		R18,0x33
		ldi		R19,0x44
		ldi		R20,0x55
		ldi		R21,0x66
		ldi		R22,0x77
		ldi		R23,0x88
		ldi		R24,0x99

		st		X+,R16					; 
		st		X+,R17
		st		X+,R18
		st		X+,R19
		st		X+,R20
		st		X+,R21
		st		X+,R22
		st		X+,R23
		st		X+,R24


		ldi		XL,low(Table)
		ldi		XH,high(Table)


		call	TjekToFrem
		inc		XL
		inc		XL
		call	TjekToFrem
		inc		XL
		inc		XL
		call	TjekToFrem
		inc		XL
		inc		XL
		call	TjekToFrem
		ldi		R16,0x00



; Bruger register XL (R26) og XH (R27) som er pointeren der peger p� tabellen med v�rdierne for stykkerne
; Bruger R16,R17,R18,R19 som midligertidlige register som den udregner i.
; S�tter R31 til 0x01 som er flaget der beskriver at den er n�et til enden af tabellen.
; Efter den har adderet de to sidste stykker i tabellen ligger resultatet i R19(high):R18(low),
; som senere kan bruges til at udregne bremse l�ngden p� de sidste stykke.
; ----------------------------------------------
; tjekker om den har n�et den sidste v�rdi
; og hvis den har det, s� l�gges de to sidste v�rdier sammen
; og gemmes i R16 (low) og R17 (high)
; FUNKTIONERNE DER SKAL BRUGES:!
TjekToFrem:	
		adiw	XH:XL,4					; Her skal den hoppe 6 frem. og tjekke om det er FF.
		ld		R16,X					; Hvis det er FF, s� skal den l�gge de to sidste sammen
		cpi		R16,0xFE				; Hvis den er FF, tjekker den n�ste v�rdi om den er 0x00
		brbs	SREG_Z,Tjek2			; Hopper til tjek 2
		sbiw	XH:XL,0x04				; Hvis ikke den er FF, s� s�tter pointeren tilbage til den hvor den var f�r funktionenskald
		rjmp	Hoptilbage

Tjek2:									
		clc								; Clear carry for sikkerhedsskyld
		adiw	XH:XL,0x01				; L�gger �n til X-pointeren og tjekker om den er 0x00
		ld		R16,X					; Loader X-pointer ind i R16
		cpi		R16,0xFE				; Tjekker om R16 er 0x00
		brbs	SREG_Z,Additionaftosidste ; Hopper til addition hvis den er 0x00 og vi er f�et enden af tabelen
		rjmp	Hoptilbage				; Eller hopper den tilbage

Additionaftosidste:	
		ldi		R31,0x01				;SET Flag
		sbiw	XH:XL,3					; Springer tilbage til de to sidste v�rdier
		ld		R16,X+					; Gemmer de to 16-bits i 4 registrer til senere brug (addition)
		ld		R17,X

		ldi		XL,low(Table)
		ldi		XH,high(Table)
		
		ld		R18,X+
		ld		R19,X
		
		add		R18,R16					;Addere to 16bits tal - R17:R16 + R19:R18 = R17:R16
		adc		R19,R17					;Gemmer resultatet i R18,R19

		ldi		XL,low(Table)			; Hopper tilbage til start
		ldi		XH,high(Table)
		
		st		X+,R18					; Skriver svaret i f�rste sted p� tabelel
		st		X,R19

	HopOgTjek:							; Hopper helt til enden og overskriver de to sidste v�rdier med 0xFE
		ld		R16,X+					
		cpi		R16,0xFE				
		brbs	SREG_Z,SkrivOver		
		rjmp	HopOgTjek
	SkrivOver:
		sbiw	XH:XL,3
		ldi		R16,0xFE
		st		X+,R16
		st		X+,R16
		; Pointeren peger p� det n�ste element som er svingere efter m�l stregen
	
		;Kald NyBremse

Hoptilbage:
	

