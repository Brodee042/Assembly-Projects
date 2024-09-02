TITLE Proj1_arbonb    (Proj1_arbonb.asm)

; Author: 	               Brody Arbon
; Last Modified:	       1/27/2024
; OSU email address:       arbonb@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 1        Due Date: 1/28/2024
; Description: This is the first project we do, it gets 3 numbers from the user, going from highest number to lowest number, which we check
; to make sure they are doing. We then use the numbers given to us to calculate how much they are added up or subtracted in various orders, 
; and we then display the results and the equation that got those results. We then and the procedure after printing a goodbye message.

INCLUDE Irvine32.inc

.data

Greeting		BYTE	"Elementary Arithemethic			by Brody Arbon", 0
Instructions	BYTE	" We ask you to input 3 numbers in descending order, highest number first, lowest number last", 0
Goodbye			BYTE	"Thanks for using this Program!  Click anything to exit!", 0
Error			BYTE	"Your values are not going from greatest to least!", 0
ExtraCredit		BYTE	"**EC: Program makes sure that the numbers are in descending order!!!**", 0

Prompt1			BYTE	"Please enter your 3 numbers, the first one here: ", 0
Prompt2			BYTE	"The second number here:  ", 0
Prompt3			BYTE	"The third, and least one here:  ", 0

Plus			BYTE	" + ", 0
Minus			BYTE	" - ", 0
Equals			BYTE	" = ", 0

uVal1			DWORD	0
uVal2			DWORD   0
uVal3			DWORD   0

SumAB			DWORD	0
DifferenceAB	DWORD	0
SumAC			DWORD	0
DifferenceAC	DWORD	0
SumBC			DWORD	0
DifferenceBC	DWORD	0
SumABC			DWORD	0
result			DWORD	0


.code
main PROC

_Introduction:

	; Prints greeting, extra credit sentence, aswell as instructions
	MOV		EDX, OFFSET Greeting
	Call	WriteString
	Call	CrLf
	Call	CrLf

	MOV		EDX, OFFSET ExtraCredit
	call	WriteString
	Call	CrLf
	Call	CrLf

	MOV		EDX, OFFSET Instructions
	call	WriteString
	Call	CrLf
	Call	CrLf

_User_Input:

	; gets users first and second number, then compares them to see if the second one is greater or not
	MOV	EDX, OFFSET Prompt1
	Call	WriteString
	Call	ReadDec
	MOV		uVal1, EAX
	Call	CrLf

	MOV		EDX, OFFSET Prompt2
	Call	WriteString
	Call	ReadDec
	MOV		uVal2, EAX
	Call	CrLf

	
	MOV		EBX, uVal2
	CMP		EBX, uVal1
	JG		if_B_greater_than_A                             ; Conditional Jump if B is greater than A
	JMP		Continue                                        ; If not, then jump to continue

if_B_greater_than_A: 
	MOV		EDX, OFFSET Error
	Call	WriteString
	CALL	CrLf
	CALL	CrLf
	JMP		_GoodBye										; Jumps to program exit

Continue:

	; gets users third number, then compares it to the second number to see if its greater
	MOV		EDX, OFFSET Prompt3
	Call	WriteString
	Call	ReadDec
	MOV		uVal3, EAX
	Call	CrLf

	MOV		EBX, uVal3
	CMP		EBX, uVal2
	JG		if_C_greater_than_B                             ; Conditional Jump if C is greater than B
	JMP		_Calculations                                   ; If not, then jump to _Calculations

if_C_greater_than_B: 
	MOV EDX, OFFSET Error
	Call	WriteString
	CALL	CrLf
	CALL	CrLf
	JMP		_GoodBye										; Jumps to program exit


_Calculations:

	; runs all nessecary calculations and puts them into 
	; A - B	
	MOV		EBX, uVal1
	SUB		EBX, uVal2
	MOV		DifferenceAB, EBX			

	; A + B
	MOV		EBX, uVal2
	ADD		EBX, uVal1
	MOV		SumAB, EBX				

	; A + C
	MOV		EBX, uVal1
	ADD		EBX, uVal3
	MOV		SumAC, EBX				

	; A - C
	MOV		EBX, uVal1				
	SUB		EBX, uVal3				
	MOV		DifferenceAC, EBX		

	; B + C
	MOV		EBX, uVal3				
	ADD		EBX, uVal2
	MOV		SumBC, EBX				

	; B - C
	MOV		EBX, uVal2
	SUB		EBX, uVal3
	MOV		DifferenceBC, EBX		

	; A + B + C
	MOV		EBX, uVal3
	ADD		EBX, uVal2
	ADD		EBX, uVal1
	MOV		SumABC, EBX				

_Output_Results:
	
	; Prints out all of the results
	; A - B
	MOV		EAX, uVal1
	CALL	WriteDec

	MOV		EDX, OFFSET Plus
	CALL	WriteString

	MOV		EAX, uVal2
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString


	MOV		EAX, SumAB
    CALL	WriteDec
	Call	CrLf



	; A - B
	MOV		EAX, uVal1
	CALL	WriteDec

	MOV		EDX, OFFSET Minus
	CALL	WriteString

	MOV		EAX, uVal2
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString

	MOV		EAX, DifferenceAB 
    CALL	WriteDec
	Call	CrLf



	; A + C
	MOV		EAX, uVal1
	CALL	WriteDec

	MOV		EDX, OFFSET Plus
	CALL	WriteString

	MOV		EAX, uVal3
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString


	MOV		EAX, SumAC
    CALL	WriteDec
	Call	CrLf
	
	; A - C
	MOV		EAX, uVal1
	CALL	WriteDec

	MOV		EDX, OFFSET Minus
	CALL	WriteString

	MOV		EAX, uVal3
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString

	MOV		EAX, DifferenceAC
    CALL	WriteDec
	Call	CrLf

	; B + C
	MOV		EAX, uVal2
	CALL	WriteDec

	MOV		EDX, OFFSET Plus
	CALL	WriteString

	MOV		EAX, uVal3
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString

	MOV		EAX, SumBC
    CALL	WriteDec
	Call	CrLf
	
	; B - C
	MOV		EAX, uVal2
	CALL	WriteDec

	MOV		EDX, OFFSET Minus
	CALL	WriteString

	MOV		EAX, uVal3
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString

	MOV		EAX, DifferenceBC
    CALL	WriteDec
	Call	CrLf

	; A + B + C
	MOV		EAX, uVal1
	CALL	WriteDec

	MOV		EDX, OFFSET Plus
	CALL	WriteString

	MOV		EAX, uVal2
	CALL	WriteDec

	MOV		EDX, OFFSET Plus
	CALL	WriteString

	MOV		EAX, uVal3
	CALL	WriteDec

	MOV		EDX, OFFSET Equals
	CALL	WriteString

	MOV		EAX, SumABC
    CALL	WriteDec
	Call	CrLf
	Call	CrLf

_GoodBye:

	; prints goodbye message then exits procedure
	MOV		EDX, OFFSET Goodbye
	Call	WriteString
	Call	CrLf

;         ASK WHY I NEED OFFSET FOR THE STRINGS AND NOT THE uVal's

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
