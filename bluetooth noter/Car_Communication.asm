.include	"m32adef.inc"	;The ATEMEGA32A Microcontroller

.org		0x0000			;Program execution is started at address: 0
			rjmp	Reset

.org		0x002A
Reset:		ldi		R16,HIGH(RAMEND)	;Stack setup
			out		SPH,R16				;Load SPH
			ldi		R16,LOW(RAMEND)		;
			out		SPL,R16				;Load SPL

			ldi		R17,00
			out		UBRRH,R17

			ldi		R16,12				;UBBR=12 for 9600 baudrate, 0.2% error
			out		UBRRL,R16			

			ldi		R16,0b00000010		;Double USART transmission speed(U2X)
			out		UCSRA,R16

			ldi		R16,0b00011000		;enable receiver / enable Transmission
			out		UCSRB,R16

			ldi		R16,0b10000110		;8bit, no parity, 1 stop bit
			out		UCSRC,R16			

			ldi		R16,0xFF			;PORT B is output
			out		DDRB,R16
			out		PORTB,R16

Loop:
			sbis	UCSRA,RXC			;Are we receiving?
			rjmp	Loop

			in		R17,UDR				;Save received data in R17 from the UDR register

			com		R17
			out		PORTB,R17
			rjmp	Loop
