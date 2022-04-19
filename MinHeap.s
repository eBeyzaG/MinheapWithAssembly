	AREA project, CODE, READONLY
	ENTRY
start
	;read write execute starts from 0x00000000 to 0x00010000
	LDR sp, =0x0000ffff ;init stack
	LDR r0, =ELEMENTS ;address of the array
	LDR r1, =0x0000f000 ;new address of the heap
	BL build
	LDR r0, [r1] ;copy the length
	BL sort
	MOV r0, #6 ;searched value
	BL find
	B programend
	
build
	PUSH {LR, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12} ;store in stack to not lose value
	;r0 contains memory address of given array
	;r1 will be the address of minheap
	;stopping variable => MAXINT
	
	;copy the array and calculate element count first
	MOV r3, #0 ;elementCount
	MOV r4, #4 ;offset for heap, starts from index 1
	MOV r5, #0 ;offset for array
copyloop
	LDR r6, [r0, r5] ;load element from array
	CMP r6, #-MAXINT
	BEQ finishcopyloop
	STR r6, [r1, r4] ;copy to heap address
	ADD r3, r3, #1
	ADD r4, r4, #4
	ADD r5, r5, #4
	B copyloop
finishcopyloop

 	STR r3, [r1] ;store the # of elements in first index
	MOV r0, r3 ;length of the array
	MOV r2, r0 ;index starting from length
buildloop ;heapify all elements
	CMP r2, #0
	BLE finishbuildloop
	BL heapify
	SUB r2, r2, #1
	B buildloop
finishbuildloop
	POP {LR, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	BX LR
	
heapify;makes the array at address r1 a heap, r0 holds the length, r2 is index
	PUSH {LR, r3, r4, r5, r6, r7, r8, r9, r10, r11}
	MOV r4, r2 ;index
	MOV r3, r0;r3 is the array length
	LDR r6, =0x80000000 ;holds the index with smallest value
	
loopstart
	CMP r4, r3 ;loop untin array length
	BGT loopfinish
	MOV r8, r4, LSL #1 ;left child index
	ADD r9, r8, #1 ; right child index
	CMP r8, r3
	BGT lcexceed ;branch if left child exceeds heap length
	LDR r10, [r1, r8, LSL #2] ;heap[leftchild]
	LDR r11, [r1, r4, LSL #2]	;heap[index]
	CMP r10, r11 
	BGE lcexceed ;branch if child is larger than parent which satisfies heap
	MOV r6, r8 ;smallest index is left child's index
	B lcifend
lcexceed
	MOV r6, r4 ;smallest index is index variable
lcifend
	CMP r9, r3
	BGT rcexceed ;branch if right child index exceeds heap length
	LDR r10, [r1, r9, LSL #2 ] ;heap[rightchild]
	LDR r11, [r1, r6, LSL #2] ;heap[smallest]
	CMP r10, r11
	BGE rcexceed ;branch if child is larger than parent
	MOV r6, r9
rcexceed
	CMP r6, r4
	BEQ ifend ;swap if not equal
	LDR r10, [r1, r6, LSL #2]
	LDR r11, [r1, r4, LSL #2]
	STR r11, [r1, r6, LSL #2]
	STR r10, [r1, r4, LSL #2]
	MOV r4, r6
	B cont
ifend
	B loopfinish
cont
	B loopstart
loopfinish
	POP {LR,r3, r4, r5, r6, r7, r8, r9, r10, r11}
	BX LR

sort 
	;this procedure sorts the array in descending order in a new address
	;r0 size of array
	;r1  address of the  first element of the heap to be sorted
	;take the first item of the heap and heapify, do this for array size
	PUSH {LR, r2, r3, r4, r5, r6, r7, r8, r9, r10}
	LDR r0, [r1]
	LDR r9, =0x0000ff10 ;sorted array address
	
	MOV r6,  r0
	MOV r2, #0 ;index
	
copysortloop
	CMP r2, r6
	BGT finishcopysortloop
	LDR r4, [r1, r2, LSL #2];r0 holds the length
	STR r4, [r9, r2, LSL #2] ;copy to heap address
	ADD r2, #1
	B copysortloop
finishcopysortloop
	
	MOV r1, r9 ;assign the new address
	MOV r10, r0 ;index
	MOV r2, #1 ;constant 1
	MOV r9, #1
sortloop
	CMP r10, #1 ;loop all elements
	BLT sortloopend
	;swap the last and first element
	LDR r7, [r1, r10, LSL #2] ;take the last element
	LDR r8, [r1, r9, LSL #2] ;
	STR r7, [r1, r9, LSL #2] ;put in the first element
	STR r8, [r1, r10, LSL #2]
	SUB r0, r0, #1;length decreases
	;call heapify r0: length r1: address
	BL heapify
	SUB r10, r10, #1
	B sortloop
sortloopend
	LDR r0, =0x0000ff10 
	POP {LR, r2, r3, r4, r5, r6, r7, r8, r9, r10}
	BX LR

find ;r0 holds the VALUE of the searched item, r1 holds address of FIRST ELEMENT, returns r0: if found: 1 not found:0, r1: adress of the found index
	PUSH {LR, r2, r3, r4, r5, r6, r7, r8, r9,r10}
	
	MOV r10, r0 ;store searched the value in r10
	MOV r9, r1; store the address
	MOV r0, r1
	LDR r1, =0x0000f000 ;address of the new array
	BL sort ;now r0 has the sorted array's address, r1 originial array's address, r10 searched value
	MOV r1, r9
	LDR r3, [r0] ;r3 holds the length of the array
	
	
	MOV r7, #1 ;low
	MOV r8, r3 ;high
	
findloop
	CMP r7,r8
	BGT notfound
	ADD r4, r7, r8
	MOV r4, r4, ASR #1;index starts from middle
	LDR r5, [r0, r4, LSL #2];read from array
	CMP r10, r5
	BLT ifsmaller
	BGT iflarger
	BEQ ifequal
ifsmaller ;if the searched value is smaller increment the starting point
	ADD r7, r4, #1
	B endifs
iflarger ;if the searched value is larger decrement the starting point
	SUB r8, r4, #1
	B endifs
ifequal ;if equal, break the loop
	MOV r0, #1 
	B findloopend
endifs
	B findloop
notfound
	MOV r0, #0
findloopend

	CMP r0, #0 ;check if the value is found, if found search for the index
	BEQ noindex
	;r3 length, r1 orig address, r10 searched
	MOV r5, #0 ;index
indexloop
	CMP r5, r3
	BGT finishindexloop
	LDR r6, [r1, r5, LSL #2]
	CMP r6, r10
	BNE notequal
	MOV r5, r5, LSL #2 ;if the searched value is found, store the found address
	ADD r1, r1, r5
notequal
	ADD r5, r5, #1
	B indexloop
finishindexloop
noindex
	POP {LR, r2, r3, r4, r5, r6, r7, r8, r9,r10}
	BX LR
programend
	CMP r0, r1 ;to prevent warning

MAXINT EQU 	0x7FFFFFFF ;maximum integer
ELEMENTS DCD 9, 19, 18,7, 12, 6, -MAXINT

	END

	

	
	
