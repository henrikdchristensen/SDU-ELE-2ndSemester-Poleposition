
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
		adiw	ZH:ZL,2					; Her skal den hoppe 6 frem. og tjekke om det er FE.
		ld		R16,Z					; Hvis det er FE, s� skal den l�gge de to sidste sammen
		cpi		R16,0xFE				; Hvis den er FE, tjekker den n�ste v�rdi om den er 0x00
		brbs	SREG_Z,Tjek2			; Hopper til tjek 2
		sbiw	ZH:ZL,2					; Hvis ikke den er FE, s� s�tter pointeren tilbage til den hvor den var f�r funktionenskald
		rjmp	Hoptilbage
Tjek2:									
		clc								; Clear carry for sikkerhedsskyld
		adiw	ZH:ZL,0x01				; L�gger �n til X-pointeren og tjekker om den er 0xFE
		ld		R16,Z					; Loader X-pointer ind i R16
		cpi		R16,0xFE				; Tjekker om R16 er 0xFE
		brbs	SREG_Z,Additionaftosidste ; Hopper til addition hvis den er 0xFE og vi er f�et enden af tabelen
		sbiw	ZH:ZL,3
		rjmp	Hoptilbage				; Eller hopper den tilbage

Additionaftosidste:	
;		ldi		R31,0x01				;SET Flag
		sbiw	ZH:ZL,3					; Springer tilbage til de to sidste v�rdier
		ld		R16,Z+					; Gemmer de to 16-bits i 4 registrer til senere brug (addition)
		ld		R17,Z

		ldi		ZL,low(Table)
		ldi		ZH,high(Table)

		ld		R18,Z+
		ld		R19,Z

		add		R18,R16
		adc		R19,R17

		ldi		ZL,low(Table)
		ldi		ZH,high(Table)

		adiw	ZH:ZL,2					; S�tter pointeren til at pege p� f�rste sving efter m�lstregen.


		;st		Z+,R18
		;st		Z+,R19

;	HopOgTjek:							; Hopper til slutningen af tabellen og skriver de to sidste v�rdier(langstykket) med 0xFE
;		ld		R16,Z+
;		cpi		R16,0xFE
;		brbs	SREG_Z,SkrivOver
;		rjmp	HopOgTjek

;	SkrivOver:
;		sbiw	ZH:ZL,2
;		ldi		R16,0xFE
;		st		Z+,R16
;		st		Z+,R16

;		ldi		ZL,low(Table)
;		ldi		ZH,high(Table)

;		adiw	ZH:ZL,2					; S�tter pointeren til at pege p� f�rste sving efter m�lstregen.	

Hoptilbage:
