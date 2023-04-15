;	----------------------------------------------------------------------------
;	Setup.asm
;	----------------------------------------------------------------------------
;
; Kort beskrivelse:
;
; Porte er som default sat til 0, så de virker som input.
;
; Interrupt Setup, for opadgående input på PORTD 2
;
; PORT B.1, input pin sat til Counter1
;
; Bluetooth sat op til 9600 baudrate, 8 bit, no parity, 1 stop bit
;
; ADC med prescale på 8 på PORTA.1 (tjek op)

;		Stack upsetting
		ldi		R16,	HIGH(RAMEND)	; 
		out		SPH,	R16				; 
		ldi		R16,	LOW(RAMEND)		;
		out		SPL,	R16				;

		push	R16
; 		setup timer2 fast pwm mode
; 		no prescaling, start pwm
		ldi		R16, 	0b01101010		; Normal mode, Fast pwm, , clk / 8 (ca. 7812 Hz)
		out		TCCR2, 	R16				; ER TJEKKET!!!
		sbi		DDRD,	7				; Sætter PORTD.7 til output
		cbi		PORTD,	7
		
;		Interrupt fra input setup:
;		cbi		DDRD,	2				; Sætter input på PORTD.2
;		cbi		PORTD,	2				 
;		ldi		R16,	0b00000100		; Enable udekommende interrupts
;		out		GICR,	R16				; Enabler INT0
;		ldi		R16,	0b00000011		; Indgang trigger på opadgående flanke
;		out		MCUCR,	R16				; Register for INT1
		
;		Timer0/Counter0 setup:			
;		ldi		R16,	0b00101011
;		out		TCCR0,	R16

;		Timer1/Counter1 setup:
		cbi		DDRB,	0x01			; Opsættes til indgang PORTB.1
		ldi		R16,	0b00000000		; Normal mode, ER TJEKKET!!
		out		TCCR1A,	R16
		ldi		R16,	0b00000111		; Trigger på opadgående
		out		TCCR1B,	R16
		
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

;		A/D konvertering setup:
		cbi		DDRA,	1		
		ldi		R16,	0b11001111		; Enable ADC, Enable ADC interrupt, prescaler 8
		out		ADCSRA,	R16				; Load ADCSRA
		ldi		R16,	0b01000001 		; 5V ref, right-justified, PA1
		out		ADMUX,	R16				; Load ADMUX

		pop		R16

