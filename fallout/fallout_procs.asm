
.386
.MODEL FLAT
.STACK 4096

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

EXTRN 	outproc:near32

CR      EQU     0Dh     ; carriage return character
LF      EQU     0Ah     ; line feed

; arguments for print_strings_proc and compare_matches_proc
str_index	EQU		[ebp + 18]
num_matches	EQU		[ebp + 16]
string_len	EQU 	[ebp + 14]
num_strings	EQU		[ebp + 12]
array 		EQU 	[ebp + 08]

; arguments for determine_matches_proc and swap_strings_proc
str_len			EQU 	[ebp + 16]
second_string 	EQU 	[ebp + 12]
first_string	EQU 	[ebp + 08]

.DATA ; test strings, please ignore
_test_input BYTE 	16 DUP (0) 
_swapping 	BYTE 	"swapping: ", CR, LF, 0
_error		BYTE 	"ERROR, DYING", CR, LF, 0

INCLUDE debug.h

.CODE

die PROC Near32

	INVOKE ExitProcess, 0 

die ENDP 

; prints the array 
print_strings_proc 	PROC 	Near32

	push 	ebp
	mov 	ebp, esp
	pushf
	push 	eax
	push 	ebx
	push 	ecx
	push 	edx

	movsx	eax, WORD PTR string_len
	mov 	ebx, array
	xor 	ecx, ecx
	movsx	edx, WORD PTR num_strings
	
	output carriage 
	
	print_loop:

		push 	ebx
		call 	outproc		; print the string
		output carriage 	; print newline

		add 	ebx, eax 	; increment pointer
		inc 	ecx 		; increment counter
		cmp 	edx, ecx 	; check number of strings 
		jne print_loop
		
	output carriage

	pop edx
	pop ecx
	pop ebx
	pop eax
	popf
	mov esp, ebp
	pop ebp
	ret 8

print_strings_proc 	ENDP

; counts the number of matches second_string has against first_string
count_matches_proc	PROC 	Near32 

	push ebp
	mov ebp, esp
	pushf
	push ebx
	push ecx
	push edi
	push esi

	mov esi, first_string		; put string to compare to in source
	mov edi, second_string		; put test string in destination
	movsx ecx, WORD PTR str_len	; put string length in ecx
	xor eax, eax 				; zero eax	
	cld							; move forwards

	compare:

		repne cmpsb 	; find an equal number
		inc eax 		; increment match counter 
		
		cmp ecx, 0		; quit when ecx is zero 
		jne compare
	
	dec eax	; make up for the 0 at the end 
	
	pop esi
	pop edi
	pop ecx
	pop ebx
	popf
	mov esp, ebp
	pop ebp
	ret 10

count_matches_proc 	ENDP

; swaps first_string with second_string
swap_strings_proc	PROC 	Near32 

	push ebp
	mov ebp, esp
	pushf
	push esi
	push edi
	push eax
	push ecx

	mov esi, first_string		; put first in esi
	mov edi, second_string		; put secoind in edi
	movsx ecx, WORD PTR str_len	; length in ecx
	xor eax, eax 				; zero eax
	
	move_loop:

		mov al, [edi]		; put byte of destination in al 
		movsb 				; put byte of source in destination
		mov [esi - 1], al 	; put byte in al in source
		dec ecx				; decrement counter 
		cmp ecx, 0 			; keep doing this until strings are done
		jne move_loop

	pop ecx
	pop eax
	pop edi
	pop esi
	popf
	mov esp, ebp
	pop ebp
	ret 10

swap_strings_proc 	ENDP

; compares all stings against the index string 
compare_matches_proc 	PROC 	Near32

	push ebp
	mov ebp, esp
	pushf
	push ebx
	push ecx
	push edx
	
	xor ecx, ecx		; zero ecx

	mov ax, str_index 	; get strings's index
	mov cx, num_strings	; get number of strings
	sub cx, ax 			; figure out how many swaps we need to do 
	dec ax 							; make index zero-based
	movsx ebx, WORD PTR string_len	; get string length
	mul bx							; array offset in dx:ax
	shl eax, 16						; move low bits of eax into high bits
	mov ax, dx						; put high bits of answer in ax
	rol eax, 16						; swap high and low bits or eax
	mov edx, array 					; get start of array
	add eax, edx 					; figure out item's place

	jecxz no_swaps
	
	; push the index string to the bottom of the list
	bubble_down_loop:

		push bx 				; push str_len 
		push eax 				; push item
		add eax, ebx 			; find next item
		push eax 				; push next item		
		call swap_strings_proc	; swap the strings
		
		dec ecx
		jnz bubble_down_loop

	; now start comparing each match with the last item
	no_swaps:

	mov ebx, array	; current index of matched strings 
	mov edx, ebx	; current index of compare string 

	compare_loop:
	
		push eax 				; save this for later
		pushw string_len		; push string length
		push edx				; push test string
		push eax				; push index string
		call count_matches_proc	; count its matches 

		cmp ax, num_matches		; compare the retuned number to num_matches
		pop eax					; get eax back
		jne increment			; skip the swap process if not exactly equal
		
		pushw string_len		; push string length
		push edx				; push matched string index
		push ebx				; push current string index 
		call swap_strings_proc	; swap them

		push edx						; save this
		movsx edx, WORD PTR string_len	; get string length
		add ebx, edx 				; increment matched index 
		pop edx							; restore

		increment:

		push ebx						; save this
		movsx ebx, WORD PTR string_len	; get string length
		add edx, ebx					; increment current item index
		pop ebx							; restore
		cmp edx, eax 					; keep doing this until we hit the last string 
		jne compare_loop
		
	mov edx, array	; get the array address	
	sub ebx, edx	; calculate the total length of matched strings
	xor eax, eax	; zero eax 
	mov ax, bx		; move number into ax (should certainly fit)
	mov bx, string_len 	; movce string length into bx 
	cwd					; prepare for division
	div bx				; (total len of strings) / strlen = matched strings

	pop edx
	pop ecx
	pop ebx
	popf
	mov esp, ebp
	pop ebp
	ret 12

compare_matches_proc	ENDP

END
