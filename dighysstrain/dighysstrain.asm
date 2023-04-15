;----------------------------------------------------------------------------
;	ATcounter.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp	RESET

;.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
;		jmp		Maalstreg

.org	0x0020							; A/D konverteren complete interrupt
		jmp		ADK	

.org	0x005D							; adresse = 42 + sum(Variabler) 
RESET:
;------ Inkluderet filer ------------

.include "Setup.asm"

;------------------------------------

Start:
		SEI								; Enabler alle interrupts
		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)
;		ldi		R19,	0x00
		ldi		R16,	0b11111111
		out		PORTB,	R16

Main:	
		rjmp	Main

;--------------------------------------

ADK:
		in		R16,	ADCL			; Bruger kun det lave byte
		in		R17,	ADCH			; Read High bits to R17
		
		out		UDR,	R16				; Tjekker værdien

		cpi		R19,	0x01			; Er register R19 sat?
		breq	No_Trigger				; gå til No_Trigger
	
		cpi		R16,	150				; Hvis signalet er højt nok
		brsh	High_Trigger			; gå til High_Trigger

		cpi		R16,	100				; Hvis signalet er lavere
		brlo	Low_Trigger

		cbi		ADCSRA,	ADIF			; Clear ADC-flag, så den resetter
		reti

;--------------------------------------

High_Trigger:
		ldi		R16,	0b11110000
		com		R16
		out		PORTB,	R16
		ldi		R19,	0x01			; Sætter R19
		reti

Low_Trigger:
		ldi		R16,	0b00001111
		com		R16
		out		PORTB,	R16
		ldi		R19,	0x01			; Sætter R19
		reti

No_Trigger:
		cpi		R16,	150				; Sammenling ADC med High
		brlo	ClearR19
		
		cpi		R16,	100				; Sammenling ADC med Low
		brsh	ClearR19
		reti


ClearR19:
		ldi		R19,	0x00
		com		R19
		out		PORTB,	R19
		reti
