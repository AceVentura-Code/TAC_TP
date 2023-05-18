;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2022/2023
;--------------------------------------------------------------
; Demostração da navegação do cursor do Ecran 
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'



        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	6	; POSx pode ir [1..80]	
		
		
		;#################
		Nome_Msg		db		'Introduza o seu nome$'	; Para pedir o nome do jogador
		Turno_MSG		db 		'Turno de $'			; Para indicar de quem é a vez
		POSya			db	3	; POSy anterior
		POSxa			db	6	; POSx  anterior
		PlayerX			db 	'X'
		PlayerO			db 	'O'
		
		board			 db  9	 dup( 	9 	dup(0) )	

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0			; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm


;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:
		;Pedir input ao jogador
			goto_xy	POSx,POSy		; Vai para nova possição
			mov 	ah, 08h
			mov		bh,0			; numero da página
			int		10h		
			mov		Car, al			; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah			; Guarda a cor que está na posição do Cursor
		
			goto_xy	78,0			; Mostra o caractr que estava na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car	
			int		21H			
	
			goto_xy	POSx,POSy	; Vai para posição do cursor
		
LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27		; ESCAPE
			JE		FIM
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
			cmp		CL, 32		; Só escreve se for espaço em branco
			JNE 	LER_SETA
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, al
			int		21H	
			goto_xy	POSx,POSy
			
			
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			;dec		POSx		;Esquerda
			Sub		POSx, 2		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		Place_Mark 
			;inc		POSx		;Direita
			Add		POSx, 2		;Direita
			jmp		CICLO
			
Place_Mark:	
			cmp		al, 0D
			jne		LER_SETA 
			
			;Atualizar jogo com o novo simbolo
			
			
			;logica de encontrar vencedor


			jmp		CICLO
			

fim:				
			RET
AVATAR		endp


;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		
		call		apaga_ecran
		
		goto_xy		0,0
		call		IMP_FICH
		call 		AVATAR
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main


		
