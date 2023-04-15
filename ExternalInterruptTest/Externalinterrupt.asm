;----------------------------------------------------------------------------
;	ExternalInterrupt.asm VIRKER!
;----------------------------------------------------------------------------
.include "m32adef.inc"


;------ Interrupt register ----------

.org	0x0000
		rjmp	RESET

.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
		jmp		Maalstreg

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
		SEI								; Enabler alle interrupts
		ldi		R26,	0x00
; 		Set pwm duty cyle to 30%
		ldi		R16, 	0			; Styrer hastigheden
		out		OCR2, 	R16

Main:
		sbis	UCSRA,	RXC
		rjmp	Main
		in		R16,	UDR
		Cpi		R16,	0x01
		breq	Nisser
		cpi		R16,	2
		breq	Nulstil
		cpi		R16,	3
		breq	Fart
		rjmp	Main					; laver ingenting


Maalstreg:
		inc		R26
		Reti

Nisser:
		out		UDR,	R26
		ret

Nulstil:
		ldi		R26,0
		ret

Fart:
		sbis	UCSRA,	RXC
		rjmp	Main
		in		R16,	UDR
		out		OCR2,	R16
		ret
