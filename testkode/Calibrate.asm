;----------------------------------------------------------------------------
;	Main.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp	RESET

;.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
;		jmp		Maalstreg

;.org	0x0004							; Udekommende interrupt, INT1, PORTD.3
;.org	0x0006							; Udekommende interrupt, INT2, PORTB.2

;.org	0x000E							; Adresse til timer1/counter1 compare match A
;		jmp		MatchA

;.org	0x0010							; Adresse til timer1/counter1 compare match B
;		jmp		MatchB

;.org	0x0014							; Compare Match interrupt Timer0
;		rjmp	AccelerationInt

;.org	0x0016							; Overflow interrupt Timer0

;.org	0x001A							; Bluetooth receive complete interrupt
;.org	0x001E							; Bluetooth transmit complete interrupt

.org	0x0020							; A/D konverteren complete interrupt
		jmp		ADK	

;------------------------------------

.org	0x002A							; Adresse 42

.dseg;- Variabler -------------------

;Data1:	.byte 1							; Oprettet variabler
Table:	.byte 100						; Opretter Table

.cseg;-------------------------------

RESET:
;------ Inkluderet filer ------------

.include "Setup.asm"

;------ Definitioner ----------------

;.def	temp	= R16

;------------------------------------

;.equ	H		= 0xFF
;.equ	L		= 0x00

;------ Register forbrug ------------

;		R16-R17							; Temp register
;		R18								; Sving tjekker
;		R20								; Lap Counter
;		R21								; SvingHYS høj høj
;		R22								; SvingHYS høj lav
;		R23								; SvingHYS lav høj
;		R24								; SvingHYS lav lav
;		R26-R30							; Pointers
		
;-------------------------------------

;.include "VentStart.asm"		

;--------------------------------------------------------------
;		AUTO MODE
;--------------------------------------------------------------

Automode:
		cbi		ADCSRA,	ADIE			; clear ADIE bit (disable interrupt)
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)	

Calibrate:
		sbis	ADCSRA, ADIF			; Vent på A/D konverteren
		rjmp	Calibrate		
		cbi		ADCSRA,	ADSC			; clear ADSC bit ( conversion)	
		cbi		ADCSRA, ADIF			; 
		in		R16,	ADCL
		ldi		R17,	28
		add		R16,	R17
		mov		R21,	R16				; høj høj værdi

		ldi		R17,	5
		add		R16,	R17
		mov		R22,	R16				; høj lav værdi

		ldi		R17,	5
		sub		R16,	R17
		mov		R23,	R16				; lav høj værdi

		ldi		R17,	28
		sub		R16,	R17
		mov		R24,	R16				; lav lav værdi	
		sbi		ADCSRA,	ADIE			; clear ADIE bit (disable interrupt)

					
;------ Bilens hastighed ------------

; 		Set pwm duty cyle to 30%
		ldi		R16, 	80				; Styrer hastigheden
		out		OCR2, 	R16

;------ Opmålings runde ---------------

;		Finder tabellen
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen

;		ldi		XL,		low(Table)		; Henter tabellens lave adressen
;		ldi		XH,		high(Table)		; Henter tebellens høje adressen
;		adiw	XH:XL,1
		ldi		R20,	0x00			; Lap værdi

;		Polling af external interrupt for at finde målstregen
Vent:
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

ADK:
		Reti
