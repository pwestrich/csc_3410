
; interpolate_driver.asm
; CSC 3410 Assignment #3
; by Philip Westrich
; Wednesday, November 5, 2014

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

CR      	 	EQU     0Dh     			; carriage return character
LF      		EQU     0Ah     			; line feed
BUFFER_SIZE		EQU		08					; input buffer size
MIN_POINTS 		EQU 	3 					; need at least three points to interpolate
MAX_NUM_POINTS	EQU 	020					; max number of points, change prompt too if number changed
MAX_NUM_ITEMS	EQU		MAX_NUM_POINTS * 2 	; number of items in the array

.STACK 4096
.DATA 

; data from user
x_coord			REAL4	?
solution 		REAL4 	?
TOLERANCE 		REAL4 	0.001
numPoints 		WORD	?
numItems		WORD 	?
degree 			WORD	?

; large array of floats 
points 			REAL4	MAX_NUM_ITEMS	DUP	(?)

; prompt strings
xPrompt			BYTE	"Enter the x-coordinate of the desired interpolated Y: ", CR, LF, 0
degreePrompt	BYTE	"Enter the degree of the interpolated polynomial: ", CR, LF, 0
pointPrompt		BYTE	"You may enter up to 20 points, one at a time. Input q to quit.", CR, LF, 0
pointError		BYTE 	"Error: You need one more point than the degree.", CR, LF, 0 
pointCheck		BYTE 	"Points entered: ", CR, LF, 0 
sorted 			BYTE 	"Sorted points: ", CR, LF, 0 
interpolatING	BYTE 	"Interpolating...", CR, LF, 0
result			BYTE	"The result: "
resultString	BYTE	 16	DUP	(0), 0 
inputBuffer		BYTE	BUFFER_SIZE DUP (0), 0

; header files!
INCLUDE compare_floats.h
INCLUDE float.h
INCLUDE interpolate.h
INCLUDE io.h
INCLUDE sort_points.h
INCLUDE debug.h

.CODE

_start:

	output xPrompt					; print prompt
	input inputBuffer, BUFFER_SIZE	; get input as string
	atof inputBuffer, x_coord		; convert to float

	output degreePrompt				; print prompt
	input inputBuffer, BUFFER_SIZE	; get input as string
	atoi inputBuffer				; convert to int 
	mov degree, ax 

	xor eax, eax 
	xor ecx, ecx 					; neat fast way to zero a register
	lea ebx, points 				; the array of points in ebx
	output pointPrompt

	readPoints:

		input inputBuffer, BUFFER_SIZE			; get input
		cmp inputBuffer, 'q'					; check if q
		je done									; stop if done
		atof inputBuffer, REAL4 PTR [ebx + eax]	; else this is x, convert to float
		inc ecx 								; increment counter
		add eax, 4
		input inputBuffer, BUFFER_SIZE			; then get Y
		atof inputBuffer, REAL4 PTR [ebx + eax]	; else this is x, convert to float
		inc ecx 								; increment counter
		add eax, 4
		cmp ecx, MAX_NUM_ITEMS					; check if that was the last item or not 
		jl readPoints 							; keep going if less

	done:
	
	mov numItems, cx					; keep numItems
	shr ecx, 1	 						; calculate numPoints (items / 2)
	mov numPoints, cx 					; store it 
	
	cmp cx, MIN_POINTS 					; can't have less than this 
	jle point_error
	
	cmp cx, degree 						; need one more point than degree
	jle point_error

	; time to start extrapolating!
	output pointCheck
	print_points points, cx 				; check myself
	
	mov eax, x_coord
	sort_points points, eax, TOLERANCE, cx 	; sort points
	output sorted 
	print_points points, cx 				; print sorted points 

	;output interpolatING
	mov ax, degree 						; make this totally unambiguous
	mov edx, x_coord					; same here
	interpolate points, ax, edx			; interpolate the value, result in EAX

	ftoa eaX, 8, 8, resultString	; convert to string
	output result	; print result
	jmp _exit
	
	point_error:
	output pointError
	
	_exit:

	INVOKE ExitProcess, 0 				; done!

PUBLIC _start

END
