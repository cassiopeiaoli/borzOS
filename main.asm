.INCLUDE	"tn2313Adef.inc"

.cseg
.org 0x0000

.ifdef UART
.INCLUDE	"uart.asm"
rcall init_uart
.endif

.ifdef SPI
.INCLUDE	"spi.asm"
rcall init_spi
.endif
rjmp loop

.INCLUDE 	"utils.asm"

.ifdef IRQ
.INCLUDE	"interrupts.asm"
rcall init_interrupts
.endif

.message "Processing: main.asm"

loop:
	rjmp loop
