
; interpolate.h
; CSC 3410 Assignment #3
; by Philip Westrich
; Wednasday, November 5, 2014
; This has the macros for what's in interpolate.asm

.NOLIST      ; turn off listing
.386

EXTRN interpolate_proc	: Near32

; calls the procedure to interpolate the value
; array is the array of points, REAL4s in x-y pairs		REAL4
; degree is the degree of polynomial to be used			WORD
; value is the number to interpolate 					REAL4
interpolate 	MACRO 	array, degree, value

	push ebx		; save register
	lea ebx, array 	; get array's address
	push ebx 		
	push value 
	push degree
	call interpolate_proc
	pop ebx

ENDM
