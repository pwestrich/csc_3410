
; interpolate.asm
; CSC 3410 Assignment #3
; by Philip Westrich
; Wednesday, November 5, 2014
; This contains the procedures for the assignment.
; They have macros in interpolate.h

.386
.MODEL FLAT
.STACK 4096

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

; constants
POINT_SIZE	EQU		8 		; points are eight bytes wide

; procedure parameters for calculate_bs_proc
lastPoint	EQU		[ebp + 8]
firstPoint	EQU		[ebp + 10]
arrayAddr	EQU		[ebp + 12]

; procedure parameters for interpolate_proc and x_proc
index 		EQU 	[ebp + 8]
degree 		EQU 	[ebp + 8]
value 		EQU		[ebp + 10]
array 		EQU 	[ebp + 14]

; loacl vars for interpolate_proc
sum 		EQU 	[ebp - 4]

.code

; Performs the interpolation
interpolate_proc	PROC 	Near32

	; beginning stuff
	push ebp
	mov ebp, esp
	push ecx
	push edx
	pushf

	movsx ecx, WORD PTR degree	; put the degree in it
	inc ecx						; add 1
	shl ecx, 3					; multiply by 2^3 (8) to get the index of the last x-val
	sub ecx, POINT_SIZE
	mov ebx, array 				; get the array address
	fldz 						; load a zero for the sum 

	interpolate:

		xor eax, eax 			; zero eax
		mov ebx, array 
		push ebx
		push cx
		push ax
		call calculate_bs_proc 	; current b should be in st0 
		
		push ebx				; push points array
		mov edx, value
		push edx				; push x
		sub ecx, POINT_SIZE 	; decrement index 
		push cx					; push index
		call x_proc				; calculate the (x - xn) 
								; should be left in st0
		fmul 	 				; b(x - x0)... in st0
		fadd 					; add this to the sum 
		cmp ecx, 0
		jne interpolate 		; keep going as long as ecx > 0

	push ebx
	push ecx 
	call calculate_bs_proc ; get b0 
	fadd					; add to sum
	fstp REAL4 PTR sum 
	mov eax, sum
		
	; ending stuff
	popf			; restore flags
	pop edx			; restore registers
	pop ecx
	mov esp, ebp	; move esp back
	pop ebp			; get ebp back
	ret 10			; return, pop 10 bytes

interpolate_proc 	ENDP

; Caclulates the bs 
calculate_bs_proc 		PROC 	Near32

	; beginning stuff
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	pushf

	; check base case 
	mov ax, lastPoint
	mov dx, firstPoint
	cmp ax, dx 					; when first = last, answer = f(first)
	je base_case

	add ax, POINT_SIZE			; decrement by one point 

	mov ebx, arrayAddr
	push ebx
	push dx
	push ax
	call calculate_bs_proc		; call function recursivley

	mov ax, lastPoint 
	sub dx, POINT_SIZE			; increment second point

	mov ebx, arrayAddr
	push ebx
	push dx
	push ax
	call calculate_bs_proc		; call function recursivley
	
	mov arrayAddr, ebx
	add dx, POINT_SIZE				; get n back
	
	fsub 							; first - second
	
	movsx eax, WORD PTR lastPoint 	; get last point's address
	fld REAL4 PTR [ebx + eax]		; load xm onto FPU

	movsx eax, WORD PTR firstPoint	; get first point's address
	fld REAL4 PTR [ebx + eax]		; load xn onto FPU
	
	fsubr						; xn - xm
	fdiv						; top / bottom, now in st0
	
	jmp done					; now we're done!

	base_case:
	mov ebx, arrayAddr				; get array address
	movsx ecx, WORD PTR firstPoint	; get point index
	fld REAL4 PTR [ebx + ecx + 4]	; b is the y-value for one of the points
	
	done:			; ending stuff
	popf			; restore flags
	pop edx			; restore registers
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp	; move esp back
	pop ebp			; get ebp back
	ret 8			; return, pop 8 bytes

calculate_bs_proc 	ENDP

; calculates the (x - xn) stuff recursivley
x_proc 				PROC 	Near32

	; beginning stuff
	push ebp
	mov ebp, esp
	pushd 0 
	push eax
	push ebx
	push ecx
	push edx
	pushf

	mov ebx, array 				; get array of points
	xor ecx, ecx				; zero ecx
	mov cx, degree				; check base case of index = 0
	cmp cx, 0
	je base		 				; if equal, do it
	
	push ebx					; push points 
	mov edx, value				; get value 
	push edx					; push value 
	sub ecx, POINT_SIZE			; decrement index
	push cx						; push index 
	call x_proc					; go do it again
								; (x - xn) should be on stack now 
	add ecx, POINT_SIZE			; get previous point back
	fld REAL4 PTR [ebx + ecx]	; push xn on stack 
	fld REAL4 PTR value			; push x on stack 
	fsubr 						; subtract (x - xn)
	fmul 						; multiply (x - xn)(x - xn-1)
	jmp done 					; done 

	base:
	fld REAL4 PTR value 		; push x on stack
	fld REAL4 PTR [ebx + ecx] 	; push x0 onto FPU
	fsub 						; (x - x0) on stack for returning call
	
	done: 			; ending stuff
	popf			; restore flags
	pop edx			; restore registers
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp	; move esp back
	pop ebp			; get ebp back
	ret 10			; return, pop 10 bytes

x_proc ENDP

PUBLIC interpolate_proc

END
