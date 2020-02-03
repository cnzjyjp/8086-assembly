DATAS SEGMENT
  FILENAME1 DB 'Input1.txt$'
  HANDLE1 DW ?
  FILENAME2 DB 'Output1.txt$'
  HANDLE2 DW ?
  BUFFER DB 20,20,20 DUP(?)
DATAS ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATAS

START:
  MOV AX,DATAS
  MOV DS,AX

  MOV CX,0
  LEA DX,FILENAME1
  MOV AH,3CH
  INT 21H      ;生成Input1.txt

  MOV HANDLE1,AX;保存Input句柄
  
  MOV AH,0AH
  LEA DX,BUFFER
  INT 21H     ;读取输入到BUFFER
  
  MOV BX,HANDLE1
  MOV CH,0
  MOV CL,BUFFER+1
  LEA DX,BUFFER+2
  MOV AH,40H
  INT 21H     ;将BUFFER写入Input1.txt

  MOV CX,0
  LEA DX,FILENAME2
  MOV AH,3CH
  INT 21H     ;生成Output1.txt

  MOV HANDLE2,AX ;保存Output句柄

  LEA DX,BUFFER
  MOV BX,HANDLE1
  MOV AH,3FH
  MOV CH,0
  MOV CL,BUFFER+1
  INT 21H     ;将Input1.txt内容写入buffer

  LEA SI,BUFFER+2
  MOV CH,0
  MOV CL,BUFFER+1
  NEXT1:
  MOV DL,[SI]
  CMP DL,'a'  ;<a
  JB NEXT2
  CMP DL,'z'  ;>z
  JA NEXT2
  SUB DL,20H  ;小写转大写
  NEXT2:
  MOV AH,02H
  INT 21H
  MOV BX,02H
  MOV AH,0
  MOV AL,BUFFER+1
  ADD BX,AX
  SUB BX,CX
  MOV BUFFER[BX],DL  ;修改BUFFER
  INC SI
  DEC CX
  JNE NEXT1

  MOV BX,HANDLE2
  MOV CH,0
  MOV CL,BUFFER+1
  LEA DX,BUFFER+2
  MOV AH,40H
  INT 21H   ;将修改过的BUFFER写入Output1.txt

  MOV BX,HANDLE1
  MOV AH,3EH
  INT 21H   ;关闭Input1

  MOV BX,HANDLE2
  MOV AH,3EH
  INT 21H   ;关闭Output1

  MOV  AX,4C00H
  INT  21H
CODE ENDS
END START