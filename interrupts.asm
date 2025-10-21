.INCLUDE "tn2313Adef.inc"
.ifndef _INTERRUPTS_ASM_
.define _INTERRUPTS_ASM_

.message "Processing: interrupts.asm"

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
