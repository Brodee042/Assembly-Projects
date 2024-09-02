TITLE Macro Demo Program     (MacroDemo.asm)

; Author: Redfield
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This program demonstrates how macros are defined and invoked
;				with arguments.
;
; NOTE: When a macro is invoked,  the complete code is substituted
;				for the macro name,  and the parameter placeholders are replaced
;				with the arguments

INCLUDE Irvine32.inc

myWriteString	MACRO	buffer
	PUSH  EDX				;Save EDX register
	MOV   EDX,  OFFSET buffer
	CALL  WriteString
	POP   EDX				;Restore EDX
ENDM

PrintSeq  MACRO	low,  high
	LOCAL	_test,  _quit	;Note local labels to avoid duplicate labels
								;   if macro is called more than once
	PUSH  EAX				;save registers
	PUSH  EBX
	MOV   EAX, low
	MOV   EBX, high
_test:
	cmp	EAX, EBX
	jg	_quit				;quit if we've reached last number
	PUSH  EAX			;Save EAX,  so we can print a space
	CALL  WriteDec
	MOV   AL, ' '
	CALL  WriteChar	;Print space
	POP   EAX			;Restore EAX
	inc	EAX			;next integer
	jmp	_test
_quit:
	CALL  CrLf
	POP   EBX			;restore registers
	POP   EAX
ENDM

.data
a		DWORD	?		;lower limit
b		DWORD	?		;upper limit
rules1	BYTE		"Enter a lower limit and an upper limit,  and I'll print", 10, 13, 0
rules2	BYTE		"the integer sequence from lower to upper.", 0
rules3	BYTE		"Here are some examples:", 10, 13, 0
prompt1	BYTE		"Lower limit: ", 0
prompt2	BYTE		"Upper limit: ", 0

.code
main PROC
	myWriteString   rules1		;Note the "short" way to print a string
	myWriteString   rules2
	call CrLf
	myWriteString   rules3
 	PrintSeq  1, 10				;Invoke SumSeq with immediate values
	MOV   ECX, 10
	MOV   EDX, 20
	PrintSeq  ECX, EDX			;Invoke SumSeq with register contents
	myWriteString   prompt1
	CALL  ReadInt
	MOV   a, EAX
	myWriteString   prompt2
	CALL  ReadInt
	MOV   b, EAX
	PrintSeq  a, b				;Invoke SumSeq with memory contents

	INVOKE ExitProcess, 0	;exit to operating system
main ENDP

END main
