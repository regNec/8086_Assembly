data SEGMENT
     ;origKeySeg DW 0
     ;origKeyOffset DW 0
     flag DW 0;0 for ignore
     exitFlag DW 1;0 for terminate
     ctr DW 0
     ;scan code z  , a  , b  ,......., y
     key DB 2ch, 1eh, 30h, 2eh, 20h, 12h, 21h, 22h, 23h, 17h, 24h, 25h, 26h, 32h, 31h, 18h, 19h, 10h, 13h, 1fh, 14h, 16h, 2fh, 11h, 2dh, 15h
data ENDS

stack SEGMENT
    DW   128  dup(0)
    top EQU 128
stack ENDS

code SEGMENT
    assume CS:code, DS:data, SS:stack
start:
      MOV AX, data
      MOV DS, AX
      MOV AX, stack
      MOV SS, AX
      MOV SP, top

      ;MOV AX, 0
      ;MOV ES, AX
      ;MOV BX, 4*9
      ;MOV AX, ES:[BX + 2]
      ;MOV origKeySeg, AX
      ;MOV AX, ES:[BX]
      ;MOV origKeyOffset, AX

      CALL far ptr intctrl
      CALL far ptr initcounter
      CALL far ptr keyboard

      ignore:
        MOV AX, exitFlag
        CMP AX, 0
        JE exit

        MOV AX, 0
        MOV flag, AX
        JMP ignoreKeyIntLoop

      react:
        MOV AX, exitFlag
        CMP AX, 0
        JE exit

        MOV AX, 1
        MOV flag, AX
        JMP openKeyIntLoop

      ignoreKeyIntLoop:
        MOV AX, exitFlag
        CMP AX, 0
        JE exit

        MOV AX, 600      ;8253a input at a clock rate of 1.19MHz
        MOV BX, ctr
        CMP BX, AX
        JA react
        JMP ignoreKeyIntLoop

      openKeyIntLoop:
        MOV AX, exitFlag
        CMP AX, 0
        JE exit

        MOV AX, 600 * 2
        MOV BX, ctr
        CMP BX, AX
        JA reset
        JMP openKeyIntLoop

      reset:
        MOV AX, 0
        MOV ctr, AX
        JMP ignore

      exit:
        ;MOV AX, 0
        ;MOV ES, AX
        ;MOV BX, 4*9
        ;MOV AX, origKeyOffset
        ;MOV ES:[BX], AX
        ;MOV AX, origKeySeg
        ;MOV ES:[BX + 2], AX

        MOV DX, OFFSET terminate
        INC DX

        terminate:INT 27h

      intctrl PROC far

        PUSH AX
        MOV  AL, 13h
        OUT  20h, AL
        MOV  AL, 08h
        OUT  21h, AL
        MOV  AL, 09h
        OUT  21h, AL
        POP  AX
        RET

      intctrl ENDP

      initcounter PROC far
        PUSH AX
        PUSH BX
        PUSH ES

        MOV AL, 36h
        OUT 43h, AL
        MOV AL, 20h
        OUT 40h, AL
        MOV AL, 4eh
        OUT 40h, AL   ;4e20h = 20000

        CLI
        MOV AX, 0
        MOV ES, AX
        MOV AX, OFFSET timeint
        MOV BX, 4*8
        MOV ES:[BX], AX
        MOV AX, seg timeint
        MOV ES:[BX + 2], AX
        STI

        POP ES
        POP BX
        POP AX
        RET
      initcounter ENDP

      keyboard PROC far

        PUSH AX
        PUSH BX
        PUSH ES

        CLI
        MOV AX, 0
        MOV ES, AX
        MOV BX, 4*9
        MOV DX, ES:[BX]
        MOV AX, OFFSET keyint
        MOV ES:[BX], AX
        MOV AX, seg keyint
        MOV ES:[BX+2], AX
        STI

        POP ES
        POP BX
        POP AX
        RET

        keyboard ENDP

      timeint:
        STI
        PUSH AX
        MOV AX, ctr
        INC AX
        MOV ctr, AX
        CLI

        MOV AL, 20h
        OUT 20h, AL

        POP AX
        IRET

      keyint:
        PUSH AX
        PUSH BX
        ;PUSH DS
        STI

        IN   AL, 60h
        PUSH AX
        IN   AL, 61h
        MOV  AH, AL
        OR   AL, 80h
        OUT  61h, AL
        XCHG AH, AL
        OUT  61h, AL
        POP  AX

        MOV BX, flag
        CMP BX, 0
        JE exit_keyInt

        CMP AL, 01h
        JE exit_p

        MOV SI, OFFSET key
        MOV BX, 0
      checkKey:
        CMP AL, [SI + BX]
        JE display
        INC BL
        CMP BL, 26
        JE exit_keyInt
        JMP checkKey


      display:
        MOV AH,2
        MOV DL, 'a'
        ADD DL, BL
        INT 21h

      exit_keyInt:
        CLI
        MOV  AL, 20h
        OUT  20h, AL

        POP  BX
        POP  AX
        IRET

      exit_p:
        MOV AX, 0
        MOV exitFlag, AX
        JMP exit_keyInt

code ENDS

END start
