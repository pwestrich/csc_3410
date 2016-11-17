
EXTRN 	print_strings_proc 		: Near32
EXTRN 	compare_matches_proc 	: Near32

; prints the number of strings in the array given
print_strings	MACRO 	array, num_strings, str_len

	push ebx

		push str_len
		push num_strings
	
		lea ebx, array
		push ebx
		
		call 	print_strings_proc

	pop ebx

ENDM

compare_matches 	MACRO 	array, num_strings, str_len, num_matches, str_index

	push str_index
	push num_matches
	pushw str_len
	push num_strings

	lea eax, array
	push eax

	call compare_matches_proc

ENDM
