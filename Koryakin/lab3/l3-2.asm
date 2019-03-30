TESTPC SEGMENT
 ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
 ORG 100H
 START: JMP FIRST

AV_MEM db 'available memory:'
WORD_BYTE db '         byte',0DH,0AH,'$'
EX_MEM db 'extended memory:'
CHAR_KB db '        Kb',0DH,0AH,'$'
FOR_LMCB db 'Address    Owner        Size Name',0DH,0AH,'$'
LIST_MCB db '                             $'
STRENDL db 0DH,0AH,'$'

PRINT PROC
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
PRINT ENDP

MAIN PROC
push ax
push bx
push cx
push dx
push es
;print available memory
	mov ah,4Ah
	mov bx,0FFFFh 
	int 21h
	mov ax,bx 
	mov bx,16
	mul bx 
	mov si,offset WORD_BYTE+7
	call TO_DEC
	mov dx,offset AV_MEM
	call PRINT

	
	mov bx,offset stc_p
	add bx,0Fh
	push cx
	mov cl,4
	shr bx,cl
	pop cx
	xor al,al
	mov ah, 4ah
	int 21h

;print extended memory
	mov  AL,30h
    	out 70h,AL
    	in AL,71h
    	mov BL,AL
    	mov AL,31h
    	out 70h,AL
    	in AL,71h
	mov bh,al
	
	mov ax,bx
	xor dx,dx
	mov si,offset CHAR_KB+6
	call TO_DEC
	mov dx,offset EX_MEM
	call PRINT
	
	
;List of memory control block
	mov dx,offset FOR_LMCB
	call PRINT
	mov ah,52h
	int 21h
	mov bx,es:[bx-2]
	mov es,bx
	CYCLE:
		mov ax,es
		mov di,offset LIST_MCB+4
		call WRD_TO_HEX
		mov ax,es:[01h]
		mov di,offset LIST_MCB+14
		call WRD_TO_HEX
		mov ax,es:[03h]
		mov si,offset LIST_MCB+26
		xor dx, dx
		mov bx, 10h
		mul bx
		call TO_DEC
		mov dx,offset LIST_MCB
		call PRINT
		mov cx,8
		mov bx,8
		mov ah,02h
		CYCLE2:
			mov dl,es:[bx]
			inc bx
			int 21h
		loop CYCLE2
		mov dx,offset STRENDL
		call PRINT
		mov ax,es
		inc ax
		add ax,es:[03h]
		mov bl,es:[00h]
		mov es,ax
		push bx
		mov ax,'  '
		mov bx,offset LIST_MCB
		mov [bx+19],ax
		mov [bx+21],ax
		mov [bx+23],ax
		pop bx
		cmp bl,4Dh
		je CYCLE
pop es
pop dx
pop cx
pop bx
pop ax
	ret
MAIN ENDP
TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP
BYTE_TO_HEX PROC near
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX
	pop CX
	ret
BYTE_TO_HEX ENDP
WRD_TO_HEX PROC near
	push BX
	mov BH,AH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	dec DI
	mov AL,BH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	pop BX
	ret
WRD_TO_HEX ENDP

BYTE_TO_DEC PROC near
	push CX
	push DX
	xor AH,AH
	xor DX,DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l: pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP

TO_DEC PROC near
	push CX
	push DX
	mov CX,10
loop_bd2: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd2
	cmp AL,00h
	je end_l2
	or AL,30h
	mov [SI],AL
end_l2: pop DX
	pop CX
	ret
TO_DEC ENDP

FIRST:
	
	mov sp,offset stc_p
	call MAIN
	xor al, al
	mov AH,4Ch
	int 21H
		
	dw 64 dup (?)
stc_p=$ 

TESTPC ENDS
 END START
 
