	;; mbr.asm - A simple x86 bootloader example.
	;;
	;; In worship to the seven hacker gods and for the honor 
	;; of source code realm, we hereby humbly offer our sacred 
	;; "Hello World" sacrifice. May our code remain bugless.

	
	org 0x7c00		; Our load address

	mov ah, 0xe		; Configure BIOS teletype mode
					; to write
	mov bx, here	; May be 0 because org directive.

request:				; Write a 0x0-terminated ascii string
	mov al, [bx]	
	int 0x10
	cmp al, 0x0
	je read
	add bx, 0x1		
	jmp request

read:
	mov bx, 0

loopRead:
	mov ah, 0x0
	int 0x16

	cmp al, 0xd
	je calculate

	mov ah, 0xe
	int 0x10

	; imul bx, 0xa
	; sub al, 0x30

	; add bl, al

	movzx dx, al; Stores read digit in dx (zero-extendension from 8 to 16 bits)
    sub dx, '0' ; Transforms ASCII into integer (not checking if it is between '0' and '9')

    imul bx, 0xa; Multiplies the number being read by 10 so that newly read int can be added

    add bx, dx  ; Adds digit that was just read

	jmp loopRead
	
calculate:
	mov ax, bx
	mov dx, 0x0
	mov cx, 0x2
	div cx

	mov cx, bx

	cmp dx, 0x0
	je even

	mov bx, isOdd
	jmp printAnswer	
	
even:
	mov bx, isEven

printAnswer:
	mov dx, 0xa
	mov ax, cx
	div dx

	mov cx, ax

	mov al, dl
	add al, 0x30

	mov ah, 0xe
	int 0x10

	cmp cx, 0x0
	je printCase

	jmp printAnswer

printCase:
	mov ah, 0xe		
	mov al, [bx]	
	int 0x10
	cmp al, 0x0
	je end
	add bx, 0x1
	jmp printCase

end:				; Jump forever (same as jmp end)
	jmp $

here: db 'Enter a number please', 0xd, 0xa, 0x0
isEven: db 'eh par', 0xd, 0xa, 0x0
isOdd: db 'eh impar', 0xd, 0xa, 0x0
	
	times 510 - ($-$$) db 0	; Pad with zeros
	dw 0xaa55		; Boot signature

		
	;; Notes (remove these comments for your code).
	;; 
	;; This assembly source code is written for x86 architecture in intel 
	;; syntax and NASM  assembler dialect. It's mean to be compiled with 
	;; NASM assembler.
	;; 
	;; A label (such as 'loop:') is interpreted by the prepossessesor as
	;; the offset to (byte count at) the next command (jmp instruction, 
	;; in this example).
	;; 
	;; The directive org 0x7c00 intructs the compiler to automatically
	;; add the load address to the offset when necessary. Therefore,
	;; 'mov al, label' virtually becomes 'mov al, label + 0x7c00'. 
	;; 
	;; BIOS interruption 'int 0x10' causes the execution flow to jump to 
	;; the interruption vector table area, where there is a pre-loaded BIOS
	;; routine capable of outputing characters to the video controller.
	;; This interruption handler routine reads the byte at the 8-bit
	;; register and send to the video controller. The video operation
	;; mode (e.g. ascii character) is controlled by register ah.
	;; After completing the operation, execution flow is returned to
	;; the next line after 'int' instruction.
	;;
	;; The argument of jmp and je instructions, here, is a relative offset. 
	;;
	;; The line db causes the ouput of 1-byte patters at the current
	;; position in the generated machine code. For instance, the string
	;; 'Hello World' followed by newline and return ascii codes is inserted
	;; in the given location.
	;; 
	;; The directive 'times X Y' produces a sequence of X repetitions of
	;; of Y. The type specification 'db' means that Y is a byte (8 bits).
	;; If it were dw, it would mean 'word', i.e. 16 bits.
	;;
	;; Symbol $  denotes the address of (byte count at) the current line.
	;; Symbol $$ denotes the address of (byte count at) the start of current
	;; section (in present case, we have only one section). Therefore, the
	;; value ($-$$) is the current address minus the address of the
	;; program start. We need 510 minus this amount of zeros.
	;;
	;; The line dw causes the output of the 2-byte pattern for the boot
	;; signature at the current position (positions 511 and 512).
