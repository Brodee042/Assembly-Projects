TITLE Proj4_arbonb     (Proj_arbonb.asm)

; Author: Brody Arbon
; Last Modified: 2/25/2024
; OSU email address: arbonb@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 4 - Nested Loops                 Due Date: 2/25/2024
;
; Description: This project essentially gets a number from the user after displaying instructions, 
; then displays an amount of prime numbers equal to the given number up to 200 numbers, starting from 2 and up. 
; This is done through the use of nested loops, which loop through numbers to make sure they are divisible by 1
; only. Once we display the prime numbers we print a final message and end the program

INCLUDE Irvine32.inc


; (insert constant definitions here)
UPPER_LIMIT = 200
LOWER_LIMIT = 1

.data

header			BYTE	"Prime Number Finder by Brody Arbon", 0
instruction		BYTE	"enter the amount of prime numbers, starting from 0, that you would like to see.",  0
instruction2	BYTE	"We can only go up to 200 numbers though.", 0
instruction3	BYTE	"Please enter a number between 1 and 200 as an amount of prime numbers to display: ", 0
rangeerror		BYTE	"Close!, your number has to be between 1 and 200!", 0
farewellmsg		BYTE	"Alright, the program is done, feel free to click a button to exit..... Anytime now...", 0
spacing			BYTE	"   ", 0

uVal1			SDWORD	?
ticker			SDWORD	0
divisor			SDWORD	1
lineticker		SDWORD	0

.code

;====================================================================================
; Calls all needed procedures, changes EAX, EBX, ECX, EDX
;====================================================================================
main PROC
	CALL	introduction
	CALL	get_user_data
	CALL	show_primes
	CALL	farewell
	Invoke ExitProcess,0	; exit to operating system
main ENDP

;====================================================================================
; the 'introduction' procedure prints out header, instruction, and instruction 2
; no post or preconditions            EDX changed
;====================================================================================
introduction	PROC

	; This overall just prints out all the pertinent information the user needs
	MOV		EDX, offset header
	CALL	WriteString
	CALL	Crlf
	MOV		EDX, offset instruction
	CALL	WriteString
	CALL	Crlf
	MOV		EDX, offset instruction2
	CALL	WriteString
	CALL	Crlf

introduction	ENDP

;====================================================================================
; the 'get_user_data' procedure gets a user number, checks it against constants to 
; make sure it is between them, then sets ECX to the user value for the later loop
;
; receives uVal1, then changes ECX to it, also changes EDX
;====================================================================================
get_user_data	PROC

  ; prints prompt, and gets user input
  MOV	EDX, OFFSET instruction3
  CALL	WriteString
  CALL	ReadInt
  MOV	uVal1, EAX

  _validate:
  ; checks to see number is between 1 and 200
  CMP	uVal1, LOWER_LIMIT
  JL	_error

  CMP	uVal1, UPPER_LIMIT
  JG	_error

  ; sets the loop value to the value recieved, meaning we will give the numbers 
  MOV	ECX, uVal1
  JMP	show_primes


  _error:

  ; prints error message, then restarts PROC
  MOV	EDX, OFFSET rangeerror
  CALL	WriteString
  CALL	Crlf

  JMP	get_user_data

 ; put _validated in here if it being in show_primes doesn't work
get_user_data	ENDP

;====================================================================================
; the 'show_prime' starts at 0, then ticks through numbers until we get the amount of
; requested prime numbers out of the loop. This works by using LOOP whenever we get/
; print a prime number. We also check to make sure it is divisble only by 1 IE prime
; We first check to see if its divisible by 2 since 50% of #'s are even, then we try to 
; divide it by all #'s less then it IE 23 divided by 1, 2, 3, 4, 5... till we reach 23.
; 
;
; needs ECX to be set prior, and it changes ECX, EAX, EDX, EBX
;====================================================================================
show_primes PROC
  ; we increment the ticker by 1 until we get however many prime numbers that the user desires

  _validated:
  INC	ticker
  XOR	EDX, EDX				  ; EDX must be clear for DIV to work properly


  ; 1 breaks the DIV
  MOV	EAX, ticker
  CMP	EAX, 1
  JE	_validated

  ; Divides ticker number by 2, and if their is 1 as a remainder, it is prime, if its zero, then non-prime
  MOV	EAX, ticker
  MOV	EBX, 2
  DIV	EBX
  CMP	EAX, 1
  JE	_prime_numbers
  CMP	EDX, 0
  JE	_non_prime

  XOR EDX, EDX	
  MOV divisor, 2


  _rest_of_possible_divisors:
  ; we divide the ticker # by the divisor number, which increments until it is the same # as the ticker, which means prime

  XOR	EDX, EDX					; Took me an hour to figure out I forgot this in the loop :(
  INC	divisor         

  MOV	EAX, ticker
  MOV	EBX, divisor
  DIV	EBX
  CMP	EAX, 1					; This gets the prime numbers once we divided x by itself IE looped all numbers
  JE	_prime_numbers
  CMP	EDX, 0
  JE	_non_prime


  MOV	EAX, ticker
  CMP	divisor, EAX  
  JL	_rest_of_possible_divisors
  ; JMP	_prime_numbers    don't think this is used, but if somethign breaks


  _print_prime:
  ; actually prints out numbers alongside the spacing, also increments teh line ticker so we know when new line needed

  INC lineticker
  MOV	EAX, ticker
  CALL	WriteDec

  MOV	EDX, OFFSET spacing
  CALL	WriteString

  LOOP	_validated				  ; once printed we loop back and deincrement ECX
  JMP	farewell				  ; once loop is done this is used

  _prime_numbers:
  ; checks to see if we need a new line, if not we go to print prime

  CMP	lineticker, 10
  JE	_new_line
  JMP	_print_prime


  _new_line:
  ; creates a new line, then resets the line ticker

  CALL	Crlf
  MOV	lineticker, 0				  ; resets lineticker
  JMP	_print_prime

  _non_prime:
  ; restarts loop, but doesn't increment ECX as we only do that when we get prime. 
  ; Also checks to make sure we aren't looping infinetely because integer overflow (I think that was the issue)

  CMP	ECX, 0
  JG	_validated


show_primes ENDP

;====================================================================================
; the procedure 'farewell' just prints out a farewell message
;
; no conditions whatsoever, changes EDX
;====================================================================================
farewell PROC
; This just prints out the farewell message

 CALL	Crlf
 CALL	Crlf
 MOV	EDX, OFFSET farewellmsg
 CALL	WriteString
 CALL	Crlf

farewell ENDP

END main
