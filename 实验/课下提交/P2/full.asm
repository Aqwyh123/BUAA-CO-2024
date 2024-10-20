.macro push(%reg)
	addi $sp, $sp, -4
	sw %reg, 0($sp)
.end_macro 
.macro pop(%reg)
	lw %reg, 0($sp)
	addi $sp, $sp, 4
.end_macro 

.eqv n $s7
.eqv index $t9
.eqv i $t8
.eqv p $t7
.eqv offset $t6
.eqv temp $t5

.data
	symbol: .word 0: 8
	array: .word 0: 8
	space: .asciiz " "
	enter: .asciiz "\n"
.text 
main:
	li $v0, 5
	syscall
	move n, $v0
	
	li $a0, 0
	jal full
	
	li $v0, 10
	syscall

full:
	push($ra)
	
	move index, $a0
	
if_begin_1:
	blt index, n, end_if_1
	
	li i, 0
for_begin_1:
	beq i, n, end_for_1
	
	la p, array
	sll offset, i, 2
	add p, p, offset
	
	lw $a0, 0(p)
	li $v0, 1
	syscall
	
	la $a0, space
	li $v0, 4
	syscall
	
	add i, i, 1
	j for_begin_1
end_for_1:
	la $a0, enter
	li $v0, 4
	syscall
	
	pop($ra)
	jr $ra
end_if_1:
	li i, 0
for_begin_2:
	beq i, n, end_for_2
if_begin_2:
	la p, symbol
	sll offset, i, 2
	add p, p, offset
	lw temp, 0(p)
	bnez temp, end_if_2
	
	la p, array
	sll offset, index, 2
	add p, p, offset
	add temp, i, 1
	sw temp, 0(p)
	
	la p, symbol
	sll offset, i, 2
	add p, p, offset
	li temp, 1
	sw temp, 0(p)
	
	add $a0, index, 1
	push(index)
	push(i)
	push(p)
	jal full
	pop(p)
	pop(i)
	pop(index)
	li temp, 0
	sw temp, 0(p)
end_if_2:
	add i, i, 1
	j for_begin_2
end_for_2:
	pop($ra)
	jr $ra

	
	
	
	
	
	
	
	
	
	
	
	
	
	
