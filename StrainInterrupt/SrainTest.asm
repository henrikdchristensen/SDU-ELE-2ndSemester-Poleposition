;----------------------------------------------------------------------------
;	StrainTest.asm VIRKER! på ATMEGA32 Board
;----------------------------------------------------------------------------
.include "m32adef.inc"


;------ Interrupt register ----------

.org	0x0000
		rjmp	RESET

.org	0x0014							; Compare Match interrupt Timer0
		rjmp	Counter

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

;------------------------------------

Start:

		SEI								; Enabler alle interrupts
; 		Set pwm duty cyle to 30%
		ldi		R16, 	80				; Styrer hastigheden
		out		OCR2, 	R16
		ldi		R22,0b00000010
		out		TIMSK,R22
		ldi		R21,255
		out		OCR0,R21
;		Starter ADC
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)
		

Main:	
		rjmp	Main

ADK:
		in		R16,	ADCL			
		in		R17,	ADCH			; Read High bits to R17
		sbi		ADCSRA, ADSC
		cbi		ADCSRA,	ADIF			;Clear ADIF flag
		reti

Counter:
		out		UDR,	R16
		reti
