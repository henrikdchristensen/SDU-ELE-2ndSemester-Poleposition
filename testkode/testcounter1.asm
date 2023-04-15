;----------------------------------------------------------------------------
;	Main.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp		RESET

;.org	0x000C
;		rjmp		Matchinterrupt		

.org	0x000E							; Adresse til timer1/counter1 compare match A
		rjmp		MatchA

.org	0x0010							; Adresse til timer1/counter1 compare match B
		rjmp		MatchB				

.org	0x002A
RESET:
;------ Inkluderet filer ------------

.include "Setup.asm"

;-------- Race mode --------------------
Race:
;------ Register forbrug ------------

;		R20								; Lap Counter
;		R26-R30							; Pointers

;		Ny interrupt fra counter setup
		ldi		R16,	0b00011000		; Enable MatchA- og MatchB-Interrupt
		out		TIMSK,	R16

;		Ny Timer1/Counter1 setup:
		ldi		R16,	0b00000010		; Normal, OC1A disconnected, normal, OC1B disconnected 
		out		TCCR1A,	R16
		ldi		R16,	0b00011111		; Fastpwm, Mode 14, Trigger på opadgående
		out		TCCR1B,	R16
		
;		ldi		R16,	0x06
;		ldi		R17,	0x00
;		out		ICR1L,	R16
;		out		ICR1H,	R17
		
		ldi		R16,	50
		ldi		R17,	0
		out		OCR1Al,	R16
		out		OCR1AH,	R17	
			
		ldi		R16,	100
		ldi		R17,	0
		out		OCR1Bl,	R16
		out		OCR1BH,	R17

; 		Set pwm duty cyle to 30%
		ldi		R16, 	60				; Styrer hastigheden
		out		OCR2, 	R16
					
		SEI
		                                                                   
Main:
		rjmp	Main

MatchA:
		ldi		R16, 	100				; Styrer hastigheden
		out		OCR2, 	R16
		reti

MatchB:
		ldi		R16, 	60				; Styrer hastigheden
		out		OCR2, 	R16
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16			
		reti

;Matchinterrupt:
;		reti
