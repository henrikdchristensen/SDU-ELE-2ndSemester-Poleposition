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
;		R21								; SvingHYS
;		R22								; SvingHYS
;		R23								; SvingHYS
;		R24								; SvingHYS
;		R26-R30							; Pointers
		
;-------------------------------------

.include "VentStart.asm"
	
;--------------------------------------------------------------
;		Calibrate
;--------------------------------------------------------------
;		Starter ADC
		cbi		ADCSRA, ADIE		
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)

Automode:
		sbis	ADCSRA, ADIF			; Vent på A/D konverteren
		rjmp	Automode
		sbi		ADCSRA,	ADSC			; set ADSC bit ( conversion)	
		cbi		ADCSRA, ADIF			; 
Andencon:
		sbis	ADCSRA, ADIF			; Vent på A/D konverteren
		rjmp	Andencon
		in		R16,	ADCL
		out		UDR,	R16
		cbi		ADCSRA,	ADSC			; clear ADSC bit ( conversion)	
		cbi		ADCSRA, ADIF			; 

		ldi		R17,	17
		mov		R22,	R16
		add		R22,	R17				; høj høj værdi

		ldi		R17,	5
		mov		R24,	R16
		add		R24,	R17				; høj lav værdi

		ldi		R17,	5
		mov		R25,	R16
		sub		R25,	R17				; lav høj værdi

		ldi		R17,	20
		mov		R23,	R16
		sub		R23,	R17				; lav lav værdi	
		sbi		ADCSRA,	ADIE

;-------------------------------------
;		Tabel til test
;-------------------------------------

;		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
;		ldi		ZH,		high(Table)		; Henter tebellens høje adressen
			
;		ldi		R16,	41	
;		st		Z+,		R16
;		ldi		R16,	0	
;		st		Z+,		R16
;		ldi		R16,	93	
;		st		Z+,		R16
;		ldi		R16,	0	
;		st		Z+,		R16
;		ldi		R16,	190	
;		st		Z+,		R16
;		ldi		R16,	0	
;		st		Z+,		R16
;		ldi		R16,	91	
;		st		Z+,		R16
;		ldi		R16,	0	
;		st		Z+,		R16
;		ldi		R16,	129	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	69	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	58	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	59	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	35	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	85	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	52	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	42	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	45	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	147	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	18	
;		st		Z+,		R16
;		ldi		R16,	1	
;		st		Z+,		R16
;		ldi		R16,	254	
;		st		Z+,		R16
;		ldi		R16,	254	
;		st		Z+,		R16	
		
;		sei
;		ldi		R17, 0b01000000
;		out		GIFR,R17
;		ldi		R20,	0
;		ldi		R16,	85
;		out		OCR2,	R16	

;Ventevente:
;		rjmp	Ventevente

;Maalstreg:
;		cpi		R20,	0x01			; Er dette første runde?
;		brsh	Lap						; Nej hop til lap.
		
;------ Opmålings runde ---------------

;		Finder tabellen
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen

		ldi		R20,	0x00			; Lap værdi

		ldi		R16,	95
		out		OCR2,	R16

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
		out		UDR,	R16
;		Gemmer i tabellen
		st		Z+,		R16				; Gemmer R17 i tabellen, +1
		st		Z+,		R17				; Gemmer R18 i tabellen, +1

;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16	
		ret		

;---------------------------------------

Maalstreg:
;		Pas på målstregs- sensoren ikke interrupter sig selv.
		cpi		R20,	0x01			; Er dette første runde?
		brsh	Lap						; Nej hop til lap.
		call	Counter1				; Gemmer og resetter counteren
		cbi		ADCSRA,	ADIE			; Uenabler ADC interrupt

Sidste:
		ldi		R16,	0xFE			; Værdien 0xFE bruges som afslutningsværdi
		ldi		R17,	0xFE			; Værdien 0xFE bruges som afslutningsværdi

;		out		UDR,	R16				; Sender R17 til Bluetooth
;		out		UDR,	R17				; Sender R17 til Bluetooth
		
;		Gemmer i tabellen
		st		Z+,		R16				; Gemmer R16 i tabellen, +1
		st		Z+,		R17				; Gemmer R17 i tabellen, +1

Race:

;		ldi		R16,	0b00000000		; Enable udekommende interrupts
;		out		GICR,	R16				; Enabler INT0
;		out		MCUCR,	R16				; Register for INT1
;		out		GIFR,	R16


;------ Register forbrug --------------

;		R16-R17							; Temp registers
;		R18-R19							; Gammel længde
;		R20								; Lap Counter
;		R21								; Tjekker om bilen accelere
;		R22								; Stykke Counter
;		R23								; Acceleration
;		R24-R25							; Ny længde	
;		R26-R30							; Pointers

;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16	

; ----- Race start ---------------------
		ldi		R22,	0x00			; Stykke værdi

;		Sæt pointer Z
		ldi		ZL,		low(Table)		; Henter tabellens lave adressen
		ldi		ZH,		high(Table)		; Henter tebellens høje adressen

Lap:
;-------- Race setup ------------------

;		Rundecounter 
		inc		R20						; Inkremitere runde-counteren

;		sei
;		cpi		R20,	2
;		brsh	Tilbage					; enable interrupt, da dette er disablet,
										; der ikke er forekommet nogen reti		
Stykke:
;------- Lige stykke -------------------
;		Henter den gamle længde værdi
		ld		R18,	Z+				; Læser fra tabellen, +1
		ld		R19,	Z+				; Læser fra tabellen, +1
		out		UDR,	R18
		inc		R22						; Optæller stykke værdien

;		Tester for målstreg
.include "ToStykker.asm"

		call	Udregning				; Udregner hvornår den skal bremser

		call	Accelerate				; Starter accelerations

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

Tilbage:
		reti

Brems2:
		cp		R17,	R18
		brsh	MatchB
		rjmp	WaitBrems
		
Wait2:
		call	Accelerate				; Accelerere bilen
		rjmp	Waitbrems				; Hopper tilbage til wait

MatchA:
		sbrs	R22,0					; Tjekker for lige eller sving stykke
		rjmp	Wait2					; Hopper til wait2 funktionen

		ldi		R16,	75				; Bremsehastigheden
		out		OCR2, 	R16
		rjmp	WaitBrems

MatchB:
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
		ldi		R16,	120
		out		OCR2,	R16
		ret	

