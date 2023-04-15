; ***********************************
; Test af Bilboard 2 semester
; ***********************************

.include 	"m32adef.inc" 				; The ATMEGA32A Microcontroller

.org		0x0000						; Program execution is started at address: 0
			rjmp 	Reset

.org 		0x002A 	
Reset: 		ldi 	R16,HIGH(RAMEND) 	; Stack setup
			out 	SPH,R16 			; Load SPH
			ldi 	R16,LOW(RAMEND)		;
			out 	SPL,R16 			; Load SPL

			; PORTD setup
			Ldi		R16, 0x80
			sbi 	DDRD,7 				; PORTD[7]  = output
			cbi		PORTD, 7			; Turn Switch off
						
			; Set pwm duty cyle to 20%
			ldi		R16, 0x30
			out		OCR2, R16
			
			; setup timer2 fast pwm mode
			; no prescaling, start pwm
			ldi		R16, 0b01101010
			out		TCCR2, R16

			; USART_Init
			; Set baud rate to 9600 @ cpu Freq = 16 Mhz.
			LDI		R17, 00
			LDI 	R16, 207
			out 	UBRRH, r17
			out 	UBRRL, r16
			; Double the USART Transmission Speed
			sbi		UCSRA, 1
			; Set frame format: 8data, 1 stop bit
			ldi 	r16, (1<<URSEL)|(3<<UCSZ0)
			out 	UCSRC,r16
			; Enable receiver and transmitter
			ldi 	r16, (1<<RXEN)|(1<<TXEN)
			out 	UCSRB,r16
			
			; Send char to UART
			ldi		R16 , 0x32
			out		UDR, R16
 		
			;USART_Receive:
			; Wait for data to be received
Loop:		sbis 	UCSRA, RXC
			rjmp	loop
			in 	 	r16, UDR		; get received char
			out	 	UDR, r16		; echo received char back to sender

			; set new duty cycle
			cpi		R16, 0x30
			brbs	SREG_Z, out_0
			cpi		R16, 0x35
			brbs	SREG_Z, out_50
			cpi		R16, 0x39
			brbs	SREG_Z, out_90
			rjmp	loop

out_0:		ldi		R16, 0x00
			rjmp	set_pwm
out_50:		ldi		R16, 0x7F
			rjmp	set_pwm
out_90:		ldi		R16,0xE5

set_pwm:	out		OCR2, R16
			rjmp	loop

			rjmp 	Loop 				; Jump to Loop label
