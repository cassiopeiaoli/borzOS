.INCLUDE	"tn2313Adef.inc"

.cseg
.org 0x0000

.ifdef UART
rcall init_uart
.endif

.ifdef SPI
rcall init_spi
.endif
rjmp loop

.INCLUDE 	"utils.asm"
.INCLUDE	"uart.asm"
.INCLUDE	"spi.asm"
.INCLUDE	"interrupts.asm"

.message "Processing: main.asm"

loop:
	rjmp loop
