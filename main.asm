.INCLUDE	"tn2313Adef.inc"

.macro load_out
	.message "no parameters"
.endm

.macro load_out_8_i_i
	ldi @0, @1
	out @2, @0
.endm

.cseg
.org 0x0000
rjmp init 


; ====== INCLUDING MODULES ======

.ifdef IRQ

.org 0x0001			; INT0
rjmp INT0_ISR
.org 0x0002			; INT1
rjmp INT1_ISR
.org 0x0003			; TIM1_CAPT
rjmp TIM1_CAPT_ISR
.org 0x0004			; TIM1_COMPA 
rjmp TIM1_COMPA_ISR
.org 0x0005			; TIM1_OVF 
rjmp TIM1_OVF_ISR
.org 0x0006			; TIM0_OVF
rjmp TIM0_OVF_ISR
.org 0x0007			; USART0_RX
rjmp USART0_RX_ISR
.org 0x0008			; USART0_UDRE 
rjmp USART0_UDRE_ISR
.org 0x0009			; USART0_TX 
rjmp USART0_TX_ISR
.org 0x000A			; ANALOG_COMP 
rjmp ANALOG_COMP_ISR
.org 0x000B			; PCINT0
rjmp PCINT0_ISR
.org 0x000C			; TIM1_COMPB
rjmp TIM1_COMPB_ISR
.org 0x000D			; TIM0_COMPA
rjmp TIM0_COMPA_ISR
.org 0x000E			; TIM0_COMPB
rjmp TIM0_COMPB_ISR
.org 0x000F			; USI_START 
rjmp USI_START_ISR
.org 0x0010			; USI_OVF
rjmp USI_OVF_ISR
.org 0x0011			; EE_READY 
rjmp EE_READY_ISR
.org 0x0012			; WDT_OVF
rjmp WDT_OVF_ISR
.org 0x0013			; PCINT1
rjmp PCINT1_ISR
.org 0x0014			; PCINT2
rjmp PCINT2_ISR

INT0_ISR:
	reti
INT1_ISR:
	reti
TIM1_CAPT_ISR:
	reti
TIM1_COMPA_ISR:
	reti
TIM1_OVF_ISR:
	reti
TIM0_OVF_ISR:
	reti
USART0_RX_ISR:
	reti
USART0_UDRE_ISR:
	reti
USART0_TX_ISR:
	reti
ANALOG_COMP_ISR:
	reti
PCINT0_ISR:
	reti
TIM1_COMPB_ISR:
	reti
TIM0_COMPA_ISR:
	reti
TIM0_COMPB_ISR:
	reti
USI_START_ISR:
	reti
USI_OVF_ISR:
	reti
EE_READY_ISR:
	reti
WDT_OVF_ISR:
	reti
PCINT1_ISR:
	reti
PCINT2_ISR:
	reti

init_interrupts:
	; Set up INT0 and INT1 interrupts based on defined symbols
	load_out [r16, (1 << INT1) | (1 << INT0), GIMSK]	
	mov r18, r16
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

	;Set up PCINT0, PCINT1 and PCINT2 interrupts
	ldi r17, (1 << 5) | (1 << 4) | (1 << 3)
	or r18, r17
	out GIMSK, r18 
	
	sei
	ret

.endif

.INCLUDE "strings.asm"

.ifdef UART
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

; TODO: implement this shit
putstring:
	lpm r17, Z+
	cpi r17, 0			; check if the character is null	
	breq putstring_end
putstring_wait:
	; lds r17, UCSR0A
putstring_end:
	ret

.endif

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

.ifdef EEPROM

; r16 - Content to put at a given EEPROM address
; r17 - EEPROM address to write to
eeprom_write:
	sbic EECR, EEPE
	rjmp eeprom_write
	; Set Programming mode
	load_out [r16, (1 << EEPM1), EECR]
	out EEAR, r17
	out EEDR, r19
	sbi EECR, EEMPE
	sbi EECR, EEPE
	ret

; r17 - EEPROM Address to read
eeprom_read:		; -> outputs to r16 
	sbic EECR, EEPE
	rjmp EEPROM_read
	out EEAR, r17
	sbi EECR, EERE
	in r16, EEDR
	ret
.endif

.message "Processing: main.asm"

init:
loop:
	.ifdef IRQ
		rcall init_interrupts
	.endif
	.ifdef UART
		rcall init_uart
	.endif
	.ifdef SPI
		rcall init_spi
	.endif
	rjmp loop
