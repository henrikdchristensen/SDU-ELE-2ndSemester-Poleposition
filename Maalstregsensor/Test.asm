.include "m32adef.inc"

.org	0x0000
		rjmp	RESET

.org	0x0002							; Udekommende interrupt, INT0, PORTD.2
		jmp		Maalstreg
.org	0x002A							; adresse 42
RESET:

;		Stack upsetting
		ldi		R16,	HIGH(RAMEND)	; 
		out		SPH,	R16				; 
		ldi		R16,	LOW(RAMEND)		;
		out		SPL,	R16	

Start:
		SEI								; Enabler alle interrupts
;		Interrupt fra input setup:
		cbi		DDRD,	2				; Sætter input på PORTD.2
		sbi		PORTD,	2				 
		ldi		R16,	0b01000000		; Enable udekommende interrupts
		out		GICR,	R16				; Enabler INT0
		ldi		R16,	0b00000011		; Indgang trigger på opadgående flanke
		out		MCUCR,	R16		

; 		setup timer2 fast pwm mode
; 		no prescaling, start pwm
		ldi		R16, 	0b01101010		; Normal mode, Fast pwm, , clk / 8 (ca. 7812 Hz)
		out		TCCR2, 	R16				; ER TJEKKET!!!
		sbi		DDRD,	7				; Sætter PORTD.7 til output
		cbi		PORTD,	7


;		Bluetooth Setup:
		ldi		R16,	00				; Den høje del bruges ikke
		out		UBRRH,	R16			
		ldi		R16,	207				; UBBR=207 (begrund for 9600 baudrate, 0.2% error
		out		UBRRL,	R16			
		ldi		R16,	0b00000010		; Double USART transmission speed(U2X)
		out		UCSRA,	R16
		ldi		R16,	0b00011000		; Enable receiver / enable Transmission
		out		UCSRB,	R16
		ldi		R16,	0b10000110		; 8bit, no parity, 1 stop bit
		out		UCSRC,	R16			

		ldi		R18,0

; 		Set pwm duty cyle to 30%
		ldi		R16, 	80				; Styrer hastigheden
		out		OCR2, 	R16

		Main:
		sbis	UCSRA,	RXC
		rjmp	Main
		in		R16,	UDR
		Cpi		R16,	0x01
		breq	Taeller
		cpi		R16,	2
		breq	Nulstil
		rjmp	Main					; laver ingenting


Maalstreg:
		inc		R18
		Reti

Taeller:
		out		UDR,	R18
		rjmp	Main

Nulstil:
		ldi		R18,0
		rjmp	Main
