.INCLUDE "tn2313Adef.inc"
.ifndef _UART_ASM_
.define _UART_ASM_

.equ		UART_BAUDRATE		= 9600	
.equ		BAUD_PRESCALE		= (8000000/16/UART_BAUDRATE) - 1
.message "Processing: uart.asm"

init_uart:
	; Set baudrate
	ldi r16, LOW(BAUD_PRESCALE)
	ldi r17, HIGH(BAUD_PRESCALE) 
	out UBRRH, r17
	out UBRRL, r16

	; Enable UART
	ldi r16, (1 << RXEN) | (1 << TXEN)
	out UCSRB, r16
	
	; Frame format: 8bit data, 1 stop bit
	ldi r16, (0 << USBS) | (3 << UCSZ0) 
	out UCSRC, r16
	ret

deinit_uart:
	; Reset baudrate
	ldi r16, 0
	out UBRRH, r16 
	out UBRRL, r16 

	; Disable TX and RX
	ldi r16, (0 << RXEN) | (0 << TXEN)
	out UCSRB, r16

	; Remove frame data
	ldi r16, (0 << USBS) | (0 << UCSZ0)
	out UCSRC, r16

	ret

; Argument: r16 - data
uart_transmit:
	sbis UCSRA, UDRE	; wait for the tx buffer to be empty
	rjmp uart_transmit
	out UDR, r16
	ret	

; Data gets put in r16
uart_receive:
	sbis UCSRA, RXC		; wait for the receive buffer to be empty
	rjmp uart_receive
	in r16, UDR
	ret

.endif
