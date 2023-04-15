;----------------------------------------------------------------------------
;	ATcounter.asm
;----------------------------------------------------------------------------
.include "m32adef.inc"
;
; Send 1 for at gå counterens nuværende værdi
;
; Send 2 for at resætte counteren
;
; Send 3 hvorefter for at vælge hastighed
;
; 
;------ Interrupt register ----------

.org	0x0000
		rjmp		RESET

;.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
;		jmp		Maalstreg

.org	0x005D							; adresse = 42 + sum(Variabler) 
RESET:
;------ Inkluderet filer ------------


.include "Setup.asm"

;------------------------------------

Start:
;		SEI								; Enabler alle interrupts
;		sbi		ADCSRA,	ADSC			; Set ADSC bit (starter conversion)

;--------------------------------------

; 		Set pwm duty cyle to 30%
		ldi		R16, 	0x00			; Styrer hastigheden
		out		OCR2, 	R16
		
Main:
		sbis	UCSRA,	RXC
		rjmp	Main

		in		R16,	UDR
	
		cpi		R16,	1
		breq	Counter1

		cpi		R16,	2
		breq	Reset_counter1

		cpi		R16,	3
		breq	Hastighed
		rjmp	Main
	


;--------------------------------------

Counter1:
		in		R16,	TCNT1L			; Gemmer counterens nuværende værdi
		in		R18,	TCNT1H	

		out		UDR,	R16
		out		UDR,	R18
		rjmp	Main
;--------------------------------------

Reset_counter1:
		ldi		R16,	0x00			
		out		TCNT1L,	R16				; Sætter counteren til 0
		out		TCNT1H,	R16	
		rjmp	Main	

;--------------------------------------

Hastighed:
		out		UDR,	R16
hast:
		sbis	UCSRA,	RXC
		rjmp	Hast

		in		R16,	UDR
		out		UDR,	R16
		out		OCR2,	R16
		rjmp	Main

;--------------------------------------

;Maalstreg:
;		rjmp	Counter1				; Gemmer og resetter counteren
;		reti
