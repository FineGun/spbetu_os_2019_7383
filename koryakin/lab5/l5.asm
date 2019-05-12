ASTACK SEGMENT STACK
	dw 100h dup (?)
ASTACK ENDS

CODE SEGMENT
 ASSUME CS:CODE, DS:DATA, ES:DATA, SS:ASTACK

ROUT PROC FAR
	
	jmp go_
	SIGNATURA dw 0ABCDh
	KEEP_PSP dw 0 
	KEEP_IP dw 0 
	KEEP_CS dw 0 
	INT_STACK DW 	100 dup (?)
	KEEP_SS DW 0
	KEEP_AX	DW ?
        KEEP_SP DW 0

go_:
	mov KEEP_SS, SS 
	mov KEEP_SP, SP 
	mov KEEP_AX, AX 
	mov AX,seg INT_STACK 
	mov SS,AX 
	mov SP,0 
	mov AX,KEEP_AX
	
	
	push ax
	push es
	push ds
	push dx
	push di
	push cx
	mov al,0
	in al,60h
	cmp al,11h 
	je do_req
	
	pushf
	call dword ptr cs:KEEP_IP 
	jmp skip 
	
do_req:
	in al, 61h   
	mov ah, al     
	or al, 80h    
	out 61h, al    
	xchg ah, al    
	out 61h, al   
	mov al, 20h     
	out 20h, al     
	
buf_push:
	mov al,0
	mov ah,05h 
	mov cl,'9' ;inst symbol  
	mov ch,00h
	int 16h
	or al,al
	jz skip
	mov ax,0040h
	mov es,ax
	mov ax,es:[1Ah]
	mov es:[09h],ax
	jmp buf_push

skip:
	pop cx
	pop di
	pop dx
	pop ds
	pop es
	mov al,20h
	out 20h,al
	pop ax
	
	mov 	AX,KEEP_SS
 	mov 	SS,AX
 	mov 	AX,KEEP_AX
 	mov 	SP,KEEP_SP
	
	iret
ROUT ENDP 
LAST_BYTE:
;---------------------------------------
PRINT PROC
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
PRINT ENDP
;---------------------------------------
PROV_ROUT PROC
	mov ah,35h
	mov al,09h
	int 21h 
	mov si,offset SIGNATURA
	sub si,offset ROUT 
	mov ax,0ABCDh
	cmp ax,ES:[BX+SI] 
	je ROUT_EST
		call SET_ROUT
		jmp PROV_KONEC
	ROUT_EST:
		call DEL_ROUT
	PROV_KONEC:
	ret
PROV_ROUT ENDP
;---------------------------------------

SET_ROUT PROC
	mov ax,KEEP_PSP 
	mov es,ax 
	cmp byte ptr es:[80h],0
		je UST
	cmp byte ptr es:[82h],'/'
		jne UST
	cmp byte ptr es:[83h],'u'
		jne UST
	cmp byte ptr es:[84h],'n'
		jne UST
	
	mov dx,offset PRER_NE_SET_VIVOD
	call PRINT
	ret
	
UST:
	call SAVE_STAND
	
	mov dx,offset PRER_SET_VIVOD
	call PRINT
	
	push ds
	mov dx,offset ROUT
	mov ax,seg ROUT
	mov ds,ax
	
	mov ah,25h
	mov al,09h
	int 21h
	pop ds
	
	mov dx,offset LAST_BYTE
	mov cl,4
	shr dx,cl 
	add dx,1
	add dx,40h
	
	mov al,0
	mov ah,31h
	int 21h 
	
	ret
SET_ROUT ENDP
;---------------------------------------
DEL_ROUT PROC
	push dx
	push ax
	push ds
	push es
	
	
	mov ax,KEEP_PSP 
	mov es,ax 
	cmp byte ptr es:[82h],'/'
		jne UDAL_KONEC
	cmp byte ptr es:[83h],'u'
		jne UDAL_KONEC
	cmp byte ptr es:[84h],'n'
		jne UDAL_KONEC
	
	mov dx,offset PRER_DEL_VIVOD
	call PRINT
	
	CLI
	
	mov ah,35h
	mov al,09h
	int 21h 
	mov si,offset KEEP_IP
	sub si,offset ROUT
	
	mov dx,es:[bx+si]
	mov ax,es:[bx+si+2]
	mov ds,ax
	mov ah,25h
	mov al,09h
	int 21h
	
	mov ax,es:[bx+si-2] 
	mov es,ax
	mov ax,es:[2ch] 
	push es
	mov es,ax
	mov ah,49h
	int 21h
	pop es
	mov ah,49h
	int 21h
	
	STI
	jmp UDAL_KONEC2
	
	UDAL_KONEC:
	mov dx,offset PRER_UZHE_SET_VIVOD
	call PRINT
	UDAL_KONEC2:
	
	pop es
	pop ds
	pop ax
	pop dx
	ret
DEL_ROUT ENDP
;---------------------------------------
SAVE_STAND PROC
	push ax
	push bx
	push es
	mov ah,35h
	mov al,09h
	int 21h 
	mov KEEP_CS, ES
	mov KEEP_IP, BX
	pop es
	pop bx
	pop ax
	ret
SAVE_STAND ENDP
;---------------------------------------
BEGIN:
	mov ax,DATA
	mov ds,ax
	mov KEEP_PSP, es
	call PROV_ROUT
	xor AL,AL
	mov AH,4Ch
	int 21H
CODE ENDS

DATA SEGMENT
	PRER_SET_VIVOD db 'Res is load',0DH,0AH,'$'
	PRER_DEL_VIVOD db 'Res unload',0DH,0AH,'$'
	PRER_UZHE_SET_VIVOD db 'Res already load',0DH,0AH,'$'
	PRER_NE_SET_VIVOD db 'Res still unload',0DH,0AH,'$'
	STRENDL db 0DH,0AH,'$'
DATA ENDS
 END BEGIN