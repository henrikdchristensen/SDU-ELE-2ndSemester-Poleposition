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

;.org	0x0020							; A/D konverteren complete interrupt
;		jmp		ADK	

;------------------------------------

.org	0x002A							; adresse 42
RESET:

;------ Inkluderet filer ------------

.include "Setup.asm"

;------------------------------------

Start:

;		SEI								; Enabler alle interrupts
; 		Set pwm duty cyle to 30%
		ldi		R16, 	80				; Styrer hastigheden
		out		OCR2, 	R16
			
; 		setup timer2 fast pwm mode
; 		no prescaling, start pwm
		ldi		R16, 	0b01101010		; Normal mode, Fast pwm, , clk / 8
		out		TCCR2, 	R16		
;		Starter ADC
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)
		
		ldi		R16,	0b00000010
		out		TIMSK,	R16

;		ldi		R21,	124
;		out		OCR0,	R21

Main:	
		sbis	ADCSRA,	ADIF
		rjmp	Main
		sbi		ADCSRA,	ADIF
		in		R16,	ADCL			
		in		R17,	ADCH			; Read High bits to R17
		out		UDR,	R16
		rjmp	Main		

;		sbi		ADCSRA,ADSC	
;		out		UDR,	R17				; Skriver høj værdi til PC
;AccelerationInt:
;		out		UDR,	R16				; Skriver lav værdi til PC
;		sbi		ADCSRA, ADSC
;		reti
