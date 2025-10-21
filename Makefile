all:
	avra main.asm -o borzos

upload:
	minipro -p "ATTINY2313A@DIP20" -w borzos 
