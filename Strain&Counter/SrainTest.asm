;----------------------------------------------------------------------------
;	StrainTest.asm VIRKER! på ATMEGA32 Board
;----------------------------------------------------------------------------
.include "m32adef.inc"


;------ Interrupt register ----------

.org	0x0000
		rjmp	RESET

;.org	0x0014							; Compare Match interrupt Timer0
;		rjmp	AccelerationInt

;.org	0x001A							; Bluetooth receive complete interrupt
;.org	0x001E							; Bluetooth transmit complete interrupt
;		jmp		Main

.org	0x0020							; A/D konverteren complete interrupt
		jmp		ADK

;------------------------------------

.org	0x002A							; adresse 42
RESET:

;------ Inkluderet filer ------------

.include "Setup.asm"
.def		TurnFlag=R21
;------------------------------------

Start:

		SEI								; Enabler alle interrupts
; 		Set pwm duty cyle to 30%
		ldi		R16, 	80				; Styrer hastigheden
		out		OCR2, 	R16
			
;		Starter ADC
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)
		
;		ldi		R16,	0b00000010
;		out		TIMSK,	R16

;		ldi		R21,	124
;		out		OCR0,	R21
		ldi		R22,	160
		ldi		R23,	104
		ldi		R24,	145
		ldi		R25,	135


Main:
		sbis	UCSRA,	RXC
		rjmp	Main
		in		R16,	UDR
		
		cpi		R16,1
		breq	CompareH

		cpi		R16,2
		breq	CompareL

		cpi		R16,3
		breq	Fart

		cpi		R16,4
		breq	CompareH2

		cpi		R16,5
		breq	CompareL2

		rjmp	Main

CompareH:
		sbis	UCSRA,	RXC
		rjmp	CompareH
		in		R22,	UDR
		rjmp	Main

CompareH2:
		sbis	UCSRA,	RXC
		rjmp	CompareH2
		in		R24,	UDR
		rjmp	Main

CompareL:
		sbis	UCSRA,	RXC
		rjmp	CompareL
		in		R23,	UDR
		rjmp	Main

CompareL2:
		sbis	UCSRA,	RXC
		rjmp	CompareL2
		in		R25,	UDR
		rjmp	Main

Fart:
		sbis	UCSRA,	RXC
		rjmp	Fart
		in		R26,	UDR
		out		OCR2,	R26
		rjmp	Main

ADK:
		in		R16, ADCL
		in		R17, ADCH
		sbi		ADCSRA, ADSC
		cbi		ADCSRA,	ADIF

		cpi		TurnFlag, 1
		breq	InTurn1

		cp		R16,R22
		brsh	Turn

		cp		R16,R23
		brlo	Turn

		reti

Turn:
		ldi 	TurnFlag, 1
		rjmp	Counter1

InTurn1:
		cp		R16, R24
		brlo	InTurn2
		reti
InTurn2:
		cp		R16, R25
		brsh	InTurn3
		reti

InTurn3:
		ldi		TurnFlag, 0
		reti
				
Counter1:
		in		R17,	TCNT1L			; Gemmer counterens nuværende værdi
		in		R18,	TCNT1H
		
		out		UDR,	R17
		out		UDR,	R18

;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16			; Sætter counteren til 0
		out		TCNT1H,	R16	
		reti	
