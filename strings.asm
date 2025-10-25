.ifndef _STRINGS_ASM_
.define _STRINGS_ASM_

.INCLUDE	"tn2313Adef.inc"
.message	"Processing strings.asm"


; r17 - pointer to string 0
; r18 - length of string 0
; r19 - pointer to string 1
; r20 - length of string 1
strings_compare:	; puts 0 in r16 if strings are equal
	cp r18, r20
; if lengths aren't equal we just 'return' 1, who gives a fuck then
	brne strings_compare_end_non_eq
strings_compare_end_non_eq:
	ldi r16, 1
strings_compare_end:
	ret

.endif
