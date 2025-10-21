.INCLUDE "tn2313Adef.inc"

.ifndef _SPI_ASM_
.define _SPI_ASM_

.define CLK		PB7
.define DO 		PB6
.define DI 		PB5
.define CS_PIN	5

.message "Processing: spi.asm"

.INCLUDE "utils.asm"

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
