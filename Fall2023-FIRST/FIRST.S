; Name:		Mack Bautista
; Email:	mbaut981@mtroyal.ca
; Course:	COMP2655-002
; Instructor:	Paul Pospisil
; Assignment:	3 Phase 2
; Due Date: 	October 26, 2023

; SOURCE FILE:	FIRST.S

; PURPOSE: To receive an unsigned three digit character as input
; 	   and to assign it as an integer to be used to calculate
;          with the given formula. The following results should
;          be displayed as an unsigned three digit character.

; DETAILS:
; Input:	User is ask to input three unsigned digits as characters
; 
; Output:	Application of the following formula where
;		the resulting integer is converted in the
;		same format as the given input, i.e three
;		unsigned digits as characters - "101".
;
; Limitations:	 Program is designed to only handle positive
;		 integers, therefore nothing is made to handle
;		 negative integers or errors. Size is also limited
;		 from minimum to a maximum of "0 - 999".
;
; Formulas:	 
; 	- y = ((8 * x^2 - 5 * x + 1997) % 10000) / 10, where "x" is
;	  the user's input and "y" is the resulting integer 
;	- Horner's Rule = ((x * 10 + y) * 10 + z), where "x, y, z"
;	 are the most significant character input value, middle order
;	 input value, and least significant input value
;	
; Quirks:
;	- clearing of registers due to unknown values stored within
;	- swapping of most significant word(MSW) and least significant
;	  word(LSW), where the MSW is the remainder, LSW is the quotient
;	- clearing MSW to calculate quotient of standard division
;	- clearing unneccesary bits to what is being used
;	- operator "lsl.l" is used to replicate the multiplication of *8
;	  due to "mulu.w" working as a 16-bit operator on a 16-bit
;	  architechture               
;

; REGISTER TABLE:
; d0 - input - holds the character read from the keyboard
;    - output - holds the character being written to screen
;
; d1 - input - holds the first character from the screen
;    - output - holds the most significant character and significant digit
;               being written to screen
;    - results - holds the resulting integer from calculated formula 
;		 to which it is converted back as a character
;
; d2 - input - holds the middle order character from the screen
;    - output - holds the middle order character being written to screen
;    - results - holds the resulting integer from calculated 
;		 formula to which it is converted back as a character
;
; d3 - input - holds the least significant character read from the screen
;    - output - holds the least significant character being written to screen
;    - results - holds the resulting integer from calculated formula to which
;		 it is converted back as a character
;
; d4 - "x" variable/integer - computes three characters as an integer from the
;				 three digit input to be used in the given 
;				 formula and is used as the 5*x operation
;
; d5 - "y" variable/results - resulting calculation from the given formula
;				by substituting  "x" variable as an integer
;				and is used as the 8*x^2 operation

; STATUS:
; Plan:		The method of testing is to assign the register to a following
;		label in order to successfully match the correct result. Keep
;		in mind that the registers use hexadecimal, therefore using the
;		expression console provided by the debugger is essential to 
;		making sure the actual outcome is the correct value in 
;		its hexadecimal notation.
;
; Test Values:
;	- "000" - reason - tests how it would handle minimum value
;		- expected result - "199"
;		- actual result - "199"
;
;	- "999" - reason - tests how it would handle maximum value
;		- expected result - "101"
;		- actual result - "101"
;
;	- "231" - reason - tests how it would handle intermediate values
;		- expected result - "773"
;		- actual result - "773"
;
;	- "773" - reason - verifies what that expected result should be
;			   the actual result
;		- expected result - "998"
;		- actual result - "836"
;
;	- "1000" - reason - tests the outside range of the input
;		 - expected result - "699" : 
;		 - actual result - "149" : due to the three digit input limit
;
;	- "-1"	- reason - tests the negative input
;		- expected result - "201"
;		- actual result - "862" : mulu, divu are operators limited ONLY
;				 	  for handling UNSIGNED representation,
;					  and ASCII only operates on positive
;					  values because they are characters
;
;	- "abc" - reason - tests the literal character input
;		- expected result - "411"
;		- actual result - "862" : limited by numbered characters and 
;					  the following input converted to 
;					  an integer exceeds that of the 
;					  determined size 


DECIMAL 	equ	10		; base 10
CR		equ	13		; character return
LF		equ	10		; line feed 
MASK		equ	$0000FFFF	; usage of word size
ASCII		equ	'0'		; character literal of ASCII

start:		clr.l	d0		; all registers that are to be used
		clr.l	d1
		clr.l	d2
		clr.l	d3
		clr.l	d4
		clr.l	d5
	
input:		jsr	read_char
		move.b	d0,d1
		jsr	read_char
		move.b	d0,d2
		jsr	read_char
		move.b	d0,d3
	
cast_int:	sub.b	#ASCII,d1
		sub.b	#ASCII,d2
		sub.b	#ASCII,d3

horner:		move.w	d1,d4
		mulu.w	#DECIMAL,d4
		add.b	d2,d4
		mulu.w	#DECIMAL,d4
		add.b	d3,d4
		
y_result:	move.w	d4,d5
		mulu.w	d5,d5
		lsl.l	#3,d5		; working with 16-bit architecture 
		mulu.w	#5,d4		;  and seperates in power of 2^3=8
		sub.l	d4,d5
		add.w	#1997,d5
		divu.w	#10000,d5
		swap.w	d5
		and.l	#MASK,d5
		divu.w	#DECIMAL,d5

recycle:	clr.l	d3
		clr.l	d2
		clr.l	d1

lsi:		move.w	d5,d3		; isolates the least significant int
		divu.w	#DECIMAL,d3
		swap.w	d3
		and.l	#MASK,d3
		
moi:		move.w	d5,d2		; isolates the middle-order int
		divu.w	#DECIMAL,d2
		and.l	#MASK,d2
		divu.w	#DECIMAL,d2
		swap.w	d2
		and.l	#MASK,d2

msi:		move.w	d5,d1		; isolates the most significant int
		divu.w	#DECIMAL,d1
		and.l	#MASK,d1
		divu.w	#DECIMAL,d1
		and.l	#MASK,d1
		divu.w	#DECIMAL,d1
		swap.w	d1
		and.l	#MASK,d1
	
cast_char:	add.b	#ASCII,d1
		add.b	#ASCII,d2
		add.b	#ASCII,d3	
		
output:		clr.l	d0
		move.b	#CR,d0		; goes to new line
		jsr	write_char
		move.b	#LF,d0
		jsr	write_char

		move.b	d1,d0
		jsr	write_char
		move.b	d2,d0
		jsr	write_char
		move.b	d3,d0
		jsr	write_char

		move.b	#CR,d0		; goes to new line
		jsr	write_char
		move.b	#LF,d0
		jsr	write_char

		jsr	exit

;----- SUBROUTINE: read_char -----
;
; PURPOSE: waits for and reads a single keystroke from the keyboard.
;
; CALLER OUTPUT: returns the ASCII value of the key in the low byte
;                of D0.
;
; IMPORTANT: NOTE THAT THE HIGHER_ORDER BYTES OF D0 ARE UNDEFINED.
;            DON'T ASSUME THEY ARE ZEROED OUT!
;
; E.G. CALL:	jsr	read_char
;		... now use D0.b ...

read_char:	movem.l	d1-d2/a0-a2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp	
		movem.l	(sp)+,d1-d2/a0-a2
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character in the low byte
;               of D0.
;
; E.G. CALL:	move.b	#'a',d0
;		jsr	write_char

write_char:	movem.l	d0-d2/a0-a2,-(sp)
		and.w	#$00FF,d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		trap	#1
