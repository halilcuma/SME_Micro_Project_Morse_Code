;Halil Cuma
.INCLUDE "m328pdef.inc" ; Load addresses of (I/O) registers
.ORG 0x0000
RJMP init	

.ORG 0x0020
RJMP Timer0OverFlowInterrupt

.EQU BUFFERBEGIN = 0x200


.DEF  DataLength =    R4
.DEF  Pattern    =    R5

init:

LDI R16, 0b00000100			;load Immediate 101 to R16(101: enable pre1024)
OUT TCCR0b, R16				; timrt counter control register

; set the correct reload values 238  
LDI R17, 185				;256-(16MH/256)/880= 184.9
OUT TCNT0, R17				; Timer counter register to initialization

; global interrupt enable
SEI		

LDI ZL,low(BUFFERBEGIN)
LDI ZH,high(BUFFERBEGIN)

LDI ZL, Low(CodeTable<<1)
LDI ZH, High(CodeTable<<1)

LPM DataLength,Z+
LPM Pattern, Z

SBI DDRB,1
SBI PORTB,1

SBI DDRC,2
SBI PORTC,2

SBI DDRC,3
SBI PORTC,3

CBI	DDRD,3 ;INPUT
CBI	DDRD,2
CBI DDRD,1
CBI DDRD,0

SBI DDRD,7 ;OUTPUT
SBI DDRD,6
SBI DDRD,5
SBI DDRD,4

SBI PORTD,3 ;PULL RESITOR 
SBI PORTD,2
SBI PORTD,1
SBI PORTD,0

RJMP MAIN
MAIN:


;SBI PORTC,3
;SBI PORTC,2

RJMP CYC1

CYC1:
CBI PORTD,7
SBI PORTD,6
SBI PORTD,5
SBI PORTD,4

SBIS PIND,0
RJMP BTNF
SBIS PIND,1
;RJMP BTN9
SBIS PIND,2
;RJMP BTN8
SBIS PIND,3
RJMP BTN7

RJMP CYC2

CYC2:
SBI PORTD,7
CBI PORTD,6
SBI PORTD,5
SBI PORTD,4

SBIS PIND,0
;RJMP BTNE
SBIS PIND,1
;RJMP BTN6
SBIS PIND,2
;RJMP BTN5
SBIS PIND,3
;RJMP BTN4


RJMP CYC3

CYC3:
SBI PORTD,7
SBI PORTD,6
CBI PORTD,5
SBI PORTD,4

SBIS PIND,0
;RJMP BTND
SBIS PIND,1
;RJMP BTN3
SBIS PIND,2
;RJMP BTN2
SBIS PIND,3
;RJMP BTN1


RJMP CYC4

CYC4:
SBI PORTD,7
SBI PORTD,6
SBI PORTD,5
CBI PORTD,4

SBIS PIND,0
;RJMP BTNC
SBIS PIND,1
;RJMP BTNB
SBIS PIND,2
;RJMP BTN0
SBIS PIND,3
;RJMP BTNA

RJMP MAIN


Delay:
	DEC R18
	BRNE Delay
RET



/*LDI R26,3
LDI R27,2
MUL R26,R27
ADD ZL,R0
ADC ZH,R1
LPM Pattern,Z+
LPM DataLength,Z*/


SendMores:
PUSH R18
	dotDashLoop:
		RCALL SendDD
		LDI R18, 50
		RCALL Delay
		DEC DataLength
		BRNE dotDashLoop
POP R18
RET

SendDD:
	ROR Pattern
	BRCC SendDot
	RJMP SendDash
RET
SendDot:
	SEI		
	CBI PORTC,2					; Turn ON LED3 
	LDI R16, 0x01				; 
	STS TIMSK0, R16				; Enable Overflow Interrupt
	LDI R18,50
	RCALL Delay
	SBI PORTC,2					; Turn OFF LED2
	LDI R16, 0x00				; 
	STS TIMSK0, R16				; Enable Overflow Interrupt
	CLI
RET

SendDash:
	SEI
	CBI PORTC,3						; Turn ON LED3
	LDI R16, 0x01				; 
	STS TIMSK0, R16				; Enable Overflow Interrupt

	LDI R18,150
	RCALL Delay

	LDI R16, 0x00				; 
	STS TIMSK0, R16				; Enable Overflow Interrupt
	SBI PORTC,3						; Turn OFF LED2
	CLI
RET



BTNF:
RCALL SendMores
RJMP MAIN

BTN7:
RCALL SendMores
RJMP MAIN


Timer0OverflowInterrupt:
	SBI PINB,1							; Toggle BUZZER 
	RETI								; Return to Calling location from Interrupt

CodeTable:
.db 5, 0b10101 ; [0] 
.db 5, 0b10101 ; [1] 
.db 5, 0b10101 ; [2] 
.db 5, 0b10101 ; [3] 
.db 5, 0b10101 ; [4] 
.db 5, 0b10101 ; [5] 
.db 5, 0b10101 ; [6] 
.db 5, 0b10101 ; [7]  
.db 5, 0b10101 ; [8] 
.db 5, 0b10101; [9] 
.db 5, 0b10101 ; [A] 
.db 5, 0b10101 ; [B] 
.db 5, 0b10101 ; [C] 
.db 5, 0b10101 ; [D] 
.db 5, 0b10101 ; [E] 
.db 5, 0b10101 ; [F] 
.db 5, 0b10101 ; [Blank]
