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

.org	0x000E							; Adresse til timer1/counter1 compare match A
		jmp		MatchA

.org	0x0010							; Adresse til timer1/counter1 compare match B
		jmp		MatchB

.org	0x0014							; Compare Match interrupt Timer0
		rjmp	AccelerationInt

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

;		R16-R17							; Temp register
;		R18								; Sving tjekker
;		R20								; Lap Counter
;		R26-R30							; Pointers
		
;-------------------------------------

;.include "VentStart.asm"		

;--------------------------------------------------------------
;		AUTO MODE
;--------------------------------------------------------------

Automode:

;------ Bilens hastighed ------------

; 		Set pwm duty cyle to 30%
		ldi		R16, 	80			; Styrer hastigheden
		out		OCR2, 	R16

;------ Opmålings runde ---------------

;		Finder tabellen
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen

		ldi		XL,		low(Table)		; Henter tabellens lave adressen
		ldi		XH,		high(Table)		; Henter tebellens høje adressen
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


;--------------------------------------

;Send:
;		læser fra tabellen
;		ld		R16,	X+				; Læser fra tabellen, +1
;		ld		R17,	X+				; Læser fra tabellen, +1
		
;		out		UDR,	R16				; Sender R17 til Bluetooth
;		out		UDR,	R17				; Sender R17 til Bluetooth
;		ret

;--------------------------------------

ADK:
		in		R16,	ADCL			
		in		R17,	ADCH			; Read High bits to R17

.include	"svingHYS.asm"

		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)
		cbi		ADCSRA,	ADIF
		reti
		
;---------------------------------------

Counter1:
		in		R16,	TCNT1L			; Gemmer counterens nuværende værdi
		in		R17,	TCNT1H

;		Gemmer i tabellen
		st		Z+,		R16				; Gemmer R17 i tabellen, +1
		st		Z+,		R17				; Gemmer R18 i tabellen, +1
;		out		UDR,	R16
		
;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16	
		ret		

;---------------------------------------

Maalstreg:
		cpi		R20,	0x01
		brsh	Lap		
		call	Counter1				; Gemmer og resetter counteren
		cbi		ADCSRA,	ADIE			; Uenabler ADC interrupt

Sidste:
		ldi		R16,	0xFE
		ldi		R17,	0xFE
		
;		Gemmer i tabellen
		st		Z+,		R16				; Gemmer R17 i tabellen, +1
		st		Z+,		R17				; Gemmer R18 i tabellen, +1
		out		UDR,	R16

;------------------------------------------------------------------------------
;		RACE MODE
;------------------------------------------------------------------------------

Race:
;------ Register forbrug --------------

;		R16-R17							; Temp registers
;		R18-R19							; Gammel længde
;		R20								; Lap Counter
;		R22								; Stykke Counter
;		R21 & R23						; Acceleration
;		R24-R25							; Ny længde	
;		R26-R30							; Pointers
;		R31								; Tjekker Tabellen

;-------- Race setup ------------------
		sei
;		Ny interrupt fra counter setup
		ldi		R16,	0b00011000		; Enable MatchA- og MatchB-Interrupt
		out		TIMSK,	R16

;		Ny Timer1/Counter1 setup:
		ldi		R16,	0b00000010		; Normal, OC1A disconnected, normal, OC1B disconnected 
		out		TCCR1A,	R16
		ldi		R16,	0b00011111		; Fastpwm, Mode 14, Trigger på opadgående
		out		TCCR1B,	R16
		
;		Startværdier
		ldi		R16,	0xFF			; 
		out		OCR1Al,	R16
		out		OCR1AH,	R16	
			
		ldi		R16,	0xFF
		out		OCR1Bl,	R16
		out		OCR1BH,	R16		

; ----- Race start ---------------------
		ldi		R22,	0x01			; Stykke værdi

Lap:
		sbrc	R31,	0
		rjmp	Sving

;		Rundecounter 
		inc		R20	
			
;		Sæt pointer Z
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen	
		adiw	ZH:ZL,2				

Stykke:
;------- Lige stykke -------------------
;		Henter den gamle længde værdi
		ld		R18,	Z+				; Læser fra tabellen, +1
		ld		R19,	Z+				; Læser fra tabellen, +1
		inc		R22						; Optæller stykker

		;		Tester for målstreg
.include "ToStykker.asm"

		call	Udregning				; Udregner hvornår den skal bremser
		call	Accelerate				; Starter accelerations		
		out		OCR1Al,	R24				; Indlæser den ny udregnet længde
		out		OCR1AH,	R25				; Indlæser den ny udregnet længde
			
		out		OCR1Bl,	R18				; Indlæser den gamle længde
		out		OCR1BH,	R19				; Indlæser den gamle længde

Wait:					
		rjmp 	Wait
Wait2:
		call	Accelerate
		rjmp	Wait

MatchA:
		out		UDR,R22
		sbrs	R22,0
		rjmp	Wait2		
		call	AccelerateStop
		ldi		R16,	255
		out		UDR,	R16
		ldi		R16,	0x4C
		out		OCR2, 	R16

		reti
MatchB:
		sbrs	R22,0
		rjmp	Stykke
			
Sving:	
		sbrc	R31,0
		ldi		R31,0
;------- Sving stykke ---------------
;		Henter den gamle længde værdi
		ld		R18,	Z+				; Læser fra tabellen, +1
		ld		R19,	Z+				; Læser fra tabellen, +1	

		call	Udregning				; Udregner hvornår den skal bremser
		
		inc		R22

		out		OCR1Al,	R14				; Indlæser den ny udregnet længde
		out		OCR1AH,	R15				; Indlæser den ny udregnet længde
			
		out		OCR1Bl,	R18				; Indlæser den gamle længde
		out		OCR1BH,	R19				; Indlæser den gamle længde
		
		rjmp	Wait

Udregning:
.include "NyBremse.asm"
		ret

;------	Acceleration ----------------
Accelerate:
		in		R21,	TIMSK
		ldi		R22,	0b00000010
		eor		R21,	R22
		out		TIMSK,	R21
		ldi		R21,	124
		out		OCR0,	R21
		ldi		R21,	85
		ret	

AccelerationInt:		
		inc		R21
		out		OCR2,	R21		
		cpi		R21,	100
		breq	AccelerateStop
		reti	

AccelerateStop:
		in		R21,	TIMSK
		ldi		R22,	0b00000010
		eor		R21,	R22
		out		TIMSK,	R21
		sei
		ret



