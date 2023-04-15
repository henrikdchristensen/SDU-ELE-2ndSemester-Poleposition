;----------------------------------------------------------------------------
;	Main.asm
;----------------------------------------------------------------------------

; Sender 1 ud for målstregs sensor interrupt,
; Sender 2 ud for ADK interrupt
; Sender 3 ud for MatchA interrupt,
; Sender 4 ud for MatchB interrupt
; Sender 5 ud for Accelerations interrupt


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

;.org	0x0014							; Compare Match interrupt Timer0
;		rjmp	AccelerationInt

;.org	0x0016							; Overflow interrupt Timer0

;.org	0x001A							; Bluetooth receive complete interrupt
;.org	0x001E							; Bluetooth transmit complete interrupt

;.org	0x0020							; A/D konverteren complete interrupt
;		jmp		ADK	

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
;		R21								; SvingHYS
;		R22								; SvingHYS
;		R23								; SvingHYS
;		R24								; SvingHYS
;		R26-R30							; Pointers
		
;-------------------------------------

;.include "VentStart.asm"	
Automode:
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen
			
		ldi		R16,	41	
		st		Z+,		R16
		ldi		R16,	0	
		st		Z+,		R16
		ldi		R16,	93	
		st		Z+,		R16
		ldi		R16,	0	
		st		Z+,		R16
		ldi		R16,	190	
		st		Z+,		R16
		ldi		R16,	0	
		st		Z+,		R16
		ldi		R16,	91	
		st		Z+,		R16
		ldi		R16,	0	
		st		Z+,		R16
		ldi		R16,	129	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	69	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	58	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	59	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	35	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	85	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	52	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	42	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	45	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	147	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	18	
		st		Z+,		R16
		ldi		R16,	1	
		st		Z+,		R16
		ldi		R16,	254	
		st		Z+,		R16
		ldi		R16,	254	
		st		Z+,		R16	
		
		sei
		ldi		R17, 0b01000000
		out		GIFR,R17
		ldi		R20,	0
		ldi		R16,	85
		out		OCR2,	R16			
Ventevente:
		rjmp	Ventevente

Maalstreg:
;		cpi		R20,	0x01			; Er dette første runde?
;		brsh	Lap						; Nej hop til lap.

Race:
;------ Register forbrug --------------

;		R16-R17							; Temp registers
;		R18-R19							; Gammel længde
;		R20								; Lap Counter
;		R21								; Tjekker om bilen accelere
;		R22								; Stykke Counter
;		R23								; Acceleration
;		R24-R25							; Ny længde	
;		R26-R30							; Pointers



;-------- Race setup ------------------
;		Ny interrupt fra counter setup
;		ldi		R16,	0b00011000		; Enable MatchA- og MatchB-Interrupt
;		out		TIMSK,	R16

;		Ny Timer1/Counter1 setup:
;		ldi		R16,	0b00000010		; Normal, OC1A disconnected, normal, OC1B disconnected 
;		out		TCCR1A,	R16
;		ldi		R16,	0b00011111		; Fastpwm, Mode 14, Trigger på opadgående
;		out		TCCR1B,	R16
		
;		Startværdier
;		ldi		R16,	0xFF			; 
;		out		OCR1Al,	R16
;		out		OCR1AH,	R16	
			
;		ldi		R16,	0xFF
;		out		OCR1Bl,	R16
;		out		OCR1BH,	R16		



Lap:
; ----- Race start ---------------------

		ldi		R22,	0x00			; Stykke værdi
;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16	

;		Sæt pointer Z
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen	
;		adiw	ZH:ZL,2	

;		Rundecounter 
		inc		R20						; Inkremitere runde-counteren

		sei
;		cpi		R20,	2
;		brsh	Wait					; enable interrupt, da dette er disablet,
										; der ikke er forekommet nogen reti		
Stykke:
;------- Lige stykke -------------------
;		Henter den gamle længde værdi
		ld		R18,	Z+				; Læser fra tabellen, +1
		ld		R19,	Z+				; Læser fra tabellen, +1

		inc		R22						; Optæller stykke værdien

;		Tester for målstreg
.include "ToStykker.asm"

		call	Udregning				; Udregner hvornår den skal bremser

;		out		OCR1AH,	R25				; Indlæser den ny udregnet længde
;		out		OCR1Al,	R24				; Indlæser den ny udregnet længde
		
;		out		OCR1BH,	R19				; Indlæser den gamle længde			
;		out		OCR1Bl,	R18				; Indlæser den gamle længde	

		call	Accelerate				; Starter accelerations

;		cpi		R20,	0x02			; Er dette anden eller en senere runde?

Wait:	
		in		R17,	TCNT1L
		in		R16,	TCNT1H

		cp		R16,	R25
		brsh	Brems1
		rjmp 	Wait					; Servicerer interrupt

Brems1:
		cp		R17,	R24
		brsh	MatchA
		rjmp	Wait

WaitBrems:
		in		R17,	TCNT1L
		in		R16,	TCNT1H

		cp		R16,	R19
		brsh	Brems2
		rjmp 	WaitBrems					; Servicerer interrupt

Brems2:
		cp		R17,	R18
		brsh	MatchB
		rjmp	WaitBrems
		
Wait2:
		call	Accelerate				; Accelerere bilen
		rjmp	Waitbrems				; Hopper tilbage til wait

MatchA:
;		ldi		R16,	0x03
;		out		UDR,	R16

		sbrs	R22,0					; Tjekker for lige eller sving stykke
		rjmp	Wait2					; Hopper til wait2 funktionen

		ldi		R16,	60				; Bremsehastigheden
		out		OCR2, 	R16
		rjmp	WaitBrems

MatchB:
;		ldi		R16,	0x04
;		out		UDR,	R16

		call	ResetCounter1			; Resetter counter1
		sbrs	R22,0					; skipper på ulige 
		rjmp	Stykke
			
Sving:	
;------- Sving stykke ---------------
;		Henter den gamle længde værdi
		ld		R18,	Z+				; Læser fra tabellen, +1
		ld		R19,	Z+				; Læser fra tabellen, +1	

		call	Udregning				; Udregner hvornår den skal accelerer
		
		inc		R22

		rjmp	Wait							; Hopper tilbage til wait

ResetCounter1:
;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16			
		ret

Udregning:
.include "NyBremse.asm"
		ret

;------	Acceleration ----------------
Accelerate:
		ldi		R16,	100
		out		OCR2,	R16
;		ldi		R16,	0xAA
;		out		UDR,	R16
;		sbrc	R21,	1
;		ret
;		in		R16,	TIMSK
;		ldi		R17,	0b00000010
;		eor		R16,	R17
;		out		TIMSK,	R16
;		ldi		R16,	124
;		out		OCR0,	R16
;		ldi		R23,	60
;		sbr		R21,	1
		ret	

AccelerationInt:
		ldi		R16,	0x05
		out		UDR,	R16

		inc		R23
		out		OCR2,	R23
		cpi		R23,	90
		brsh	AccelerateStop		
		reti	

AccelerateStop:
		;in		R17,	TIMSK
		;ldi		R16,	0b00000010
		;eor		R17,	R16
		;out		TIMSK,	R17
		;cbr		R21,	1
		ret



