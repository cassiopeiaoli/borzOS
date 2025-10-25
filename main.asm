.INCLUDE	"tn2313Adef.inc"

.cseg
.org 0x0000

.macro load_out
	.message "no parameters"
.endm

.macro load_out_8_i_i
	ldi @0, @1
	out @2, @0
.endm

rjmp loop

; ====== INCLUDING MODULES ======

.ifdef UART
; Init UART
.equ		UART_BAUDRATE		= 9600	
.equ		BAUD_PRESCALE		= (8000000/16/UART_BAUDRATE) - 1

init_uart:
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

; TODO: implement this shit
putstring:
	lpm r17, Z+
	cpi r17, 0			; check if the character is null	
	breq putstring_end
putstring_wait:
	lds r17, UCSR0A
putstring_end:
	ret

.ifdef SPI

.define CLK		PB7
.define DO 		PB6
.define DI 		PB5
.define CS_PIN	PB4

init_spi:
	; set CLK, DO as output and DI as input
	load_out [r16, (1 << CLK) | (1 << DO), DDRB]
	load_out [r16, (0 << DI), DDRB]

	; set USI for three wire mode
	load_out [r16, (1 << USIWM0) | (1 << USICS1) | (1 << USICLK), USICR]
	load_out [r16, (1 << CS_PIN), DDRB]
	ret

spi_transmit:
	out USIDR, r16
	ldi r16, (1 << USIOIF)
	out USISR,  r16
	ldi r17, (1 << USIWM0) | (1 << USICS1) | (1 << USICLK) | (1 << USITC)	
spi_transmit_loop:
	out USICR, r17
	in r16, USISR
	sbrs r16, USIOIF
	rjmp spi_transmit_loop
	in r16, USIDR
	ret
.endif

.ifdef IRQ

init_interrupts:
	; Set up INT0 and INT1 interrupts based on defined symbols
	ldi r16, 0
	.ifdef INT0_LL
	ldi r16, (0 << ISC01) | (0 << ISC00)
	.endif
	.ifdef INT0_LC
	ldi r16, (0 << ISC01) | (1 << ISC00)
	.endif
	.ifdef INT0_FE
	ldi r16, (1 << ISC01) | (0 << ISC00)
	.endif
	.ifdef INT0_RE
	ldi r16, (1 << ISC01) | (1 << ISC00)
	.endif
	.ifdef INT1_LL
	ldi r17, (0 << ISC11) | (0 << ISC10)
	.endif
	.ifdef INT1_LC
	ldi r17, (0 << ISC11) | (1 << ISC10)
	.endif
	.ifdef INT1_FE
	ldi r17, (1 << ISC11) | (0 << ISC10)
	.endif
	.ifdef INT1_RE
	ldi r17, (1 << ISC11) | (1 << ISC10)
	.endif
	or r16, r17
	out MCUCR, r16
	
	sei
	ret
.endif

.message "Processing: main.asm"

loop:
	rjmp loop
