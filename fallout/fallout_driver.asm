
; fallout_driver.asm
; CSC 3410 Assignment #4 
; by Philip Westrich
; <DATE>

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

EXTRN  inproc:near32, outproc:near32

CR      	 	EQU     0Dh     ; carriage return character
LF      		EQU     0Ah     ; line feed
BUFFER_SIZE		EQU		013 	; input buffer size
STRING_SIZE 	EQU BUFFER_SIZE - 1	; string size 
MAX_NUM_STR		EQU 	020 	; maximum number of strings
MAX_NUM_GUESS	EQU 	004 	; maximum number of guesses allowed

.STACK 4096
.DATA

num_strings 	WORD 	?
index 			WORD 	?
buffer 			BYTE 	BUFFER_SIZE DUP (0), 0 

; huge array of strings
str_array 		BYTE 	(STRING_SIZE * MAX_NUM_STR) DUP (0), 0 

; prompts
string_prompt	BYTE 	"Enter a string, or x to quit: ", 0 
number_prompt	BYTE 	"The number of strings entered is: "
number_entered 	BYTE 	8 DUP (' '), CR, LF, 0 
test_prompt		BYTE  	"Enter the 1-based index of the test password: ", 0
match_prompt 	BYTE 	"Enter the number of exact character matches: " , 0

INCLUDE fallout_procs.h
INCLUDE io.h 
INCLUDE debug.h

.CODE

_start:
 	
	xor 	ecx, ecx		; zero counter
	lea 	ebx, str_array 	; load array address
	
	read_input:
	
		output 	string_prompt	; prompt user
				
		push ebx
		mov edx, BUFFER_SIZE
		push edx 
		call inproc				; call this manually because header file won't let me do this
		
		push ebx 
		call outproc
		
		output carriage 
		
		mov al, [ebx] 			; get the first character
		cmp al, 'x' 			; check if x, done if it is 
		je input_done
		
		inc ecx 				; increment counter
		add ebx, STRING_SIZE	; increment array index
		cmp ecx, MAX_NUM_STR 	; check for max num strings entered
		jne read_input
		
	input_done:
	
	mov num_strings, cx			; save number of items
	itoa number_entered, cx 	; convert to string
	output number_prompt 		; print number entered
	mov bx, STRING_SIZE
	print_strings str_array, cx, bx 
	
	input buffer, BUFFER_SIZE 	; flush buffer
	
	mov bx, cx 				; put number of stings in bx
	xor ecx, ecx 			; zero counter
	mov dx, MAX_NUM_GUESS	; hold on to the max number of guesses

	guess_string:

		output test_prompt			; prompt user
		input buffer, BUFFER_SIZE	; get number 
		output carriage
		atoi buffer 				; int now in ax
		mov index, ax				; save it 

		output match_prompt			; prompt for matches 
		input buffer, BUFFER_SIZE	; input number 
		output carriage
		atoi buffer 				; convert to int, in ax 
		
		; call compare procedure
		compare_matches str_array, bx, STRING_SIZE, ax, index

		; print the strings left
		print_strings str_array, ax, STRING_SIZE
		
		mov bx, ax
		cmp bx, 1 			; check number of strings left, returned in ax 
		jle done
	
		inc ecx 			; increment try count 
		cmp ecx, edx		; check number of tries 
		jne guess_string

	done:
	
	INVOKE ExitProcess, 0 

PUBLIC _start

END
