;----------------------------------------------------------------------------
;	Main.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp	RESET

.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
		jmp		Maalstreg

;.org	0x0004							; Udekommende interrupt, INT1, PORTD.3
;.org	0x0006							; Udekommende interrupt, INT2, PORTB.2

;.org	0x000E							; Adresse til timer1/counter1 compare match A
;		jmp		MatchA

;.org	0x0010							; Adresse til timer1/counter1 compare match B
;		jmp		MatchB

.org	0x0014							; Compare Match interrupt Timer0
		rjmp	Send

;.org	0x0016							; Overflow interrupt Timer0

;.org	0x001A							; Bluetooth receive complete interrupt
;.org	0x001E							; Bluetooth transmit complete interrupt

.org	0x0020							; A/D konverteren complete interrupt
		jmp		ADK	

;------------------------------------

.org	0x002A							; Adresse 42

.dseg;- Variabler -------------------

;Data1:	.byte 1							; Oprettet variabler
Table:	.byte 100						; Opretter Table fylder 2 adresser per plads


.cseg;-------------------------------

.org	0x00F2							; Adresse = 42 + sum(Variabler) 
RESET:
;------ Inkluderet filer ------------

.include "Setup.asm"

;------ Definitioner ----------------

;.def	temp	= R16

;------------------------------------

;.equ	H		= 0xFF
;.equ	L		= 0x00

;------ Register forbrug ------------

;		R19								; Sim.Flag register
;		R20								; Lap Counter
;		R26-R30							; Pointers

;-------------------------------------

;.include "VentStart.asm"		

Automode:

;------ Bilens hastighed ------------

; 		Set pwm duty cyle to 30%
		ldi		R16, 	70			; Styrer hastigheden
		out		OCR2, 	R16

;------ Opmålings runde ---------------

;		ldi		R19,	0x00			; Set R19 til 0
;		Finder tabellen
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen

		ldi		XL,		low(Table)		; Henter tabellens lave adressen
		ldi		XH,		high(Table)		; Henter tebellens høje adressen


;		Polling af external interrupt for at finde målstregen
Vent:
;		!Skal skrives om til at tjekke bit!			
		sbis	PIND,	2
		rjmp	Vent
		
Vent2:
		sbic	PIND,	2
		rjmp	Vent2

		ldi		R16,0
		out		TCNT1H,	R16
		out		TCNT1L,	R16

		ldi		R17, 0b01000000
		out		GIFR,R17
		
		SEI								; Enabler alle interrupts
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)

;--------------------------------------

Main:
		rjmp	Main


;--------------------------------------

ADK:
		in		R16,	ADCL			
		in		R17,	ADCH			; Read High bits to R17

.include	"svingHYS.asm"
		sbi		ADCSRA, ADSC
		cbi		ADCSRA,	ADIF
		reti

;---------------------------------------

Counter1:
		in		R16,	TCNT1L			; Gemmer counterens nuværende værdi
		in		R17,	TCNT1H

;		Gemmer i tabellen
		st		Z+,		R16				; Gemmer R17 i tabellen, +1
		st		Z+,		R17				; Gemmer R18 i tabellen, +1
		
;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1H,	R16				; Sætter counteren til 0
		out		TCNT1L,	R16	
		ret		

;---------------------------------------

Maalstreg:
		cbi		ADCSRA,	ADIE			; Uenabler ADC interrupt
		
		call	Counter1				; Gemmer og resetter counteren

		ldi		R16, 	0x00			; Styrer hastigheden
		out		OCR2, 	R16

;------ Sidste stykke ------------------
Sidste:
		ldi		R16,	0xFF
		ldi		R17,	0xFF
		
;		Gemmer i tabellen
		st		Z+,		R16				; Gemmer R17 i tabellen, +1
		st		Z+,		R17				; Gemmer R18 i tabellen, +1

		ldi		R17,	0
		out		GICR,	R17
Venter:
		sbis	UCSRA,	RXC		
		rjmp	Venter
		cbi		UCSRA,	RXC
;--------------------------------------
				
		sei
		ldi		R22,0b00000010
		out		TIMSK,R22
		ldi		R21,255
		out		OCR0,R21


Venter2:
		rjmp	Venter2
Send:
;		læser fra tabellen
		ld		R16,	X+				; Læser fra tabellen, +1
		ld		R17,	X+				; Læser fra tabellen, +1
		
		cpi		R17,	0xFF
		Breq	Slut

		out		UDR,	R16				; Sender R17 til Bluetooth

Send2:	
		sbis	UCSRA,	TXC
		rjmp	Send2

		out		UDR,	R17				; Sender R17 til Bluetooth
Send3:	
		sbis	UCSRA,	TXC
		rjmp	Send3
		
		reti

Slut:
		ldi		R22,0b00000000
		out		TIMSK,R22

		out		UDR,	R17				; Sender R17 til Bluetooth
Send4:	
		sbis	UCSRA,	TXC
		rjmp	Send4

Send5:
		sbis	UCSRA,	RXC
		rjmp	Send5
		
		rjmp	RESET
