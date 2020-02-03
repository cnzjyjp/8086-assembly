DATAS SEGMENT
    NUMBER  DW  0
    PREDECESSOR DB 0 
    EXPRESSION DW 2048 DUP(?)
    THEEND DW 0             
    RESULT  DB 5 DUP(?)      ;16λ
DATAS ENDS

STACK SEGMENT
    S DW 2048 DUP (?)
STACK  ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATAS,SS:STACK
    
START:
    MOV     AX,DATAS
    MOV     DS,AX
    MOV     AX,STACK
    MOV     SS,AX
    MOV     SP,2048

    LEA     SI, EXPRESSION
    MOV     DI,13
    MOV     [SI], DI
    ADD     SI, 2
    MOV     DI,6
    MOV     [SI],DI
    ADD     SI, 2     
    
INPUT:   
    MOV     AH, 1
    INT     21H                        
    MOV     DL, AL   

L1:    
    CMP     DL, 30H
    JB      OPERATOR                 
    SUB     DL, 30H
    MOV     DH, 0
    MOV     CX, DX
    MOV     PREDECESSOR, 1
    MOV     AX, NUMBER         
    MOV     BX, 10
    MUL     BX                   
    ADD     AX, CX                    
    MOV     NUMBER, AX         
    JMP     INPUT
    
OPERATOR:
    MOV     AL, PREDECESSOR
    CMP     AL, 0
    JE      CHECK
    MOV     AX, NUMBER
    MOV     [SI], AX
    ADD     SI, 2
    MOV     DI,1
    MOV     [SI], DI
    ADD     SI, 2
    JMP     NOTBRACKET

    
CHECK: 
    CMP     DL, '-'
    JE      INSIDE              
    CMP     DL, '+'
    JE      INSIDE             
    JMP     NOTBRACKET

INSIDE:
    MOV     BL, [SI-2]               
    CMP     BL, 4
    JE      INSERT0
    CMP     BL, 6
    JE      INSERT0
    JMP     NOTBRACKET

INSERT0:
    MOV     WORD PTR[SI], 0
    ADD     SI, 2
    MOV     WORD PTR[SI], 1
    ADD     SI, 2
NOTBRACKET:
    MOV     DH, 0
    MOV     [SI], DL
    ADD     SI, 2
    CMP     DL, '+'
    JE      ADDER
    CMP     DL, '-'
    JE      SUBER
    CMP     DL, '('
    JE      LEFT_BRACKET
    CMP     DL, ')'
    JE      RIGHT_BRACKET
    CMP     DL, 13
    JE      ENDOFEXP

ADDER:
    MOV     DL, 2
    JMP     RTN
SUBER:
    MOV     DL, 3
    JMP     RTN
LEFT_BRACKET:
    MOV     DL, 4
    JMP     RTN
RIGHT_BRACKET:
    MOV     DL, 5
    JMP     RTN
ENDOFEXP:
    MOV     DX, 6
    MOV     [SI], DX
    MOV     THEEND, SI
    JMP     FINISH_INPUT

RTN:
    MOV     [SI], DX
    ADD     SI, 2
    MOV     AX, 0
    MOV     PREDECESSOR, AL
    MOV     NUMBER, AX
    JMP     INPUT 

FINISH_INPUT:
    MOV     SI, THEEND
    PUSH    [SI-2]
    PUSH    [SI] 
    SUB     SI, 4
PUSH_LOOP:
    MOV     DX, [SI]
    CMP     DX, 6
    JE      ENDEXPRESSION
    CMP     DX, 4
    JE      INSIDEBRACKET
    PUSH    [SI-2]
    PUSH    [SI]
    SUB     SI, 4
    JMP     PUSH_LOOP

ENDEXPRESSION:
    POP     AX
    POP     DX
    POP     AX
    CMP     AX, 2
    JE      ADDCAL
    CMP     AX, 3
    JE      SUBCAL
    CMP     AX, 6
    JE      CAL_FINISH

ADDCAL:
    POP     CX
    POP     CX
    POP     CX
    ADD     DX, CX
    PUSH    DX
    MOV     DI,1
    PUSH    DI
    JMP     ENDEXPRESSION
SUBCAL:
    POP     CX
    POP     CX
    POP     CX
    SUB     DX, CX
    PUSH    DX
    MOV     DI,1
    PUSH    DI
    JMP     ENDEXPRESSION

INSIDEBRACKET:
    POP     AX
    POP     DX
    POP     AX
    CMP     AX, 2
    JE      ADD_L
    CMP     AX, 3
    JE      SUB_L
    CMP     AX, 5
    JE      RIGHT_L

ADD_L:
    POP     CX
    POP     CX
    POP     CX
    ADD     DX, CX
    PUSH    DX
    MOV     DI,1
    PUSH    DI
    JMP     INSIDEBRACKET
SUB_L:
    POP     CX
    POP     CX
    POP     CX
    SUB     DX, CX
    PUSH    DX
    MOV     DI,1
    PUSH    DI
    JMP     INSIDEBRACKET
RIGHT_L:
    POP     CX
    PUSH    DX
    MOV     DI,1
    PUSH    DI
    SUB     SI, 4
    JMP     PUSH_LOOP


CAL_FINISH:                         
    MOV     CX, DX
    LEA     SI, RESULT

PRINTSTART:
    MOV     AH, 2                       
    MOV     DL, 13
    INT     21H

    CMP     CX, 0
    JE      PRINT0

MINUS:
    CMP     CX, 0
    JS      PRINT_MINUS
L2:
    MOV     BX, 10000
    MOV     AX, CX
    MOV     DX, 0
    DIV     BX
    ADD     AL, 30H
    MOV     [SI], AL
    INC     SI
    MOV     CX, DX
    MOV     BX, 1000
    MOV     AX, CX
    MOV     DX, 0
    DIV     BX
    ADD     AL, 30H
    MOV     [SI], AL
    INC     SI
    MOV     CX, DX
    MOV     BX, 100
    MOV     AX, CX
    MOV     DX, 0
    DIV     BX
    ADD     AL, 30H
    MOV     [SI], AL
    INC     SI
    MOV     CX, DX
    MOV     BX, 10
    MOV     AX, CX
    MOV     DX, 0
    DIV     BX
    ADD     AL, 30H
    MOV     [SI], AL
    INC     SI
    ADD     DL, 30H
    MOV     [SI], DL

PRINT:
    MOV     CL, 0
    LEA     SI, RESULT
    MOV     AH, 2
SKIP:
    CMP     CL, 5
    JE      QUIT
    MOV     DL, [SI]
    CMP     DL, '0'
    JNE     LOOPER 
    INC     SI
    INC     CL
    JMP     SKIP
LOOPER:
    CMP     CL, 5
    JE      QUIT
    MOV     DL, [SI]
    INT     21H
    INC     SI
    INC     CL
    JMP     LOOPER

PRINT_MINUS:
    MOV     AH, 2
    MOV     DL, '-'
    INT     21H
    NOT     CX
    INC     CX
    JMP     L2

PRINT0:
    MOV     AH, 2
    MOV     DL, 30H
    INT     21H
    
QUIT:
    MOV     AX,4C00H
    INT     21H
CODE ENDS
END START