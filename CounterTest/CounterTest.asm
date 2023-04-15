;----------------------------------------------------------------------------
;	Tælletest.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp		RESET

;.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
;		jmp		Maalstreg

;.org	0x0004							; Udekommende interrupt, INT1, PORTD.3
;.org	0x0006							; Udekommende interrupt, INT2, PORTB.2

;.org	0x001A							; Bluetooth receive complete interrupt
;.org	0x001E							; Bluetooth transmit complete interrupt

.org	0x0020							; A/D konverteren complete interrupt
		jmp		ADK	

;------------------------------------

.org	0x002A							; adresse 42


.dseg;- Variabler -------------------

Data1:	.byte 1							; oprettet variabler
Table:	.byte 50						; opretter table

.cseg;-------------------------------

.org	0x005D							; adresse = 42 + sum(Variabler) 
RESET:
;------ Inkluderet filer ------------

.include "Setup.asm"

;------ Definitioner ----------------

;.def	temp	= R16

;------------------------------------

.equ	H		= 0xFF
.equ	L		= 0x00

;------------------------------------

Start:
		ldi		R19,	0x00			; Set R19 til 0
;		Finder tabellen
		SEI								; Enabler alle interrupts
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)

;------ Bilens hastighed ------------

; 		Set pwm duty cyle to 30%
		ldi		R16, 	0x4C			; Styrer hastigheden
		out		OCR2, 	R16
			
; 		setup timer2 fast pwm mode
; 		no prescaling, start pwm
		ldi		R16, 	0b01101010		; Normal mode, Fast pwm, , clk / 8
		out		TCCR2, 	R16		

;------------------------------------

Main:
		rjmp	Main

;--------------------------------------

ADK:
		in		R16,	ADCL			
		in		R17,	ADCH			; Read High bits to R17

		cpi		R19,	0x01			; Er register R19 sat?
		breq	No_Trigger				; gå til No_Trigger

		cpi		R16,	H				; Hvis signalet er højt nok
		brge	High_Trigger			; gå til High_Trigger
		
		cpi		R16,	L				; Hvis signalet er lavere
		brlt	Low_Trigger

		cbi		ADCSRA,	ADIF			; Clear ADC-flag, så den resetter
		reti

;--------------------------------------

High_Trigger:
		rjmp	Counter1				; Gemmer og resetter counteren
		ldi		R19,	0x01			; Sætter R19
		reti

Low_Trigger:
		rjmp	Counter1				; Gemmer og resetter counteren
		ldi		R19,	0x01			; Sætter R19
		reti

No_Trigger:
		cpi		R16,	H				; Sammenling ADC med High
		brlt	ClearR19
		brlt	Counter1				; Hvis ADC er lavere, gem og reset counteren
				
		cpi		R16,	L				; Sammenling ADC med Low
		brge	ClearR19
		brge	Counter1				; Hvis ADC er højere, gem og reset counteren

		reti

;---------------------------------------

ClearR19:
		ldi		R19,	0x00			; Clear R19
		ret

;---------------------------------------

Counter1:
		in		R17,	TCNT1L			; Gemmer counterens nuværende værdi
		in		R18,	TCNT1H
		
		out		UDR,	R17
		out		UDR,	R18

;		Reset counter1
		ldi		R16,	0x00			
		out		TCNT1L,	R16			; Sætter counteren til 0
		out		TCNT1H,	R16	
		ret		
