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

									; Enabler alle interrupts
; 		Set pwm duty cyle to 30%
		ldi		R16, 	0				; Styrer hastigheden
		out		OCR2, 	R16
			
;		Starter ADC
		cbi		ADCSRA, ADIE		
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)
		
;		ldi		R16,	0b00000010
;		out		TIMSK,	R16

;		ldi		R21,	124
;		out		OCR0,	R21
;		R21								; SvingHYS høj høj
;		R22								; SvingHYS høj lav
;		R23								; SvingHYS lav høj
;		R24								; SvingHYS lav lav
Home:
		in		R16,	UDR
		cpi		R16,	1
		breq	Calibrate
		rjmp	Home


Calibrate:
		sbis	ADCSRA, ADIF			; Vent på A/D konverteren
		rjmp	Calibrate		
		cbi		ADCSRA,	ADSC			; clear ADSC bit ( conversion)	
		cbi		ADCSRA, ADIF			; 
		in		R16,	ADCL
		out		UDR,	R16

		ldi		R17,	20
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

		ldi		R16, 	80				; Styrer hastigheden
		out		OCR2, 	R16
		
		sei	
		sbi		ADCSRA,	ADSC


Main:
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

;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16			; Sætter counteren til 0
		out		TCNT1H,	R16	
		reti	
