
TITLE Proj3_arbonb     (Proj3_arbonb.asm)

; Author: Brody Arbon
; Last Modified:            2/12/2024
; OSU email address:        arbonb@oregonstate.edu
; Course number/section:    CS271 Section 400
; Project Number: Project 3                 Due Date: 2/11/2024
; Description: Prints out the highest number, lowest number, the sum of all numbers recieved, the amount of numbers recieved, and the average which is rounded
; We get these numbers via a loop/accumulator, which gets a users input, verifies it is in the range we want, and then we compare to the min and max already in the system,
; add it to the sum, and increment the total loop number. We keep doing that till we get a positive number, then we print out the above info.

INCLUDE Irvine32.inc

; (insert constant definitions here)

; constants we will use to determine if value is in range
LOWER_LIMIT_A = -200
UPPER_LIMIT_A = -100
LOWER_LIMIT_B = -50
UPPER_LIMIT_B = -1

.data
header			BYTE    "Integer Accumulator by Brody Arbon",0
instruction     BYTE    "We will be accumulating user-input negative integers between the specified bounds, then displaying statistics of the input values including minimum, maximum, and average values values, total sum, and total number of valid inputs.",0
username		BYTE    "What is your name?: ",0
reaction		BYTE	"Thanks for using this program, ", 0
parameter		BYTE	"Please enter numbers in [-200, -100] or [-50, -1].", 0 
enternumber		BYTE	"Enter a number: ", 0
error           BYTE    "Please enter a number within the range specified (INVALID INPUT)", 0
error2          BYTE    "You entered a number which shuts the program down with no numbers inputted", 0
goodbye			BYTE	"You got to the end of the program, congrats ", 0

maxnumber       BYTE    "The max number entered is: ",0
minimumnumber   BYTE    "The minimum number entered is: ", 0
sumofnumbers    BYTE    "The sum of the numbers you've inputted is: ", 0
enterednumbers  BYTE    "You entered this many valid numbers: ", 0 
averagenumber   BYTE    "The average of all the numbers entered is: ", 0



; these variables will change throughout the program
uVal1			SDWORD	?
given_name		BYTE    24 DUP(0) ; input buffer
byteCount		DWORD   ? ; holds counter

loop_count      SDWORD   0
remainder       SDWORD   0
number_sum      SDWORD   0
number_average  SDWORD   0
max_value       SDWORD   ?
min_value       SDWORD   ?


.code
main PROC

  ; prints off header and instructions
  MOV EDX, OFFSET header
  CALL  WriteString
  CALL	CrLf
  CALL	CrLf
  MOV   EDX, OFFSET instruction
  CALL  WriteString
  CALL  Crlf

  ; prints prompt asking for users' name
  MOV   EDX, OFFSET username
  CALL  WriteString

  ; gets the users name here and also gets the bytecount so we can print it out later, then greets them
  MOV   EDX, OFFSET given_name
  MOV   ECX, SIZEOF given_name
  CALL  ReadString 
  MOV   byteCount, EAX 
  MOV   EDX, OFFSET reaction
  CALL  WriteString
  MOV   EDX, OFFSET given_name
  CALL  WriteString

  CALL  Crlf
  CALL  Crlf

  ; tells the user the range they must input
  MOV   EDX, OFFSET parameter
  CALL  WriteString
  CALL  Crlf

  ; sets the max value to lowest number allowed and min value to the highest number so when we compare they automatically are replaced since 0 wouldn't work
  MOV	max_value, LOWER_LIMIT_A
  MOV	min_value, UPPER_LIMIT_B

_value_loop:
  ; loops for however long the user wants adding each number to to a sum, and if needed the min or max after they are verified

  ; prints enter number prompt, gets number and saves to uVal1
  MOV	EDX, OFFSET enternumber
  CALL	WriteString
  CALL	ReadInt
  MOV	uVal1, EAX

  ; breaks out of loop to do calculations if sign flag is positive
  MOV	EBX, uVal1
  JNS	_calculations

  ; checks to see if number x < -200, goes to error if so
  MOV	EBX, LOWER_LIMIT_A
  CMP	uVal1, EBX
  JL	_error

  ; checks to see if number x =< -100, if so jumps to verified since its between -200 and -100
  CMP	uVal1, UPPER_LIMIT_A
  JLE	_verified

  ; checks to see if x < -50, returns error if so
  CMP	uVal1, LOWER_LIMIT_B
  JL	_error

  ; checks to see if x > -1, returns error if so
  CMP	uVal1, UPPER_LIMIT_B
  JG	_error


_verified:
  ; we then add numbers to sum and replace min or max after they are verified

  ; if uVal1 is less than the min value, then replace it
  MOV	EBX, uVal1
  CMP	EBX, min_value
  JL	_replace_min

  ; if uVal1 is greater than the max value, then replace it
  MOV	EBX, uVal1
  CMP	EBX, max_value
  JG	_replace_max

  ; adds value to number_sum
  MOV	EBX, uVal1
  ADD	number_sum, EBX

  ; increments the loop count so we know how many numbers we've recieved
  INC	loop_count

  ; restart loop
  JMP	_value_loop

_replace_min:
  ; replaces min_value then jumps to verified
  MOV	EBX, uVal1
  MOV	min_value, EBX
  JMP	_verified

_replace_max:
  ; replaces max_value then jumps to verified
  MOV	EBX, uVal1
  MOV	max_value, EBX
  JMP	_verified



_error:
  ; prints out error message, then restarts the loop
  MOV	EDX, OFFSET error
  CALl	WriteString
  CALL  Crlf
  JMP	_value_loop

_no_input:
  ;  only print this out if we got no numbers at all prior to a positive one, then ends program
  MOV	EDX, OFFSET error2
  CALl	WriteString
  CALL  Crlf
  JMP	_exit_program

_calculations:
  ; does all of the calculations IE the averages and also prints out all the needed information

  ; checks to see if we've done atleast one loop, if not jump to error message
  CALL	Crlf
  CMP	loop_count, 1
  JL	_no_input

  ; prints min number
  MOV	EDX, OFFSET minimumnumber
  CALL	WriteString
  MOV	EAX, min_value
  CALL	WriteInt
  CALL  Crlf
  CALL	Crlf

  ; prints max number
  MOV	EDX, OFFSET maxnumber
  CALL	WriteString
  MOV	EAX, max_value
  CALL	WriteInt
  CALL  Crlf
  CALL	Crlf

  ; prints sum of numbers
  MOV	EDX, OFFSET sumofnumbers
  CALL	WriteString
  MOV	EAX, number_sum
  call	WriteInt
  CALL	Crlf
  CALL	Crlf

  ; prints of loopcount/how many numbers entered
  MOV	EDX, OFFSET enterednumbers
  CALL	WriteString
  MOV	EAX, loop_count
  CALL	WriteInt
  CALL  Crlf

  ; initial division of total sum by the loop count
  MOV	EAX, number_sum
  CDQ
  IDIV	loop_count

  MOV	remainder, EDX        ; store the remainder 
  MOV	number_average, EAX   ; store the calculated average in number_average

  ; Check to see if rounding is needed by 
  MOV	EAX, number_average
  MOV	ECX, 2
  CDQ
  IDIV	ECX 

  CMP	remainder, EAX        ; remainder is what is leftover after division to figure out initial average, EAX is the average we got / 2, meaning if EAX is less than the remainder we have to round 
  JL	rounding 

  ; prints off the number average
  CALL	Crlf
  MOV	EDX, OFFSET averagenumber
  CALL	WriteString
  MOV	EAX, number_average
  CALL	WriteInt
  CALL	Crlf
  CALL	Crlf

  ; prints off a goodbye message & name
  MOV	EDX, OFFSET goodbye
  CALL	WriteString
  MOV   EDX, OFFSET given_name
  MOV   ECX, byteCount 
  CALL  WriteString

  JMP	_exit_program

rounding:
  ; adds -1 so as to round it 'up' then prints
  ADD	number_average, -1

  ; prints out number average
  CALL	Crlf
  MOV	EDX, OFFSET averagenumber
  CALL	WriteString
  MOV	EAX, number_average
  CALL	WriteInt
  CALL	Crlf
  CALL	Crlf

  ; prints goodbye and name
  MOV	EDX, OFFSET goodbye
  CALL	WriteString
  MOV   EDX, OFFSET given_name
  MOV   ECX, byteCount 
  CALL  WriteString
  CALL	Crlf

  JMP	_exit_program


_exit_program:
main ENDP

; (insert additional procedures here)

END main
