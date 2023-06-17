;------------------------------------------------------------------------
;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2022/2023
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'

		ExeName			db		'Ultimate Tic Tac Toe$'

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo1.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db		32	; Guarda um caracter do Ecran 
		Cor				db		7	; Guarda os atributos de cor do caracter
		POSy			db		8	; a linha pode ir de [1 .. 25]
		POSx			db		17	; POSx pode ir [1..80]	
		
		;#################	
		POSya			db		8	; POSy anterior
		POSxa			db		17	; POSx  anterior
		
		XPosCorners		BYTE	3, 13, 23
		YPosCorners		BYTE	2,  7, 12

		LargeBoard		db  	9	 dup( 9 dup(0) )
		FinalBoard		db  	9	 dup(0) 
		
		currentplayer 	db		2
		PlayerX			db 		'X'
		PlayerO			db 		'O'
		strPlayer	 	db 		'jogador $',0		

		Nome_Ms			db		'Introduza o nome (12 chars): $',0	; Para pedir o nome do jogador
		Turno_MSG		db 		'É Turno de :$',0			; Para indicar de quem é a vez
		StrPlayer1	 	DB 		"            $",0	;  12 digitos + $
		StrPlayer2	 	DB 		"            $",0			
		strLength		db		12
	
		MsgPlayerY 		db 		15
		MsgPlayerX 		db		3	

		;offset to game  in the corner
		boardOffsetX	db		1
		boardoffsetY	db		1
		;offset to in board corner
		moveOffsetX	db		1
		moveoffsetY	db		1
		indexInFullboard db		0

dseg	ends

cseg	segment para public 'code'
assume	cs:cseg, ds:dseg



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
		
apaga:		mov		byte ptr es:[bx], ' '
			mov		byte ptr es:[bx+1], 7
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


;LE_STRING 	proc
    ;mov ah, 0Ah
    ;mov dx, offset BufferEntrada
    ;int 21h
    ;mov si, offset BufferEntrada + 2 ; A string começa no terceiro byte do buffer
    ;mov di, offset StrInput
    ;mov cl, byte ptr [BufferEntrada + 1] ; Comprimento da string
    ;mov ch, 0 ; Zerar o contador
    ;rep movsb ; Mover a string do buffer de entrada para StrInput
    ;ret
;LE_STRING 	endp

; ; ;########################################################################
; ; ; SET_PLAYERS
; ; SET_PLAYERS proc

; ; 		goto_xy 10, 10
; ; 		lea     dx,ExeName
; ; 		mov     ah,09h
; ; 		int     21h; AH already set to 09h

; ; 		;escreve mensagem
; ; 		goto_xy	MsgPlayerX, MsgPlayerY
; ; 		mov     ah,09h
; ;         lea     dx,Nome_Msg
; ;         int     21h; AH already set to 09h
		
; ; 		inc MsgPlayerY
; ; 		goto_xy	MsgPlayerX, 17
; ; 		mov     ah,09h
; ; 		lea		dx,strPlayer
; ; 		int     21h
		
; ; 		Mov cx, 12 	
		
; ; 		MOV bx, 0
		
		
; ; 		;cmp 
		

; ; LER_NOME:	;leitura input nome
; ; 		mov ah,07h
; ; 		int  21h
		
; ; 		cmp al,13;is an \r\n
; ; 		je Nome_lido;exit on enter
		
; ; 		; verifica se é uma letra
; ; 		cmp al,'A'
; ; 		jb LER_NOME

; ; 		cmp al,'z'
; ; 		ja LER_NOME
		
		
; ; 		INC dl
		
; ; 		loop LER_NOME
		
; ; Nome_lido:		

; ; 	goto_xy	MsgPlayerX, MsgPlayerY
; ; 	lea     dx, Nome_Msg
; ; 	int     21h; AH already set to 09h
; ; 	ret	
		

; ; SET_PLAYERS endp

; ; Nome_Leitura proc;leitura input nome

; ; ler_Chan_nome:
; ; 		mov ah,07h
; ; 		int  21h
		
; ; 		cmp al,13;is an \r\n
; ; 		je fim_nome
		
; ; 		mov		ah, 02h		; coloca o caracter lido no ecra
; ; 		mov		dl, al
; ; 		int		21H	
		
; ; 		loop ler_Chan_nome
		
		
		
; ; fim_nome:
; ; 	ret
		
; ; Nome_Leitura endp
		
		
;########################################################################
; Player switch
SwapPlayer macro
		Mov al, currentplayer
		Mov ah, dl
		xor dx, dx
		mov bx, 2
		div bx
		inc dl
		mov currentplayer, dl	
endm

;########################################################################
; Calculate offset to left-up-most board
;		0 for aligned, 1 for middle, 2 for oposite
;		for both x (left) and y (up)

CalcBoardOffset PROC
		Mov bl, byte ptr [XPosCorners + 2]
		mov al, POSx;fica com o valor durante toda a proc

	LastColumn:
		cmp al, bl
		jb MiddleColumn;se for menos, não está na coluna da direita
		mov boardOffsetX, 2
		jmp YOffset

	MiddleColumn:
		Mov bl, byte ptr [XPosCorners + 1]
		cmp al, bl
		jb FirstCol;se for menos, não está na coluna do meio
		mov boardOffsetX, 1
		jmp YOffset
		
	FirstCol:;Se chega aqui, só pode estar nesta
		mov boardOffsetX, 0

	YOffset:
		Mov bl, byte ptr [XPosCorners + 2]
	LastRow:
		cmp al, bl
		jb MiddleRow;se for menos, não está na linha do fundo
		mov boardOffsetY, 2
		jmp EndCalc

	MiddleRow:
		Mov bl, byte ptr [YPosCorners + 1]
		cmp al, bl
		jb FirstRow;se for menos, não está na linha do meio
		mov boardOffsetY, 1
		jmp EndCalc

	FirstRow:;Se chega aqui, só pode estar nesta
		mov boardOffsetY, 0

EndCalc:
	ret
CalcBoardOffset endp


; Calculate offset inside board
; 		0 for aligned, 1 for middle, 2 for oposite
; 		for both x (left) and y (up)

CalcMoveOffset PROC
		xor ax, ax
		xor bx, bx
		mov bl, byte ptr [XPosCorners]
		mov al, boardOffsetX
		mov ah, 10
		mul ah; diferença entre mesmas posições de tabuleiros ajacentes de cada linha 
		add bl, al
		xor ax, ax
		mov al, POSx
		inc bl

	IsMiddleColumn:
		cmp al, bl
		jb IsFirstColumn
		ja IsLastColumn
		mov boardOffsetX, 1
		jmp YMove

	IsLastColumn:
		mov boardOffsetX, 2
		jmp YMove
		
	IsFirstColumn:
		mov boardOffsetX, 0

YMove:
		xor ax, ax
		xor bx, bx
		mov bl, byte ptr [YPosCorners]
		mov al, boardOffsetY
		mov ah, 10
		mul ah; diferença entre mesmas posições de tabuleiros ajacentes de cada coluna
		add bl, al
		xor ax, ax
		mov al, POSx
		inc bl

	IsMiddleRow:
		cmp al, bl
		jb IsFirstRow
		ja IsLastRow
		mov boardOffsetX, 1
		jmp EndCalcMove

	IsLastRow:
		mov boardOffsetX, 2
		jmp EndCalcMove
		
	IsFirstRow:
		mov boardOffsetX, 0


EndCalcMove:
	ret

CalcMoveOffset endp


UpdataBoardWithMove proc

		; Mov bx, offset XPosCorners
		; Xor ax, ax;reset AX
		; mov al, boardOffsetX; poe desloc em ax (al para NÃO ir buscar mais bytes) 
		; mov si, ax; move para SI com tamnaho certo
		; add bx, si; soma o valor em si  
		; inc bl
		; mov al, POSx

	;;;Mov [LargeBoard + ?] , currentplayer

		XOR ax, ax
		mov al, boardOffsetX
		mov bl, moveOffsetX

		


		Mov indexInFullboard, al

		Mov bx, offset LargeBoard
		Xor ax, ax;reset AX
		mov al, boardOffsetX; poe desloc em ax (al para NÃO ir buscar mais bytes) 
		mov si, ax; move para SI com tamnaho certo
		add bx, si; soma o valor em si  
		inc bl
		mov al, POSx


UpdataBoardWithMove endp


SetBxToCorner macro LargeBoard, boardOffsetX, boardOffsetY
	xor ax, ax
	xor bx, bx
	lea si, LargeBoard
	mov bx, si
	mov al, boardOffsetY
	mov ah, 27; diferença entre localização no arrya de tabuleiros em coluna 
	mul ah
	xor ah, ah
	add bx, ax

    mov al, boardOffsetX
	mov ah, 9; diferença entre localização no arrya de tabuleiros em linha
	mul ah
	xor ah, ah
	add bx, ax
	; Bl aponta para posição de canto do tabuleiro
endm

;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:
		;Pedir input ao jogador
			xor bx, bx
			mov		bl, POSx
			mov		POSxa, bl
			mov		bh, POSy
			mov		POSya, bh
		
			goto_xy	POSx,POSy		; Vai para nova possi��o
			
			;cmp  Car, 4fh		
			;jne IMPRIME
			
			;goto_xy	POSxa,POSya	
		
			
IMPRIME:
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
		
			;mov		ah, 02h		; coloca o caracter lido no ecra
			;mov		dl, al
			;int		21H	
			goto_xy	POSx,POSy
	
			;Is enter
			cmp		al, 0dh
			je		Place_Mark 

			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima

			cmp		POSy, 1;Limite superior de tabuleiro
			ja		CICLO
			inc		POSy

			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo			
			cmp		POSy, 15 ;Limite inferiror de tabuleiro
			jb		CICLO
			dec		POSy

			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			Sub		POSx, 2		;Esquerda
					
			cmp		POSx, 3;Limite esquerdo de tabuleiro
			ja		CICLO
			Add 	POSx, 2

			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			Add		POSx, 2		;Direita
			
			cmp		POSx, 31	;Limite direito de tabuleiro
			jb		CICLO
			Sub 	POSx, 2

			jmp		CICLO


Place_Mark:	;Atualizar tabuleiro com o novo simbolo
			mov bl, currentplayer
			cmp bl, 2
			jb	PlayO

PlayX:
		mov		ah, 02h		; coloca o caracter X
		mov		dl, 'X'
		mov		dh, Car
		int		21H	
		jmp PostTurn

PlayO:
		mov		ah, 02h		; coloca o caracter O
		mov		dl, 'O'
		mov		dh, Car
		int		21H	
		jmp PostTurn
			
PostTurn:
			call CalcBoardOffset
			; call CalcMoveOffset

			;logica de encontrar vencedor


			;set up next turn
			SwapPlayer
			jmp		CICLO

fim:
			RET
AVATAR		endp


;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov	ah,00h
		int	1ah
		
		;Random Starting players
		Mov al, dh
		Mov ah, dl
		xor dx, dx
		mov bx, 2
		div bx
		inc dl
		mov currentplayer, dl		
		mov			ax,0B800h
		mov			es,ax
		
		call		apaga_ecran	

		mov boardOffsetX, 1
		mov boardOffsetY, 2
		SetBxToCorner LargeBoard, boardOffsetX, boardOffsetY


		;call 		SET_PLAYERS		
		;call		apaga_ecran			
		
		
		goto_xy		0,0
		call		IMP_FICH
		
		goto_xy		POSx, POSy
		call 		AVATAR
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main
