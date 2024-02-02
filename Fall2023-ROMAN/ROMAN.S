; Name:		Mack Bautista
; Email:	mbaut981@mtroyal.ca
; Course:	COMP2655-002
; Instructor:	Paul Pospisil
; Assignment:	4
; Due Date: 	November 19, 2023
;
; Source File:	ROMAN.S

; PURPOSE:
; To convert a given Imrpoved Roman Numeral between 1-3999 into a
; Arabic notation. All inputs are read as characters and is to be
; outputted as decimal integers. 

; DETAILS:
; Input:	User is asked to input valid improved roman numerals
;		between 1-3999 and quits the program if the followig
;		character 'Q' is detected.  	
; 
; Output:	The program converts the roman numerals into decimal
;		integers. As long as the program is not forfeit, loops
;		the next input. Errors are handled and displayed on
;		the first position it occurs read left to right.
;
; Limitations: 	The program only handles unsigned integer representation
;		with the following range between "1-3999". Five error cases
;		are only handled. Input is limited to 20 characters.
;
; Quirks:	- Variables must be loaded to a data register to be compared
;		- Arrays of structures must be loaded to a data register to be
;		  used and compared
;		- Declaration and initialization of structure must be done during
;		  during assembly time
;		- Declaration of memory space being used
;		- Strings have to be loaded to an address register to be printed
;		- Strings have to be looped in order to be printed
;		- Branch conditions are tested opposite of the conditions

; REGISTER TABLE:
; d0-d2	- keeps track of changes made to variables and
;	  for input and output
;
; d0	- input - reads character inputs from keyboard as ASCII
;	- output - writes output as decimal integers
;	- s_index - tracks the s_index variable for indexed register
;		    with offset of string
;	-
;  
; d1 	- offset of all_roman structure initialization
;	- r_index - tracks the r_index variable for indexed register
;		    with offset of string and all_roman
;	- s_index - handles the offset position for handling location
;		    of error digit position
; 
; d2 	- r_last - handles the offset position for r_last
; 
; d3-d7 - is used for most branch conditions
;
; d3 	- sum - handles the sum of the given roman numerals
;	- all_roman[r_index].count
; 	
; d4 	- all_roman[r_index].max_times
;
; d5	- all_roman[s_index].sub_index
;	- all_roman[r_index].sub_index
;
; d6	- all_roman[r_index].modifier
;	- all_roman[s_index+1].sub_index
;
; d7	- all_roman[r_last].modifier
;	- all_roman[all_roman[r_index].sub_index].modifier
;
;
; a0 	- loads addressess of most print statements including
;	  error cases
;
; a1 	- all_roman - address location of all_roman 
;		      structure initialization
;
; a2	- sum - address location of sum for printing result  
;

; STATUS:
; Plan:	To test values in which it is represented as a word and a byte. 
;	Assign inputs that tests how the program handles the processing of
;	specific sizes. Document proper error results as it is a part of the
;	input/output results of the program.
;
; Fail:	Failure to handle error occurs when dealing with error case 4, and 5.
;	Errors occur when the next input is loaded, in which previous data
;	is transferred to the next input. This results in miscalculations and
;	error handling.  
;
; Test Values:
;	- "I"		- minimum value
;			- expected result: "1"
;			- actual result: "1"
;
;	- "MMMCMXCIX"	- maximum value
;			- expected result: "3999"
;			- actual result: "3999"
;
;	- "CCLV" 	- maximum value of a byte
;			- expected result: "255" 
;			- actual result: "255"
;
;	- "CCLIV" 	- maximum range of a byte
;			- expected result: "254"
;			- actual result: "254"
;
;	- "CCLVI"	- beginning of size word
;		 	- expected result: "256"
;			- actual result: "256"
;
;	- "CCLVIII"	- maximum "I's" in a given input
;			- expected result: "258"
;			- actual result: "258"
;	
;	- "IK"		- error case 1: invalid roman "K"
;	- "LMK"		- error case 2: out of order
;
;	- "CMC"		- provided as error 3 example
;			- expected result:
;				error case 3: already modified
;			- actual result:
;				"1000" - branching error 
;	- "XCL"		- provided as error 4 example
;			- expected result:
;				error case 4: illegal combination
;			- actual result:
;				"140" - branching error
;
;	- "IIIII"	- error case 5: exceeded max occurences

ext_sr:		xref	write_char
		xref	read_char
		xref	exit

DECIMAL		equ	10	;base 10
ASCII		equ	'0'	;beginning of ASCII integers
OP_PAR		equ	'('	;opening parenthesis
CL_PAR		equ	')'	;closing parenthesis

CR		equ	13	;character return
LF		equ	10	;line field

MAX_ROMANS	equ	7 	;maximum romans allowed
MAX_STRING	equ	20	;maximum string allowed
NO_ERROR	equ	0
MAX_DIG_COUNT 	equ	3	
C_NULL		equ	0	;null terminator
QUIT		equ	'Q'	;to exit program

DIGIT		equ	0
ARAB_VALUE	equ	2
SUB_INDEX	equ	4
COUNT		equ	5
MODIFIED	equ	6
MODIFIER	equ	7
MAX_TIMES	equ	8
ROMAN_DIGIT_SZ	equ	10


init_struct:	lea	all_roman,a1
		clr.l	d1

roman_1:	move.b	#'I',DIGIT(a1,d1)
		move.w	#1,ARAB_VALUE(a1,d1)
		move.b	#-1,SUB_INDEX(a1,d1)	
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#MAX_DIG_COUNT,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1

roman_5:	move.b	#'V',DIGIT(a1,d1)
		move.w	#5,ARAB_VALUE(a1,d1)
		clr.b	SUB_INDEX(a1,d1)
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#1,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1

roman_10:	move.b	#'X',DIGIT(a1,d1)
		move.w	#10,ARAB_VALUE(a1,d1)
		clr.b	SUB_INDEX(a1,d1)
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#MAX_DIG_COUNT,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1									
	
roman_50:	move.b	#'L',DIGIT(a1,d1)
		move.w	#50,ARAB_VALUE(a1,d1)
		move.b	#2,SUB_INDEX(a1,d1)
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#1,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1

roman_100:	move.b	#'C',DIGIT(a1,d1)
		move.w	#100,ARAB_VALUE(a1,d1)
		move.b	#2,SUB_INDEX(a1,d1)
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#MAX_DIG_COUNT,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1

roman_500:	move.b	#'D',DIGIT(a1,d1)
		move.w	#500,ARAB_VALUE(a1,d1)
		move.b	#4,SUB_INDEX(a1,d1)
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#1,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1

roman_1000:	move.b	#'M',DIGIT(a1,d1)
		move.w	#1000,ARAB_VALUE(a1,d1)
		move.b	#4,SUB_INDEX(a1,d1)
		clr.b	COUNT(a1,d1)
		move.b	false,MODIFIED(a1,d1)
		move.b	false,MODIFIER(a1,d1)
		move.b	#MAX_DIG_COUNT,MAX_TIMES(a1,d1)
		add.w	#ROMAN_DIGIT_SZ,d1
		clr.l	d1

load_txt:	lea 	PROG_TXT,a0	;loads program text box
		clr.l	d0

print_txt:	move.b	(a0)+,d0
		beq	load_input
		jsr	write_char
		bra	print_txt

load_input:	lea	PROG_INPUT,a0	;loads input text box
		clr.l	d0

print_input:	move.b	(a0)+,d0
		beq	user_array
		jsr	write_char
		bra	print_input

user_array:	lea	string,a0

scanf_roman:	clr.l	d0
		jsr	read_char
		move.b	d0,(a0)+		
		cmp.b	#CR,d0
		bne	scanf_roman
		clr.b	-(a0)		;clears CR

reload_string:	lea	string,a0	;reload to string[0]
		cmp.b	#QUIT,(a0)
		beq	to_quit

init_var:	move.w	#0,sum
		move.b	#0,s_index
		move.b	#MAX_ROMANS-1,r_last
		move.b	#NO_ERROR,error

valid_entr:	move.b	s_index,d0
		cmp.b	#C_NULL,(a0,d0)
		beq	find_error
		cmp.b	#NO_ERROR,error
		bne	find_error
		move.b	#MAX_ROMANS-1,r_index	
		
find_digit:	tst.b	r_index		;not at beginning of string
		blt	eval_digit
		move.b	r_index,d1
		mulu.w	#ROMAN_DIGIT_SZ,d1
		move.b	DIGIT(a1,d1),d4
		cmp.b	(a0,d0),d4
		beq	eval_digit
		sub.b	#1,r_index
		bra	find_digit	
		
eval_digit:	tst.b	r_index
		bge	order_digit

error1:		move.b	#1,error
		bra	valid_entr

order_digit:	move.b	r_index,d1	;update register after r_index
		move.b	r_last,d2
		cmp.b	d2,d1
		ble	valid_combine
	
		mulu.w	#ROMAN_DIGIT_SZ,d1
		mulu.w	#ROMAN_DIGIT_SZ,d2

		move.b	SUB_INDEX(a1,d1),d3
		cmp.b	r_last,d3
		beq	valid_order
		cmp.b	#1,COUNT(a1,d2)
		blo	valid_order

error2:		move.b	#2,error
		bra	valid_entr
		
valid_order:	move.w	sum,d3
		add.w	ARAB_VALUE(a1,d1),d3
		move.w	ARAB_VALUE(a1,d2),d4
		mulu.w	#2,d4
		sub.w	d4,d3
		move.w	d3,sum

is_modified:	move.b	SUB_INDEX(a1,d1),d4
		sub.b	#1,COUNT(a1,d4)
		add.b	#1,COUNT(a1,d1)														
		move.b	true,MODIFIED(a1,d1)	
		move.b	true,MODIFIER(a1,d4)	
		bra	no_error		;end of branch path																																

valid_combine:	mulu.w	#ROMAN_DIGIT_SZ,d1
		tst.b	MODIFIER(a1,d1)
		beq	legal_digit

error3:		move.b	#3,error
		bra	valid_entr

legal_digit:	move.b	SUB_INDEX(a1,d1),d5
		move.b	r_index+1,d1
		mulu.w	#ROMAN_DIGIT_SZ,d1
		move.b	SUB_INDEX(a1,d1),d6			
		cmp.b	d5,d6
		bne	max_dig
		tst.b	MODIFIER(a1,d5)
		beq	max_dig

error4:		move.b	#4,error
		bra	valid_entr

max_dig:	clr.l	d3
		clr.l	d4
		move.b	r_index,d1
		mulu.w	#ROMAN_DIGIT_SZ,d1
		add.b	#1,COUNT(a1,d1)
		move.b	COUNT(a1,d1),d3
		move.b	MAX_TIMES(a1,d1),d4
		cmp.b	d4,d3
		bgt	error5

get_sum:	move.w	sum,d3
		add.w	ARAB_VALUE(a1,d1),d3
		move.w	d3,sum
		move.b	r_index,r_last
		bra	no_error	; end of branch path

error5:		move.b	#5,error
		bra	valid_entr	
		
no_error:	cmp.b	#NO_ERROR,error
		bne	find_error
		add.b	#1,s_index
		move.b	r_index,r_last
		bra	valid_entr

find_error:	tst.b	error
		beq	load_sum
		lea	PROG_ERR_POS,a0

print_error:	move.b	(a0)+,d0
		beq	load_pos
		jsr	write_char
		bra	print_error

load_pos:	lea	s_index,a0

print_pos:	cmpa.l	#s_index,a0
		bne	open_pare
		move.b	(a0)+,d0
		add.b	#ASCII,d0
		jsr	write_char
		bra	print_pos

open_pare:	move.b	#OP_PAR,d0
		jsr write_char			

load_digit:	lea	string,a0
		move.b	s_index,d1

print_digit:	cmp.b	s_index,d1
		bne	close_pare
		move.b	(a0,d1),d0
		jsr	write_char
		add.b	#1,d1
		bra	print_digit

close_pare:	move.b	#CL_PAR,d0
		jsr	write_char

next_line:	move.b	#CR,d0
		jsr	write_char
		move.b	#LF,d0
		jsr	write_char
		clr.l	d0	
		
case_1:		cmp.b	#1,error
		bne	case_2
		lea	ERR_POS_1,a0
		beq	print_case

case_2:		cmp.b	#2,error
		bne	case_3
		lea	ERR_POS_2,a0
		beq	print_case

case_3:		cmp.b	#3,error
		bne	case_4
		lea	ERR_POS_3,a0
		beq	print_case

case_4:		cmp.b	#4,error
		bne	case_5
		lea	ERR_POS_4,a0
		beq	print_case

case_5:		cmp.b	#5,error
		bhi	case_def
		lea	ERR_POS_5,a0
		beq	print_case

case_def:	lea	ERR_POS_5,a0
		bra	print_case

print_case:	clr.l	d0
		move.b	(a0)+,d0
		beq	i_counter
		jsr	write_char
		bra	print_case
	
load_sum:	lea	sum,a2
		move.w	sum,d2
		
		move.b	#LF,d0
		jsr	write_char

convert_sum:	divu.w	#DECIMAL,d2
		swap	d2
		add.b	#ASCII,d2
		move.b	d2,(a2)+
		clr.w	d2
		swap	d2
		bne	convert_sum

print_sum:	cmpa.l	#sum,a2
		beq	print_cr
		move.b	-(a2),d0
		jsr	write_char
		bra	print_sum
		
print_cr:	move.b	#LF,d0
		jsr	write_char

i_counter:	move.b	#0,i

reset_struct:	cmp.b	#MAX_ROMANS,i
		beq	reload_prompt
		move.b	i,d7
		mulu.w	#ROMAN_DIGIT_SZ,d7
		clr.b	COUNT(a1,d7)
		move.b	false,MODIFIED(a1,d7)
		move.b	false,MODIFIER(a1,d7)
		add.b	#1,i
		bra	reset_struct

reload_prompt:	bra	load_input

to_quit:	jsr exit			

		
; MEMORY DECLARATIONS
 
PROG_TXT:	dc.b	CR,LF,"This program converts numbers in "
		dc.b	"Improved Roman notation to Arabic notation.",CR,LF
		dc.b	"	Input is limited to UPPER case Roman digits only.",CR,LF
		dc.b	"	To exit the program type only the Enter key.",CR,LF,C_NULL

PROG_INPUT:	dc.b	CR,LF,"Input a Roman number (Press 'Q' to exit): ",C_NULL	 

PROG_ERR_POS:	dc.b	CR,LF,"Character at position ",C_NULL
ERR_POS_1:	dc.b	"	is not a valid Roman digit",CR,LF,C_NULL
ERR_POS_2:	dc.b	"	is out of order for a Improved Roman number",CR,LF,C_NULL
ERR_POS_3:	dc.b	"	has been used as a modifier and can't be used unmodified",CR,LF,C_NULL
ERR_POS_4:	dc.b	"	combination of the modified prior digit and this digit is ",CR,LF	
		dc.b	"	an invalid Roman number",CR,LF,C_NULL	
ERR_POS_5:	dc.b	"	has exceeded the maximum occurences for this digit",CR,LF,C_NULL
ERR_DEF:	dc.b	"In error handling with an invalid error code",CR,LF,C_NULL

true:		dc.b	1
false:		dc.b	0

all_roman:	ds.b	ROMAN_DIGIT_SZ*MAX_ROMANS
string:		ds.b	MAX_STRING+1
s_index:	ds.b	1
r_last:		ds.b	1
r_index:	ds.b	1
i:		ds.b	1
error		ds.b	1
sum:		ds.b	4