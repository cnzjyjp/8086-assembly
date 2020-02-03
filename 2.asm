DATAS SEGMENT
   COUNT DB ?
   BLS DB ?
   CHS DB ?
   CLS DB ?
   ARRAY DB 120 DUP(?)
DATAS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
     
START:
    MOV  AX,DATAS
    MOV  DS,AX

    MOV AX,00H
    INT 16H
    SUB AL,30H
    MOV COUNT,AL  ;读入N

    MOV DX,0
    MOV AH,0
    MOV AL,COUNT
    MUL AL
    LEA SI,ARRAY
FILL: 
    ADD DL,01H
    MOV [SI],DL
    INC SI
    DEC AL
    JNE FILL      ;填充二维数组,计数从N平方到1

    MOV DX,0
    MOV CH,0    ;当前行已输出数个数
    MOV CL,01H  ;当前行应当输出数个数
    MOV BH,0
    MOV BL,COUNT ;剩余行数
    LEA SI,ARRAY
PRINT:
    MOV DX,SI
    LEA AX,ARRAY
    SUB DX,AX
    CMP DX,08H   ;如果是0到9的个位数则直接转ASCII码输出
    JA  TRANS    ;否则进一步处理
    MOV DL,[SI]
    ADD DL,30H
    MOV AH,02H
    INT 21H     
    MOV DL,20H
    MOV AH,02H
    INT 21H     ;空格
L1:   
    INC SI
    INC CH
    CMP CH,CL
    JNE PRINT
    MOV AL,COUNT
    MUL CL
    MOV AH,0
    LEA SI,ARRAY
    ADD SI,AX 
    MOV CH,0
    ADD CL,01H
    MOV DL,0AH   ;\n
    MOV AH,02H
    INT 21H
    DEC BL
    JNE PRINT
    JMP STOP

TRANS:
    MOV BLS,BL
    MOV CHS,CH
    MOV CLS,CL    ;保护现场
    MOV AL,[SI]
    MOV AH,0
    MOV BL,0AH
    DIV BL
    MOV CX,AX
    MOV DL,CL     ;十位（商）
    ADD DL,30H
    MOV AH,02H
    INT 21H
    MOV DL,CH     ;个位（余数）
    ADD DL,30H
    MOV AH,02H
    INT 21H
    MOV DL,20H    ;空格
    MOV AH,02H
    INT 21H
    MOV BL,BLS
    MOV CH,CHS
    MOV CL,CLS
    JMP L1
    
STOP:
    MOV  AX,4C00H
    INT  21H
CODES ENDS
END START