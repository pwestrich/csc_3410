
; vankins.asm
; CSC 3410, Assignment 2
; by Philip Westrich
.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

CR      	 	EQU     0Dh     ; carriage return character
LF      		EQU     0Ah     ; line feed
BUFFER_SIZE		EQU		010		; input buffer size
MAX_NUM_ROWS	EQU		10		; how many rows max?
MAX_NUM_COLS	EQU		10		; how many columns max?
MAX_GRID_SIZE	EQU		MAX_NUM_ROWS * MAX_NUM_COLS	; largest grid size

OUTPUT_PRINT_WIDTH		EQU		6	; how many chars are we printing for a word?
OUTPUT_NUMBER_WIDTH		EQU		2	; leave 4 spaces for number output
OUTPUT_STRING_SIZE		EQU		1024; 

.STACK 4096
.DATA 

numRows			WORD	?
numCols			WORD	?
numItems		WORD	?

grid			WORD	MAX_GRID_SIZE * MAX_GRID_SIZE DUP (0)
solutionsGrid	WORD	MAX_GRID_SIZE * MAX_GRID_SIZE DUP (0)

inputBuffer		BYTE	BUFFER_SIZE DUP (0)

; prompts
getRowPrompt	BYTE	"How many rows? ", CR, LF, 0
getColPrompt	BYTE	"How many columns? ", CR, LF, 0
getItemPrompt	BYTE	"Enter the next item: ", CR, LF, 0

vankinArr		BYTE	"Input grid:", CR, LF, 0
solutionArr		BYTE	"Solutions grid:", CR, LF, 0
answerPrompt	BYTE	"The solution path: "
answerString	BYTE	OUTPUT_STRING_SIZE DUP (0)

INCLUDE io.h      ; header file for input/output
INCLUDE debug.h   ; header for debugging

.CODE

; macro for getting an item's index in the array
; leaves it in index
; row in ax, col in bx
; dx is wrecked
; ax ends up with index
getItemIndex		MACRO
	
	mov dx, numCols	; get the number of columns
	dec ax			; row - 1
	mul dx			; (row - 1) * cols -> dx:ax
	add ax, bx		; (row - 1) * cols + cols
	dec ax			; (row - 1) * cols + cols - 1
	
ENDM

; puts an item in the spot of the specified matrix
; row in ax, col in bx, item in cx, 
putItem				MACRO	array

	push eax
	push ebx			; save registers

	getItemIndex	; find item's offset, in ax
	
	shl ax, 1		; ax * 2
	movsx eax, ax	; make sure eax has only my number
	lea ebx, array	; get array's address
	add ebx, eax	; add to it the offset
	mov [array], cx	; put item in array at offset
	
	pop ebx			; restore registers
	pop eax
	
ENDM

; gets an item from the array
; row in ax, col in bx
; item will be in cx
getItem 			MACRO	array

	push ax
	push bx			; save registers

	getItemIndex	; find item's offset
	
	shl ax, 1		; ax * 2
	movsx eax, ax	; make sure all of eax is empty
	lea ebx, array	; get array's address
	add ebx, eax	; add to it the offset
	mov cx, [ebx]	; put number in cx

	pop bx			; restore registers
	pop bx
	
ENDM

printArray		MACRO	array
				LOCAL 	printLoop
	lea ebx, array		; move array's address into ebx
	mov cx, numRows		; put numRows in loop counter
	mov ax, 0			; zero column count
	
	printLoop:
	
		mov dx, WORD PTR [ebx]	; move number into register
		itoa inputBuffer, dx	; convert to a string
		output inputBuffer		; print number
		add ebx, 2				; next number
		inc ax					; increment column count
		
		cmp ax, numCols			; check column count
		jnz printLoop			; skip carriage if not zero
		
		output carriage			; otherwise print it
		mov ax, 0				; and zero counter
		
		dec cx					; decrement loop counter
		jnz printLoop			; repeat if it was not zero
		
ENDM

; reads input for an array
; wrecks ax, ebx, dx
readInput			MACRO
					LOCAL read_loop
	
	; first, read the num rows & cols
	inputw getRowPrompt, numRows
	inputw getColPrompt, numCols
	
	mov ax, numRows
	mov bx, numCols
	mul bx				; calculate the num items, now in ax
	mov numItems, ax 	; save it
	lea ebx, grid		; get first item in the array
	mov cx, ax
	
	read_loop:
	
		inputw getItemPrompt, [ebx]	; get item
		add ebx, 2					; move over two bytes
		dec cx
		
	jnz read_loop

ENDM

_start:

	readInput
	
	output vankinArr			; print prompt
	printArray grid				; print the array
	
	; now start working on the solution
	movsx ecx, numItems		; find index of last item
	dec ecx
	shl ecx, 1				; turn it into a number of bytes
	lea ebx, grid			; load the two array's addresses
	lea edx, solutionsGrid
	mov ax, [ebx + ecx]			; get the last item
	mov [edx + ecx], ax			; put the last item in
	
	; now start solving the grid
solveBottom:
	sub ecx, 2				; move one item over
	mov ax, [ebx + ecx]		; get the item in that spot
	add ax, [edx + ecx + 2]	; add to it the previous score
	cmp [ebx + ecx], ax		; compare the two
	jg useOtherBottom
	
useAXBottom:
	mov [edx + ecx], ax		; put cumulative number in solution spot
	jmp bottomDone

useOtherBottom:
	mov ax, [ebx + ecx]		; put the ragular number in the solution spot
	mov [edx + ecx], ax

bottomDone:
	push ecx
	movsx eax, numItems
	movsx ecx, numCols
	sub eax, ecx
	shl eax, 1
	pop ecx
	cmp eax, ecx
	jb solveBottom
	
	; now do the far right column
	sub ecx, 2	; should be the next item
solveRight:
	movsx eax, numCols	; get number of columns
	shl eax, 1			; multiply by 2
	add eax, ecx		; add to ecx for index of item below
	mov ax, [edx + eax]	; get the item below from solutions
	add ax, [ebx + ecx]	; add it to the current item in grid
	cmp [ebx + ecx], ax	; compare to current item in grid
	jg rightUseOther
	
rightUseAX:
	mov [edx + ecx], ax		; put ax in spot
	jmp rightDone

rightUseOther:
	mov ax, [ebx + ecx]		; put cumulative sum in spot
	mov [edx + ecx], ax
	
rightDone:	
	movsx eax, numCols	; figure out if we're on first row or not
	shl eax, 1			; multiply by 2
	sub ecx, eax		; move up a row
	jns solveRight
	
	; now base cases are finished, solve inside of grid
	mov ax, numRows
	mov bx, numCols
	dec ax			; numRows - 1
	dec bx			; numCols - 1
	getItemIndex	; get the item's index
	shl ax, 1		; ax * 2
	movsx ecx, ax	; put it in loop counter
	add ecx, 2
	
solveInner:
	sub ecx, 2				; move over one item
	lea ebx, solutionsGrid	; get solutions address
	movsx eax, numCols		; and number of columns
	shl eax, 1				; multiply it by two
	add eax, ecx			; add the loop counter to it
	mov ax, [ebx + eax]		; get from solutions item down
	mov dx, [ebx + ecx + 2]	; get from solutions item right
	lea ebx, grid			; get grid's address
	add ax, [ebx + ecx]		; add grid's item to each
	add dx, [ebx + ecx]
	lea ebx, solutionsGrid
	cmp ax, dx				; pick larger and keep
	jl innerUseDX
	
innerUseAX:
	mov [ebx + ecx], ax	; put ax in the spot
	jmp innerDone

innerUseDX:
	mov [ebx + ecx], dx ; put dx in the spot
	
innerDone:
	cmp ecx, 0			; now determine where to jump
	jl findPath			; if we are before the first element, we're done!
	
	mov bx, numCols		; determine end of row
	shl bx, 1			
	mov ax, cx			; put loop counter in ax, don't wreck it
	cwd					; prepare for division
	div bx				; I want dx = ax % bx (current index % numCols)
	cmp dx, 0			; if no remainder, it's the end of the row
	jne solveInner		; otherwise, keep going
	
nextRow:
	sub ecx, 2			; move over one more item
	jmp solveInner		; keep looping
	
findPath:
	mov ecx, 0				; start in first spot
	mov eax, 0				; offset for string
	push eax				; save it
	
findPathLoop:
	lea ebx, solutionsGrid	; get solutions grid address
	movsx eax, numCols		; calculate item below
	shl eax, 1
	add eax, ecx
	push eax				; save this for later
	mov ax, [ebx + eax]		; get it
	mov dx, [ebx + ecx + 2]	; and the item right
	cmp ax, dx				; take the larger
	jle pathUseDX
	
pathUseAX:
	pop eax							; get item below back
	mov ecx, eax					; move loop counter to item below
	lea ebx, answerString			; get string's address
	pop eax							; and the current offset
	mov BYTE PTR [ebx + eax], 'd'	; put letter in place
	inc eax							; increment offset
	push eax
	jmp pathDone

pathUseDX:
	add ecx, 2						; move loop counter to item right
	lea ebx, answerString
	pop eax							; get rid of this
	pop eax							; get string offset
	mov BYTE PTR [ebx + eax], 'r'
	inc eax
	push eax
	
pathDone:
	movsx eax, numItems
	shl eax, 1
	cmp ecx, eax
	jl findPathLoop
	
done:
	output solutionArr			; print prompt
	printArray solutionsGrid 	; print solutions
	output answerPrompt			; print path
	
   INVOKE ExitProcess, 0  		; done!

PUBLIC _start

END
