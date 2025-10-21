.INCLUDE "tn2313Adef.inc"

.ifndef _SPI_ASM_
.define _SPI_ASM_

.message "Processing: spi.asm"

.INCLUDE "utils.asm"

init_spi:
	load_out [r16, (1 << PB7) | (1 << PB6), DDRB]
	load_out [r16, (1 << USIWM0) | (1 << USICS1) | (1 << USICLK), USICR]
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
