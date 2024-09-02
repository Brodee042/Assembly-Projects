TITLE Proj5_arbonb     (Proj_arbonb.asm)

; Author: Brody Arbon
; Last Modified: 3/5/2024
; OSU email address: arbonb@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 5 - Arrays, Addressing, and Stack-Passed Parameters          Due Date: 3/5/2024

; Description: This program altogether takes nothing from the user, it simply generates a randomized Array 
; of a size deterimined by the constant ARRAY_SIZE, and to the specifications of HI and LO. Regardless,
; The randomized array is created, we then loop through the array, starting from least to greatest, in order
; to create a array that is sorted. After that, we loop through it again to count out how many of each
; type of number their is in the array. All of these arrays are printed via calling one procedure, and then 
; at the end we put the median of the sorted list.


INCLUDE Irvine32.inc


; (insert constant definitions here)
ARRAY_SIZE = 200
HI = 50
LO = 15

.data


someArray		DWORD	ARRAY_SIZE DUP(?)
sortedArray		DWORD	ARRAY_SIZE DUP(?)
counts			DWORD	HI DUP(?)

intro1			BYTE	"Generating, Sorting, and Counting Random integers                    Made by Brody", 0
intro2			BYTE	"This program generates 200 random integers between 15 and 50, inclusive. It then displays the original list, sorts the  list, then counts how many of each different number we get, and lastly we display the Median of the Sorted List",  0
explanation1	BYTE	"unsorted list:  ", 0
explanation2	BYTE	"sorted list:  ", 0
explanation3	BYTE	"number of numbers in array:  ", 0
explanation4	BYTE	"Median:  ", 0
spacing			BYTE	"  ", 0

number_of_values	DWORD	0


.code

;====================================================================================
; Calls all needed procedures, changes everything, no pre/post conditions
;====================================================================================
main PROC

	PUSH	OFFSET	intro1
	PUSH	OFFSET	intro2
	CALL	introduction


	PUSH	OFFSET	spacing
	PUSH	OFFSET	someArray
	CALL	fillArray


	PUSH	OFFSET	someArray
	PUSH	OFFSET	sortedArray
	CALL	exchangeElements


	PUSH	OFFSET	number_of_values
	PUSH	OFFSET	someArray
	PUSH	OFFSET	counts
	CALL	countList

	PUSH	OFFSET	explanation3
	PUSH	OFFSET	explanation2
	PUSH	OFFSET	explanation1
	PUSH	OFFSET	number_of_values
	PUSH	OFFSET	spacing
	PUSH	OFFSET	counts
	PUSH	OFFSET	sortedArray
	PUSH	OFFSET	someArray
	CALL	displayList

	PUSH	OFFSET	explanation4
	PUSH	OFFSET	sortedArray
	CALL	displayMedian

	Invoke ExitProcess,0	; exit to operating system
main ENDP


;====================================================================================
; the 'introduction' procedure prints out header, instruction, and instruction 2
; no post or preconditions            EDX changed
;====================================================================================
introduction	PROC
	; This overall just prints out all the pertinent information the user needs
	PUSH EBP
	MOV  EBP, ESP

	CALL	Crlf
	CALL	Crlf
	MOV		EDX, [EBP + 12]			; Writes the first string
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	MOV		EDX, [EBP + 8]			; Writes the second string
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	POP		EBP	
	RET		12

introduction	ENDP


;====================================================================================
; This fills up the array with random numbers to the specifications of LO and HI,
; which we make sure of during the looping. We get the numbers from RandomRange
;
;	EBP + 8 = someArray
;	no pre or post conditions, EDX register not changed
;====================================================================================
fillArray	PROC

	XOR		EBX, EBX
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ECX, ARRAY_SIZE			;	make ARRAY_SIZE our loop counter
	MOV		EDI, [EBP + 8]			;	EDI holds address of someArray




_number_generation:
	MOV		EAX, HI
	ADD		EAX, 1					;	Need to add 1 to make it inclusive
	CALL	RandomRange
	CMP		EAX, LO					;	Make sure it isn't below the minimum LO value
	JNGE	_number_generation


	MOV     [EDI], EAX 
    ADD     EDI, 4					;	Adds number to array


	LOOP _number_generation



_exit:
	POP		EBP	
	RET		12
	
fillArray	ENDP


;====================================================================================
; This program loops through the initial random array, starting with the lowest
; value possible then going up to the highest one, and when it finds a match to the
; number in the random array, it puts it in the sorted one, in the end creating a
; sorted array.
;
;	EBP + 12 = unsortedArray
;	EBP + 8  = sortedArray
;
;	no pre or post conditions, simply creates array, all registers changed
;====================================================================================
exchangeElements	PROC
	PUSH	EBP
	MOV		EBP, ESP

	XOR		EDX, EDX

	MOV		EBX, LO

_exchange_loop:
	MOV		ECX, ARRAY_SIZE
	MOV		ESI, [EBP + 12]				; ESI has address for unsorted array
	MOV		EDI, [EBP + 8]				;EDI has address for sortedArray

_loop_to_get_numbers:
    MOV		EAX, [ESI]
    CMP		EAX, EBX
    JE		_numbers_equal
    ADD		ESI, 4
    LOOP	_loop_to_get_numbers
	JMP		_out_of_loop

_numbers_equal:
    MOV		[EDI + EDX], EAX          ; Move the equal number to sortedArray


    ADD		EDX, 4
    ADD		ESI, 4					  ;	increment both arrays

    LOOP	_loop_to_get_numbers
	JMP		_out_of_loop

_out_of_loop:
    INC		EBX						  ; Increment the number to look for
    CMP		EBX, HI
    JLE		 _exchange_loop			  ; Continue if EBX is less than HI

_exit:
    POP		EBP
    RET		12

exchangeElements	ENDP


;====================================================================================
; All this procedure does is find the median of the sorted array, and this is done
; via dividing array_size by 2, rounding up if needed, then looping thourgh the array
; by the amount we get after we divide

;	EBP + 8 = SortedArrray
;	EBP + 12 = explanation4

; No pre or post conditions, outputs Median: 'median'
;====================================================================================
displayMedian	PROC
	PUSH	EBP
	MOV		EBP, ESP

	XOR		EAX, EAX
	XOR		EDX, EDX
	MOV		EBX, 2
	MOV		EDX, 0
	MOV		EAX, ARRAY_SIZE			   ;	divide ARRAY_size

	DIV		EBX

	CMP		EDX, 1
	JE		_round_up

	JMP		_find_given_number

_round_up:

	ADD		EAX, 1

_find_given_number:
	MOV		EDI, [EBP + 8]
	MOV		ECX, EAX				  ; keeps looping till we get to midpoint determined earlier by dividing ARRAY_SIZE

_loop:
	MOV		EAX, [EDI]
	ADD     EDI, 4   
	LOOP	_loop

	CALL	Crlf
	MOV		EDX, [EBP + 12]
	CALL	WriteString

	CALL	WriteDec

	CALL	Crlf

displayMedian	ENDP

;====================================================================================
; This procedure goes through, finding out how many of each type of numbers are in the array
; and then it puts them in the counts array. 
;
;	EBP + 8 = counts
;	EBP + 12 = someArray
;	EBP + 16 = number_of_values
;
;	must have SomeArray created, no post conditions, all registers changed
;====================================================================================
countList	PROC

	PUSH	EBP
	MOV		EBP, ESP
	XOR		EDX, EDX
	XOR		EBX, EBX
	MOV		EBX, LO
	MOV		EDI, [EBP + 8]	

_exchange_loop:
	MOV		ECX, ARRAY_SIZE					; loop counter is ARRAY_SIZE
	MOV		ESI, [EBP + 12]					; ESI has address for unsorted array


_loop_to_get_numbers:
    MOV		EAX, [ESI]

    CMP		EAX, EBX						; EAX is the number in the List, EBX is the number we are trying to find, we start at LO
    JE		_numbers_equal

    ADD		ESI, 4
    LOOP	_loop_to_get_numbers
	JMP		_out_of_loop					;  once loop runs out we jump out

_numbers_equal:
	INC		EDX

    ADD		ESI, 4

    LOOP	_loop_to_get_numbers
	JMP		_out_of_loop

_out_of_loop:
	XOR		EAX, EAX

	CMP		EDX, 0
	JE		_given_num_not_found			; if we found nothing we jump over their and inc EBX

	MOV		[EDI], EDX  
	ADD		EDI, 4

	MOV EAX, EDX




	XOR		EDX, EDX
	MOV		ESI, [EBP + 16]					;EBP + 16 is number_of_values location
	INC		EDX
	ADD		[ESI], EDX

	XOR		EDX, EDX

_given_num_not_found:
	INC		EBX               

	CMP		EBX, HI
    JG		_exit							; Continue if EBX is less than HI
	JMP		_exchange_loop
_exit:
    POP		EBP
    RET		16
	exit



countList	ENDP

;====================================================================================
;	This prints out all of the arrays in one procedure, as the instructions stated, and this 
;	procedure essentially uses every single register, and it has no pre/post conditions
;
; EBP + 36 =explanation3
; EBP + 32 =explanation2
; EBP + 28 =explanation1
; EBP + 24 =number_of_values
; EBP + 20 =spacing
; EBP + 16 =counts
; EBP + 12 =sortedArray
; EBP + 8 =someArray

;   outputs all of the arrays, no pre/post conditions, all registers changed
;	
;====================================================================================
displayList PROC

	PUSH	EBP
	MOV		EBP, ESP

	XOR		EDX, EDX
	XOR		EAX, EAX
	XOR		EBX, EBX
	XOR		ESI, ESI

	MOV		ESI, 1							;	I use ESI to keep track of which array we are loopoing through

_next_loop:

_write_unsorted:
	MOV		EDI, [EBP + 8]	
	MOV		EDX, [EBP + 28]
	CALL	WriteString						;	Writes out explanation
	CALL	Crlf

	MOV		ECX, ARRAY_SIZE
	CMP		ESI, 1
	JE		_display_loop

_write_sorted:
	CALL	Crlf
	MOV		EDI, [EBP + 12]					;sorted list
	MOV		ECX, ARRAY_SIZE
	CMP		ESI, 2
	JE		_display_loop

_write_count:
	CALL Crlf
	MOV		EDI, [EBP + 16]					;this loop does count
	MOV		ESI, [EBP + 24]
	MOV		ECX, [ESI]

	MOV		ESI, 3

	JE		_display_loop

_display_loop:

	MOV		EAX, [EDI]
	CALL	WriteDec						; Writes the number we just created and then prints out spacing
	MOV		EDX, [EBP + 20]				
	CALL	WriteString


    ADD     EDI, 4							; Adds four as that is how large DWORD is


	INC		EBX
	CMP		EBX, 20
	JE		_new_line

	LOOP	_display_loop


_new_line:
    CALL    Crlf						; Move to the next line after displaying 20 numbers
	XOR     EBX, EBX

	CMP		ECX, 0
	JE		_skip_loop					;Prevent integer overflow
	LOOP	_display_loop

_skip_loop:
	XOR     EDX, EDX
	INC     ESI							; Move to the next list

	CMP		ESI, 2
	JG		_next_label
	CALL	Crlf
	MOV		EDX, [EBP + 32]
	CALL	WriteString
	JMP		_write_sorted

_next_label:							; this prints out our last lable for numbers counted, then sets the loop up again
	CMP		ESI, 3					
	JG		_end
	CALL	Crlf
	MOV		EDX, [EBP + 36]
	CALL	WriteString

	JMP		_write_count


	CMP		ESI, 4
	JE		_end

	LOOP	_display_loop

_end:

    POP     EBP
    RET		36


displayList	ENDP


END main

