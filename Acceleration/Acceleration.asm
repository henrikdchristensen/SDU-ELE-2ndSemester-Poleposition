.include "m32adef.inc"

;------ Interrupt register ----------

.org	0x0000
		rjmp		RESET
.org	0x0014							; Compare Match interrupt Timer0
		rjmp		AccelerationInt
RESET:
;------ Inkluderet filer ------------

.include "Setup.asm"


;------	Acceleration ----------------
		sei
		ldi		R16,0
		out		OCR2,R16
Accelerate:	
;		call	Udregning
;		call	Nycounter
		in		R21,TIMSK
		ldi		R22,0b00000010
		eor		R21,R22
		out		TIMSK,R23
		ldi		R21,248
		out		OCR0,R21
		ldi		R21,0

AccelerateWait:
		rjmp	AccelerateWait		

AccelerationInt:		
		cpi		R21,255
		breq	AccelerateStop
		inc		R21
		out		OCR2,R21
		reti	

AccelerateStop:
		in		R21,TIMSK			;Timer reset
		ldi		R22,0b00000010
		eor		R21,R22
		out		TIMSK,R21
		ldi		R16,0
		out		OCR2,R16
		reti		
