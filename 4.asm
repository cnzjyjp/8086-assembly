DATAS SEGMENT
    BUFFER DB 3,3, 3 DUP(?)
    FACTOR DB 64 DUP(?)      
    N  DB  ?               
DATAS ENDS

STACK SEGMENT
    S DW 30 DUP (?)
STACK  ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATAS,SS:STACK

FACT PROC NEAR
    AND CL,CL
    JZ FACT1
    PUSH CX
    DEC CL
    CALL FACT
    POP CX
    CALL MULTI
    RET
FACT1:
    MOV FACTOR,1
    RET
FACT ENDP

MULTI PROC NEAR     
    MOV     BX,0    ;偏移量 
MULTI1:             ;将乘数乘到答案的各个位上
    CMP     BX,14H             
    JE      FINISHMULTI     ;乘完准备进位
    MOV     AL,CL              
    MUL     BYTE PTR FACTOR[BX]     
    MOV     FACTOR[BX], AL         
    INC     BX                  
    JMP     MULTI1           
FINISHMULTI:
    MOV     BX,0               
UP:           ;进位
    CMP     BX,14H
    JE      RETURNM        ;进位完成
    MOV     AX,0
    MOV     AL,FACTOR[BX]
    MOV     DH,0AH
    DIV     DH               
    MOV     DH,0
    MOV     FACTOR[BX],AH       ;余数重新放进该位
    ADD     FACTOR[BX+1],AL     ;商作为进位累加到下一位
    INC     BX                 
    JMP     UP            
RETURNM:
    RET
MULTI ENDP

START:
    MOV     AX,DATAS
    MOV     DS,AX
    MOV     AX,STACK
    MOV     SS,AX
    MOV     SP,28H

    MOV     AH,0AH
    LEA     DX,BUFFER
    INT     21H
  
    MOV     CL,BUFFER+1
    MOV     AX,0
    CMP     CL,01H
    JE      L1
    MOV     AL,BUFFER+2
    SUB     AL,'0'
    MOV     BL,0AH
    MUL     BL
    MOV     DL,BUFFER+3
    SUB     DL,'0'
    ADD     AL,DL
    MOV     BX,AX
    JMP     CALLSTART
  
L1:
    MOV     AL,BUFFER+2
    SUB     AL,'0'
    MOV     BX,AX 
     
CALLSTART:
    MOV     DX,BX
    MOV     N,DL
    MOV     DL,0AH
    MOV     AH,02H
    INT     21H
    MOV     CL,N
    CALL FACT


    MOV     BX,14H             
    MOV     CL,0               ; CL为1时0需要输出
PRINT:                          ;打印一位
    MOV     DL,FACTOR[BX]         
    CMP     DL,0
    JE      CHECK               
    MOV     CL,1               ;之后的0需要输出
CHECK:
    CMP     CL,0               
    JE      SKIP               
    ADD     DL,48
    MOV     AH,2
    INT     21H                
SKIP:
    CMP     BX, 0               
    JE      FINISH             
    DEC     BX                  
    JMP     PRINT             

FINISH:
    MOV     AX,4C00H
    INT     21H
CODE ENDS
END START
