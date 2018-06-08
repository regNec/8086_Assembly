data SEGMENT
    ;the array of 50 integers
    ;arr DW  7, 49, 73, 58, 30, 72, 44, 78, 23, 9, 40, 65, 92, 42, 87, 3, 27, 29, 40, 12, 3, 69, 9, 57, 60, 33, 99, 78, 16, 35, 97, 26, 12, 67, 10, 33, 79, 49, 79, 21, 67, 72, 93, 36, 85, 45, 28, 91, 94, 57
    arr DW 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    ;variables in functions
    elem DW ? 
    i DW ?
    j DW ?
    low DW 0     ;start of the array
    high DW 49    ;end of the array
    keyPos DW ?
    

ENDS

stack SEGMENT
    stk DB 100 dup(0) 
    top EQU 100
ENDS

code SEGMENT
    assume CS:code, DS:data, SS:stack
start:
    MOV AX, data
    MOV DS, AX
    MOV AX, SS
    MOV SS, AX
    MOV SP, top
    
    CALL quickSort
MOV AX, 4c00h
INT 21h      

;void quick_sort(int *a, int low, int high){
;    if (low < high) {
;        int key = partition(a, low, high);
;        quick_sort(a, low, key - 1);
;        quick_sort(a, key + 1, high);
;    }
;}
quickSort PROC  
    ;if (low >= high) , end the function
    MOV AX, low
    CMP AX, high 
    JG endQuickSort 
    
    ;int key = partition(a, low, high)  
    CALL partition
    MOV keyPos, AX
    
    ;save for quick_sort(a, key + 1, high)
    PUSH high
    INC AX
    PUSH AX
    
    ;quick_sort(a, low, key - 1);
    MOV AX, keyPos
    DEC AX
    MOV high, AX
    CALL quickSort
    
    ;quick_sort(a, key + 1, high);  
    POP low
    POP high
    CALL quickSort
    
    endQuickSort:
        RET
quickSort ENDP

        
;int partition(int *a, int low, int high){
;    int elem = a[high];
;    int i = low - 1;
;    for (int j = low; j <= high; j++) {
;        if (a[j] <= elem) {
;            i++;
;            swap(a[i], a[j]);
;        }
;    }
;    return i;
;}        
partition PROC  
    ;int elem = a[high];
    MOV SI, high
    SHL SI, 1
    MOV AX, [SI] 
    MOV elem, AX
   
    ;int i = low - 1; 
    MOV AX, low
    DEC AX
    MOV i, AX
    
    ;int j = low
    MOV AX, low
    MOV j, AX
    
    MOV CX, high
    SUB CX, low
    INC CX 
    
    ifblock:
        MOV SI, j
        SHL SI, 1 
        MOV AX, [SI]
        CMP AX, elem
        JG endif
        INC i
        MOV AX, i
        
        ;swap(a[i], a[j]);
        MOV SI, i
        SHL SI, 1
        MOV BX, [SI]
        PUSH BX             ;push a[i]
        
        MOV SI,j
        SHL SI, 1
        MOV BX, [SI]
        PUSH BX             ;push a[j]
        
        MOV SI, i
        SHL SI, 1
        POP [SI]            ;pop a[i]
        
        MOV SI, j
        SHL SI, 1
        POP [SI]            ;pop a[j]
    
    endif:
        INC j
        LOOP ifblock
     RET
         
partition ENDP

END start
