;; Prepare yourself to be amazed... or not really, it's just a very simple calculator.	
	org 0x7c00						; Our load address.

;; It controls the program flow and kind of everything.
control:
	mov bx, FNRequest				; Loads first number request string.
	call requestNumber  			; requests number.
	push bx 						; Pushes the first read number.
	call breakLine

	call requestOperator			; Calls operator to be requested.
	push bx							; Pushes operator.
	call breakLine

	mov bx, SNRequest				; Loads second number request string.
	call requestNumber				; Requests number.
	call breakLine

	pop cx							; Pops operator and stores it in cx.
	pop ax							; Pops first number and stores it in ax.
	call calculate					; Actually calculate... what did you expect "calculate" to do?
	call printResult    			; Prints the result.
	jmp end							; Ends program.
	


;; Requests a number and then reads it (Read number is stored in 'bx' (I don't know why either, 
;; guess Alex likes b)).
requestNumber:	     	 			; Write First number request string
	call printString	 			; Prints request string
	call readNumber		 			; Reads number (stored in bx)
	ret			 		 			; Return stuff

readNumber:							; Reads a number entered until a breakLine.
	mov bx, 0x0

readNumberLoop:
	mov ah, 0x0						; Reads a char entered.
	int 0x16

	cmp al, 0xd						; If it's a break line return.
	je readNumberRet

	mov ah, 0xe 					; Prints entered char.
	int 0x10

	cmp al, '0'						; Else, it checks if the entered char was a number,	
	jl invalidInput					; (That is '0' <= bx <= '9').
	cmp al, '9'						; If it isn't, jump to invalidInput error "treatment".
	jg invalidInput

	mov ch, 0x0
	mov cl, al						; Stores read digit in cx (zero-extending from 8 to 16 bits).
    sub cx, '0' 					; Transforms ASCII into integer.

    imul bx, 0xa					; Multiplies the number being read by 10 so that newly read int can be added.

	add bx, cx  					; Adds digit that was just read.

	jmp readNumberLoop  			; Loop stuff

readNumberRet:
	ret								; Return stuff
	

;; Prints the string that happens to be in bx.
printString:		
	mov ah, 0xe			
printStringLoop:
	mov al, [bx]					; Get the next char out of bx
	int 0x10						; Prints it
	cmp al, 0x0						; If it was a \0 return
	je printStringRet	
	add bx, 0x1						; Step
	jmp printStringLoop				; Loop stuff
printStringRet:
	ret


;; Prints the number that happens to be in bx.
printNumber:
	push 'A'						; Just so you don't need a count register.
	mov cx, 0xa						; Set cx to 10 to be the divisor.
printNumberLoop:					; This actually invert the number's digits for it to print properly.
	mov dx, 0x0						; Clears the remainder.
	mov ax, bx						; Move current number to ax.
	div cx							; Divide number by 10.

	mov bx, ax						; Move the quotient to be the number .

	add dx, '0'						; Adds '0' to make it the number's ASCII value.
	push dx							; Pushes number's last digit.
	cmp bx, 0x0						; If the number becomes 0 then this section is over
	jne printNumberLoop
finallyPrint:					
	pop dx							; Pop digits one by one
	cmp dx, 'A'						; If its an 'A' return (again, that's only so you don't need a counter)
	je printNumberRet				
	mov ah, 0xe						
	mov al, dl						; Print the digit's char.
	int 0x10
	jmp finallyPrint
printNumberRet:
	mov al, 0x0						; Prints a nice empty space after the number
	int 0x10						; (You never know when you'll need it).
	ret								

;; Requests a Operator and proceeds to read it.
requestOperator:
	mov bx, ORequest				; Load and prints operator request string.
	call printString

	mov ah, 0x0						; Reads a char and prints it
	int 0x16

	mov ah, 0xe
	int 0x10

	mov bx, 0x0
	mov bl, al						; Move char entered to bx to return it (for pattern sake I guess...)
	ret

;; Execute the calculation requested.
calculate:							; A switch() would have been useful...
	cmp cx, '+'						; If operator is '+'.
	je	sum							; Sum the operants
	cmp cx, '-'						; if it is '-'
	je 	subtr						; Subtract them
	cmp cx, '*'						; if '*'
	je	mult						; Multiply
	cmp cx, '/'						; You got it right?
	je  divi

	jmp invalidInput				; If the operator is none of the above jump to error "treatment".

;; This is like basic instructions I'm not commenting this.
sum:
	add ax, bx
	mov bx, ax
	ret
subtr:
	sub ax, bx
	mov bx, ax
	ret
mult:
	imul ax, bx
	mov bx, ax
	ret
divi:
	div bl
	mov bx, 0
	mov bl, al
	ret

;; Prints a nice line breaker.
breakLine:
	mov ah, 0xe						
	mov al, 0xd						; This is a \r.
	int 0x10
	mov al, 0xa						; This is a \n.
	int 0x10						; This prints them.
	ret								; This returns.

;; Prints the Results.
printResult:
	push bx							; Pushes bx not to lose everything we coded so hard for.
	mov bx, ResultString			; Loads	the result string and prints it.
	call printString				
	pop bx							; Pop back bx to be used in printNumber.
	call printNumber				; Prints the number.
	ret

;; Yeah this is what I call error treatment!
invalidInput:
	mov bx, ErrorString				; Prints a very informative and understanding message.
	call printString				; And lets the user start again (Such kindness...).

;; End but actually no.
end:								; And they don't stop coming.
	call breakLine					; Insert a break line
	jmp control						; Start everything again.

;; Strings used.
FNRequest: db 'Enter the first number', 0xd, 0xa, 0x0
SNRequest:	db 'Enter the second number', 0xd, 0xa, 0x0
ORequest: db 'Enter the Operator ('+', '-', '*', '/')', 0xd, 0xa, 0x0
ResultString: db 'The result is:', 0xd, 0xa, 0x0 
ErrorString: db 'Nope... u doin it poopy, try again', 0xd, 0xa, 0x0
	
	times 510 - ($-$$) db 0	; Pad with zeros
	dw 0xaa55		; Boot signature
