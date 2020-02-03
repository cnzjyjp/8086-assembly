.MODEL SMALL
.386

.DATA
TEN DD 10.0
TEMP DW ?
RESULT DD ?
FIRST DD ?
SECOND DD ?
SIGN DB ?   ;a是否为负数，0为正1为负
BUFFERX DD ?
BUFFERA1 DD ?
BUFFERA2 DD ?
BUFFERA3 DD ?
FPUSTATUS DW ?
ERRORMESSAGE  DB "Error: x<0!$"
CRLF  DB 0AH,0DH,"$"

.CODE
INPUT	PROC NEAR
	MOV	AH, 1
	INT	21H
      RET
INPUT	ENDP  ;读入单个字符

OUTPUT PROC NEAR
	MOV	AH, 2
	MOV	DL, AL
	INT 21H
	RET
OUTPUT ENDP ;输出AL对应的字符

.STARTUP
	FLDZ	          ;栈底为0
	CALL INPUT      ;开始读入x
	.IF AL == '-'   ;负号立即跳转
	JMP ERROR
	.ENDIF
	JMP NEXT

ERROR:
      LEA EDX,CRLF   ;换行
	MOV AH,9
	INT 21H  
	LEA EDX, ERRORMESSAGE;输出错误信息
	MOV AH, 09H
	INT 21H
	MOV AH, 4CH
	INT 21H    ;终止

NEXT:
	.REPEAT        ;整数部分，数在栈顶
	FMUL TEN       ;高位乘10
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP     ;加上低位
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'  ;0到9以外的停止读入，如果全部输完默认以回车终止便于自动分割x和a1

	CMP AL, '.'                ;检查是否是小数点
	JNE NEXTAONE	
	FLD1	                  ;小数部分，压入权重
	.WHILE 1
	FDIV TEN                ;当前权重除以10
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'  ;0到9以外的停止读入，默认以回车终止便于自动分割x和a1
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP      ;将数压入栈
	FMUL ST, ST(1) ;乘以权重
	FADD ST(2), ST ;加在整数块上
	FCOMP      ;将临时部分弹出
	.ENDW

	FCOMP      ;将权重弹出
NEXTAONE:
	FSTP  BUFFERX
LOOPA11:
	MOV SIGN,0
	FLDZ	      ;将0入栈
	CALL INPUT
	.IF AL == '-'
	MOV SIGN, 1	
	CALL INPUT
	.ENDIF

	.REPEAT
	FMUL TEN  
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP	
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'	

	CMP	AL, '.'
	JNE	LOOPA12
	FLD1
	.WHILE 1
	FDIV TEN
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP
	FMUL ST, ST(1)
	FADD ST(2), ST
	FCOMP
	.ENDW
	FCOMP

LOOPA12:
	.IF SIGN == 1
	FCHS   ;改变符号位
	.ENDIF
	FSTP  BUFFERA1

LOOPA21:
	MOV SIGN,0
	FLDZ	
	CALL INPUT
	.IF AL == '-'
	MOV SIGN, 1	
	CALL INPUT
	.ENDIF
	.REPEAT
	FMUL TEN
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP	
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'	
	CMP	AL, '.'
	JNE	LOOPA22
	FLD1
	.WHILE 1
	FDIV TEN
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP
	FMUL ST, ST(1)
	FADD ST(2), ST
	FCOMP
	.ENDW
	FCOMP
LOOPA22:
	.IF SIGN == 1
	FCHS
	.ENDIF
	FSTP  BUFFERA2
LOOPA31:
	MOV SIGN,0
	FLDZ	
	CALL INPUT
	.IF AL == '-'
	MOV SIGN, 1	
	CALL INPUT
	.ENDIF
	.REPEAT
	FMUL TEN
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP	
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'	
	CMP	AL, '.'
	JNE	LOOPA32
	FLD1
	.WHILE 1
	FDIV TEN
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP
	FMUL ST, ST(1)
	FADD ST(2), ST
	FCOMP
	.ENDW
	FCOMP
LOOPA32:
	.IF SIGN == 1
	FCHS
	.ENDIF
	FSTP  BUFFERA3
;输入完成
	FLD BUFFERX
	FSQRT
	FLD  BUFFERA1
	FMUL
	FST RESULT

	FLD BUFFERA2
	FLD BUFFERX
	FYL2X
	FADD RESULT
	FST RESULT

	FLD BUFFERX
	FSIN
	FLD BUFFERA3
	FMUL
	FADD RESULT
	FSTP RESULT
;计算完毕，结果在RESULT
	FSTCW	FPUSTATUS	
	OR	FPUSTATUS,0C00H  ;FPU控制字的RC=11,将浮点数取整时向0对齐（直接舍去小数部分）
	FLDCW	FPUSTATUS

	FLD	RESULT
	FTST
	FSTSW	AX
      AND   AX, 4500H  ;FPU状态字C0、C2、C3
	CMP	AX, 0100H  ;所以前面应该可以AND 0100H?
	JNZ	NOTMINUS
	MOV	AL, '-'   ;结果为负
	CALL	OUTPUT
	FABS ;取绝对值

NOTMINUS:
	FLD	ST
	FRNDINT
	FIST	FIRST	;保存整数部分
	FSUBR      
	FABS
	FSTP	SECOND	;保存小数部分
	MOV	EAX, FIRST
	MOV	EBX, 10
	MOV	CX, 0  ;记录整数位数
	PUSH	BX
LOOPER1:
	MOV	EDX, 0
	DIV	EBX
	ADD	DL, 30H ;取余数push
	PUSH	DX
	INC	CX     ;循环次数，Loop用
	CMP	EAX, 0
	JNZ	LOOPER1
PRINTER:
	POP	AX
	CALL	OUTPUT	;从栈顶从上往下，输出整数部分
	LOOP	PRINTER
	MOV	AL, '.'
	CALL	OUTPUT	
	MOV	EAX, SECOND      ;整数输出完成

	FSTCW	FPUSTATUS
	XOR	FPUSTATUS, 0C00H     ;RC=00，舍入到最近
	FLDCW	FPUSTATUS

	FLD	SECOND
	FXTRACT  ;把 ST(0) 内的数值改成 X*2的Y次，然后把 Y 存回 ST(0)里，再把 X 压入堆栈，所以最后 ST(0)为有效数X，ST(1) 为以 2 为底的指数Y
	FSTP	SECOND     ;X出栈
	FABS             ;指数取绝对值
	FISTP	FIRST	     ;Y出栈
	MOV	ECX, FIRST
	MOV	EAX, SECOND
	SAL	EAX, 9	;将目的操作数顺序左移9位，盖掉IEEE符号位和阶位,算数左移和逻辑左移等价
	RCR	EAX, CL     ;EAX+CF循环右移，等价于除上指数绝对值次的2，注意是循环右移以填充CF位的1，但是不确定CF到底怎么置1?
;现在得到的等价于非IEEE计数法的小数
LOOPER2:
	MUL	EBX  ;对于小数，每次乘10
	PUSH	EAX
	XCHG	EAX, EDX ;将积的高位EDX即小数点前面一位换到AL以输出
	ADD	AL, 30H
	CALL	OUTPUT
	POP	EAX        ;将小数点后的截断部分入栈继续处理
	CMP	EAX, 0     
	JNZ	LOOPER2    ;小数点后都是0，说明输出完毕
	
QUIT:
	MOV AH, 4CH
	INT 21H 
END