TITLE Proj6_arbonb     (Proj6_arbonb.asm)

; Author: Brody Arbon
; Last Modified: 3/19/2024
; OSU email ADDress: arbonb@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 6 - String Primitives and Macros          Due Date: 3/17/2024

; Description: This program takes 10 values from the user, and they can be negative or positive, and they will will be checked
; so as to make sure that the number isn't too large or that it has letters or any other symbols that aren't numbers. this is done
; via changing the incoming number into a string, comparing the ASCII value of the number to make sure that the value is either - or +, 
; or a digit. From their, once approved, the value is then stored.


INCLUDE Irvine32.inc


; (insert constant definitions here)
ARRAY_SIZE = 10
HI = 32767
LO = -32768
ZERO   =	48		  ;represent '0' in Ascii code'
NINE   =	57        ;represent '9' in Ascii code'
TEN    =   10	
MINUS  =   45
PLUS   =   43
FOUR	=  4
FIVE	=  5
ONE		=  1


;================================================================================
;	This Macro takes a prompt, prints it out, and then takes the user input and feeds
; it into the ReadString procedure, which then returns us the size of the user input,
; and the user input itself. we put the former in inputLen
;
; EAX changed to the value, no post or pre conditions besides parameters
;
;================================================================================
mGetString      MACRO   prompt, user_input, input_size, inputLen

    PUSH    EDX
    PUSH    ECX
    MOV     EDX, prompt
    CALL    WriteString
    MOV     EDX, user_input
    MOV     ECX, input_size
    CALL    ReadString
	MOV		inputLen, EAX
    POP     ECX
    POP     EDX

ENDM

;================================================================================
;	This macro justs takes in a string address as given by the user, prints it out
;   and that is that, 
;
;	No registers changed, EDX pushed and popped, no pre or post conditions besides parameters
;================================================================================
mDisplayString  MACRO given_string

    PUSH    EDX
    MOV     EDX, given_string
    CALL    WriteString
    POP     EDX

ENDM

.data


intro1					BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures                   Created by: Brody Arbon", 0
intro2					BYTE	"Please provide 10 signed decimal integers.",  0
intro3					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
inputPrompt				BYTE    "Enter a signed integer: ", 0
errorPrompt				BYTE    "Invalid input, the number was likely to big, or wasn't a number", 0
promptNum				BYTE	" Please enter an unsigned number: ", 0
numberMsg				BYTE	" You entered the following numbers: ",0
sumMsg					BYTE	" The sum is: ", 0
avgMsg					BYTE	" The average is: ", 0
spaceComma				BYTE	", ", 0 
space					BYTE	" ", 0  
spacing					BYTE	"  ", 0



positive_ticker			DWORD	0
_get_digits_counter		DWORD	0
_sum_of_values			DWORD	0
inputLen				DWORD	0
sum						SDWORD	0
digit1					DWORD	0
digit2					DWORD	0
digit3					DWORD	0
digit4					DWORD	0
negative_flag			DWORD	0
sumValue				DWORD ?  
avgValue				DWORD ?  


inputBuffer				BYTE  255 DUP(0)       
someArray				SDWORD	ARRAY_SIZE DUP(0)   
stringOutput			BYTE  32 DUP(?)    
counts					DWORD	HI DUP(?)
intValue				SDWORD  ?




.code

;====================================================================================
; Calls all needed procedures, changes everything, no pre/post conditions
;====================================================================================
main PROC

	PUSH	OFFSET	intro1
	PUSH	OFFSET	intro2
	PUSH	OFFSET	intro3
	CALL	introduction

	PUSH	OFFSET	inputLen
	PUSH	OFFSET	positive_ticker
	PUSH	OFFSET	_get_digits_counter
	PUSH    OFFSET  errorPrompt
	PUSH	OFFSET	inputPrompt
	PUSH	OFFSET	someArray
	PUSH    SIZEOF  inputBuffer
    PUSH    OFFSET  inputBuffer
	CALL    ReadVal


	;PUSH	OFFSET space		    ;pass spaces string by reference
	PUSH	OFFSET spaceComma	    ;pass spaceComma string by reference
	PUSH	OFFSET numberMsg        ;pass numberMsg string by reference
	PUSH	OFFSET stringOutput		;pass string array by reference
	PUSH	OFFSET someArray	    ;pass array of integers by reference
	CALL	displayInput			;CALL displayInput procedure

	PUSH	OFFSET		negative_flag
	PUSH	OFFSET		sum
	PUSH	OFFSET		digit4
	PUSH	OFFSET		digit3
	PUSH	OFFSET		digit2
	PUSH	OFFSET		digit1
	PUSH	OFFSET		someArray
	PUSH	OFFSET		avgMsg
	PUSH	OFFSET		sumMsg
	CALL	SumAvg

	;CALL	displaySumAvg

	;PUSH	OFFSET	spacing
	;PUSH	OFFSET	someArray
	;CALL	fillArray

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

	mDisplayString [EBP + 16]			; Writes the first string
	CALL	Crlf
	CALL	Crlf

	mDisplayString [EBP + 12]			; Writes the second string
	CALL	Crlf

	mDisplayString [EBP+8] 			; Writes the third string
	CALL	Crlf
	CALL	Crlf

	POP		EBP	
	RET		12

introduction	ENDP



;===================================================
; This section of code takes all of the user data using the mgetstring macro, which we then turn into 
; ASCII values so as to make sure that we got + or - or number digits, and not letters. We also make sure
; that the value isn't too big, once. We then put the value in the array at intervals of 6. We do this
; through an outer loop, which gets gets user numbers till we have ten, and an inner loop which verifies the 
;	values work
;
; EBP + 32 =   keeps track of if a plus was in front or not. Positive Ticker
; [EBP + 28] = keeps the ECX/size of each digit
; [EBP + 24] = error message
; [EBP + 20] = prompt message
;  EBP + 12 = input buffer
;  EBP + 8 = sizeof input buffer
;
;	Their are no pre or post conditions, every register is changed here
;=====================================================


readVal PROC

    PUSH    EBP                         ; Save EBP
    MOV     EBP, esp                    ; Set stack pointer
    MOV     EDI, [EBP+16]               ; Point to first empty spot in numericArray
    MOV     ECX, TEN                    ; Set counter
    
_outerLoop:
    PUSH    ECX                         ; Save outerLoop counter

_askAgain:
		mGetString [EBP+20], [EBP+8], [EBP+ 12], [EBP + 36] ; 12 is input size, 36 is len of input 

		MOV     EDX, [EBP+8]               ; Transfer userInput ADDress to EDX   
		MOV     esi, EDX                   ; Point to the very first element

		MOV     ECX, EAX					; InnerLoop counter
		CMP		ECX, 4
		JG		_displayError

		MOV		[EBP + 28], ECX
		cld

		MOV     EAX, 0
		MOV     ebx, 0					

_innerLoop:                             
		lodsb                               ; Moves byte at [esi] into the AL register
		CMP		ax, MINUS
		JE		_negativeValue              ; Jump if the current character is '-'
		CMP		ax, PLUS
		JE		_positiveValue
		CMP     ax, ZERO                    ; check ascii low range, 48
		jb      _displayError
		CMP     ax, NINE                    ; check ascii top range, 57
		ja      _displayError
_AcceptedValue:
		xchg    EAX, ebx                    ; Place converted value in accumulator
		jMP     _noError

_negativeValue:								; Handling negative value
	jmp     _AcceptedValue	
   
_positiveValue:
	PUSH	EAX
	MOV		EAX, 1
	MOV		[EBP + 32], EAX					; puts one on Positive ticker
	POP		EAX
	LOOP	_innerloop

_outerloop1:
	JMP		_outerloop

_displayError:
    CALL    CrLf
    mDisplayString  [EBP+24]           ; Call macro to display error message
	CALL    CrLf

    MOV     ECX, 0
    jmp     _askAgain                    ; Ask for a new valid input

_noError:
_processDigit:
	ADD     EAX, ebx                    ; Add the digit to set correct spot in the final integer
	xchg    EAX, ebx                    ; Update accumulator with latest decimal value
                 

	MOV     [EDI], al               ; store the  digit in the array
	ADD     EDI, 1                  ; Move to the next position digit
	
	loop    _innerLoop 


	MOV		ECX, 6						; For each digit, we move 6 bytes from the start each time, 
	SUB		ECX, [EBP + 28]				; We make sure of this my subtracking the digits we place from the 6 we must place
	ADD		EDI, ECX					; edgecase when we have a plus in front, which means we need an additional place
	MOV		ECX, 1
	CMP		ECX, [EBP + 32]				; See if the plus flag has activated
	JNE		_noPLus
	ADD		EDI, 1

_noPLus:
	MOV	ECX, 0
	MOV	[EBP + 32], ECX
	;POP ECX

	pop     ECX                            ; Restore outer loop counter
	loop    _outerLoop1

	pop EBP                                 ; Restore EBP
	RET 32                                  ; Clean the stack



readVal ENDP

;================================================================================
;	This procedure basically prints out the message saying this is what you gave,
;	and then we basically increment through the whole array using WriteVal to actually
;	write thestuff down besides the space and comma's.
;
;	EBP + 8 = SomeArray, the array we use
;	EBP	+ 12 = number buffer
;	EBP +  16, prints out 'these are the numbers given' message
;	EBP + 20 = space and comma for spacing out the values
;
;================================================================================

displayInput  PROC
	PUSH	EBP						
	MOV		EBP, esp				

	mDisplayString [EBP+16]			;CALL macro to display header message
	CALL	CrLf
	CALL	CrLf
	;mDisplayString [EBP+24]			

	MOV		esi, [EBP+8]			;save someArray esi
	MOV		ECX, TEN				;set loop counter
	cld								;direction = forward

	displayLoop: 
		PUSH	[EBP+12]			;PUSH temporary string to store converted value
		PUSH	esi					;PUSH current array value to be converted by writeVal 	
		CALL	writeVal			

		MOV		EAX,[esi]			;This is basically LODSD but instead we go up by 6 as specified prior
		ADD		esi, 6

		CMP		ECX, 1				;avoid comma after the last element
		je		endLoop
		mDisplayString [EBP+20]		;CALL macro to display comma and space
	  endLoop:
		loop	displayLoop
	

	pop EBP							;restore EBP
	ret 16							;clean the stack  

displayInput ENDP

;================================================================================
;	This is a subprocedure that is called by display inputs, basically is an innerloop but 
;   seperate to the outerloop that is display input, which feeds us the location of the value.
;   uses the same stack as display input basically
;	
;
;	We use PUSHAD to save all registries, so nothing is changed once it is processed
;   The pre condition of this is the ESI must be pointing towards a Array. No post conditions
;================================================================================

writeVal  PROC

	PUSH	EBP						;by convention, save EBP
	MOV		EBP, esp				;set stack pointer
	PUSHad							;save all registers 

	MOV		EDI, [EBP+8]			;point to value to be converted
	MOV		EAX, [EDI]				;EAX holds the whole number value
	xor		bx, bx					

	mDisplayString esi     

	MOV		ebx, 0					
	popad							;restore registers	
	pop		EBP							
	ret		8						

writeVal  ENDP


;================================================================================
;	This was the procedure that was supposed ot turn the values in the array into 
;	actual number values that could be added/altered away from the values they were
;   saved as, but in the end all of the different variables one has to account for 
;	turning ascii into numeric values made it impossible for me to accomplish
;
;
;	EBP + 8 =		Sum message
;	EBP + 12 =		Average message
;	EBP + 16 =		Array location
;	EBP + 20 =		digit 1
;	EBP + 24 =		digit 2
;	EBP + 28 =		digit 3
;	EBP + 32 =		digit 4
;	EBP + 36 =		sum
;	EBP + 40 =		negative flag
;
;	No post/pre conditiosn, everything changed
;
;================================================================================
SumAvg	PROC
	PUSH	EBP
	MOV		EBP, ESP

	CALL	Crlf
	mDisplayString [EBP+8] 			
	CALL	Crlf
	CALL	Crlf

	mDisplayString [EBP+12] 			
	CALL	Crlf
	CALL	Crlf

	MOV		ESI, [EBP + 16]

	_restart_loop:
	XOR		EAX, EAX
	XOR		ECX, ECX
	XOR		EDX, EDX


	; digit1 is EBX 20
	
_find_length:
    MOV		AX, [ESI]      ; Load the value at the current position into AX so we get 1 number
    TEST	AX, AX        ; We Loop through each individual digit seeing if it ends at 0 so we can find the lenght
    JZ		_end_loop        ; If the value is zero, end the loop
    INC		ECX            
    ADD		ESI, 1         ; MOVe to the next element
    JMP		_find_length    

_negative_sign:
	MOV	EAX, 1
	ADD		[EBP + 40], EAX
	MOV		EAX, 0
	MOV		[EBP + 20], EAX
	XOR		EAX, EAX
	JMP		negative_flag_set



_end_loop:
	MOV		ESI, [EBP + 16]
	XOR		EAX, EAX

	MOV		AL, [ESI]
	MOV		EDX, MINUS
	CMP		EDX, EAX
	JE		_negative_sign
	MOV		EBX, ZERO
	MOV [EBP + 20], EAX
	SUB [EBP + 20], EBX      ; Convert ASCII to numeric value ('0' = 48)
	CMP		ECX, 1
	JE		_one_digit

negative_flag_set:
	MOV		AL, [ESI + 1]
	MOV [EBP + 24], EAX   
	MOV		EBX, ZERO
	SUB [EBP + 24], EBX       ; Convert ASCII to numeric value ('0' = 48)
	CMP		ECX, 2
	JE		_two_digit

	MOV		AL, [ESI + 2]
		MOV [EBP + 28], EAX  
	MOV		EBX, ZERO
	SUB [EBP + 28], EBX        ; Convert ASCII to numeric value ('0' = 48)
	CMP		ECX, 3
	JE		_three_digit

	MOV		AL, [ESI + 3]
	MOV [EBP + 32], EAX  
	SUB [EBP + 32], EBX        ; Convert ASCII to numeric value ('0' = 48)




;Begin the actual transfer from ASCII to actual numbers for given array


	MOV		EAX, [EBP + 20]
	IMUL	EAX, 1000    
	MOV		[EBP + 20], EAX

	MOV		EAX, [EBP + 24]
IMUL	EAX, 100              ; Multiply by 100 to shift it to the tens place
MOV		[EBP + 24], EAX

MOV		EAX, [EBP + 28]
IMUL	EAX, 10              ; Multiply by 100 to shift it to the tens place
MOV		[EBP + 28], EAX

JMP _one_digit


_three_digit:

	MOV		EAX, [EBP + 20]
	IMUL	EAX, 100              ; Multiply by 100 to shift it to the tens place
	MOV		[EBP + 20], EAX

	MOV		EAX, [EBP + 24]
	IMUL	EAX, 10              ; Multiply by 100 to shift it to the tens place
	MOV		[EBP + 24], EAX

JMP _one_digit


_two_digit:

	MOV		EAX, [EBP + 20]
	IMUL	EAX, 10              ; Multiply by 10 to shift it to the tens place
	MOV		[EBP + 28], EAX

	JMP _one_digit

_one_digit:

	MOV		EAX, [EBP + 28]
	ADD		[EBP + 32], EAX

	MOV		EAX, [EBP + 24]
	ADD		[EBP + 32], EAX

	MOV		EAX, [EBP + 20]
	ADD		[EBP + 32], EAX       

	MOV		EAX, [EBP + 32]

	MOV		EBX, 1
	CMP		[EBP + 40], EBX
	JNE		not_negative
	neg		EAX

not_negative:
	ADD		[EBP + 36], EAX

	MOV	EAX, 6
	ADD ESI, EAX
	MOV	EAX, 0
	ADD		[EBP + 32], EAX    
	ADD		[EBP + 28], EAX    
	ADD		[EBP + 24], EAX    
	ADD		[EBP + 20], EAX    
	JMP		_restart_loop

;sum_loop:
	;XOR	EDX, EDX
    ;ADD EAX, [ESI]					; Load the ASCII character into EDX
   ; MOV	ESI, [ESI + 6]              ; Move to the next character in the array
   ; LOOP sum_loop						

    POP EBP                        
    RET                             
SumAvg ENDP
END main

