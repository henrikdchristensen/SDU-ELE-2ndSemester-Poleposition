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

			ldi		R16,103				;UBBR=207 for 9600 baudrate, 0.16% error og 16 MHz
			out		UBRRL,R16			

			ldi		R16,(0<<U2X)		;Double USART transmission speed(U2X)
			out		UCSRA,R16

			ldi		R16,0b00011000		;enable receiver / enable Transmission
			out		UCSRB,R16

			ldi		R16,0b10000110		;8bit, no parity, 1 stop bit
			out		UCSRC,R16			
			
			sbi		DDRD,7					;PD7 = output
			cbi		PORTD,7
			ldi		R16, 0b01101010			;preclae 8
			out		TCCR2, R16				;COM1A = non-inverted

			ldi	R16,0					; start hastigheden!
			rjmp PWM


VentStart1:				;Tjekker 1. byte (SET 0x55) fra PC.
			sbis 	UCSRA, RXC		;Sætter flag for modtaget data
			rjmp 	VentStart1		;Jump tilbage og tjek igen
			in 		R16, UDR		;Læs modtaget data fra PC
			cpi 	R16, 0x55		;Tjek værdi
			breq 	VentStart2		;Jumper til ventStart2
			rjmp 	VentStart1		;Jumper tilbage ventStart1 og venter på signal fra PC

VentStart2:				;Tjekker 2. byte (kommando) fra PC.
			sbis 	UCSRA, RXC		;Sætter flag for modtaget data
			rjmp 	VentStart2		;Jumper tilbage til ventStart2
			in 		R16, UDR		;Læser 2. byte ind i R16
			cpi 	R16, 0x10 		;0x10 for Start kommando
			breq 	Start			;Brancher hvis byten er 0x10
			cpi 	R16, 0x11 		;0x11 for Stop kommando
			breq 	Stop			;Brancher hvis byten er 0x11
			cpi 	R16, 0x12		;0x12 for Automode
			breq 	Automode		;Brancher hvis byten er 0x12
			rjmp 	VentStart1


Start:
			sbis	UCSRA,RXC		;Sætter flag for modtaget data
			rjmp	Start			;Jumper tilbage til ventStart2
			in		R16,UDR			;Læser 3. byte ind i R16
			lsr		R16				;Dividerer R16 med 2
			ldi		R17, 5			;Loader 5 ind i R17
			mul		R16, R17		;Ganger R16 med R17
			movw	R16, R0			;Kopierer det lave resultat ind i R16
			rjmp	PWM				;Jumper til PWM

Stop:
			ldi		R16,0			;Sætter start værdien til 0
			rjmp	PWM				;Jumper til PWM

PWM:		
			out		OCR2,R16		;Skriver værdien til motoren
			rjmp	VentStart1		;Jumper tilbage til VentStart1 for at modtage ny signal

Automode:	
			ret
