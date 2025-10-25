all:
	avra main.asm --define EEPROM --define UART --define IRQ --define SPI -o borzos

uart:
	avra main.asm --define UART -o borzos

irq:
	avra main.asm --define IRQ -o borzos

spi:
	avra main.asm --define SPI -o borzos

spi_uart:
	avra main.asm --define SPI --define UART -o borzos

upload:
	minipro -p "ATTINY2313A@DIP20" -w borzos 
