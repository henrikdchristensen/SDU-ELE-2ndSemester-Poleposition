			ldi	R16,0					; start hastigheden!
			rjmp PWM

;			Tjekker 1. byte (SET 0x55) fra PC.
VentStart1:			
			sbis 	UCSRA, RXC		;Sætter flag for modtaget data
			rjmp 	VentStart1		;Jump tilbage og tjek igen
			in 		R16, UDR		;Læs modtaget data fra PC
			cpi 	R16, 0x55		;Tjek værdi
			breq 	VentStart2		;Jumper til ventStart2
			rjmp 	VentStart1		;Jumper tilbage ventStart1 og venter på signal fra PC

;			Tjekker 2. byte (kommando) fra PC.
VentStart2:			
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
	
