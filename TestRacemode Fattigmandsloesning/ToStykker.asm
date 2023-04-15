
; Bruger register XL (R26) og XH (R27) som er pointeren der peger på tabellen med værdierne for stykkerne
; Bruger R16,R17,R18,R19 som midligertidlige register som den udregner i.
; Sætter R31 til 0x01 som er flaget der beskriver at den er nået til enden af tabellen.
; Efter den har adderet de to sidste stykker i tabellen ligger resultatet i R19(high):R18(low),
; som senere kan bruges til at udregne bremse længden på de sidste stykke.
; ----------------------------------------------
; tjekker om den har nået den sidste værdi
; og hvis den har det, så lægges de to sidste værdier sammen
; og gemmes i R16 (low) og R17 (high)
; FUNKTIONERNE DER SKAL BRUGES:!

TjekToFrem:
		adiw	ZH:ZL,2					; Her skal den hoppe 6 frem. og tjekke om det er FE.
		ld		R16,Z					; Hvis det er FE, så skal den lægge de to sidste sammen
		cpi		R16,0xFE				; Hvis den er FE, tjekker den næste værdi om den er 0x00
		brbs	SREG_Z,Tjek2			; Hopper til tjek 2
		sbiw	ZH:ZL,2					; Hvis ikke den er FE, så sætter pointeren tilbage til den hvor den var før funktionenskald
		rjmp	Hoptilbage
Tjek2:									
		clc								; Clear carry for sikkerhedsskyld
		adiw	ZH:ZL,0x01				; Lægger én til X-pointeren og tjekker om den er 0xFE
		ld		R16,Z					; Loader X-pointer ind i R16
		cpi		R16,0xFE				; Tjekker om R16 er 0xFE
		brbs	SREG_Z,Additionaftosidste ; Hopper til addition hvis den er 0xFE og vi er fået enden af tabelen
		sbiw	ZH:ZL,3
		rjmp	Hoptilbage				; Eller hopper den tilbage

Additionaftosidste:	
		ldi		R18,	0xFF
		ldi		R19,	0xFF


Hoptilbage:
