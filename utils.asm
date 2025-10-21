.ifndef _UTILS_ASM_
.define _UTILS_ASM_

.message "processing utils.asm"

.macro load_out
	.message "no parameters"
.endm

.macro load_out_8_i_i
	ldi @0, @1
	out @2, @0
.endm

.endif
