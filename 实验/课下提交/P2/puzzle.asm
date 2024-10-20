.eqv n $s7
.eqv m $s6
.eqv start_i $t9
.eqv start_j $t8
.eqv end_i $s5
.eqv end_j $s4
.eqv i $t7
.eqv k $t6
.eqv p $t5
.eqv offset $t4
.eqv temp $t3
.eqv cond $t2
.eqv result $t1

.macro push(%reg)
	addi $sp, $sp, -4
	sw %reg, 0($sp)
.end_macro
.macro pop(%reg)
	lw %reg, 0($sp)
	addi $sp, $sp, 4
.end_macro

.data
	matrix: .word 0: 64
.text
main:
	li $v0, 5
	syscall
	move n, $v0
	li $v0, 5
	syscall
	move m, $v0
	
	li i, 0
for_1_begin:
	beq i, n, for_1_end
	
	li k, 0
for_2_begin:
	beq k, m, for_2_end
	
	la p, matrix
	sll offset, i, 3
	add offset, offset, k
	sll offset, offset, 2
	add p, p, offset
	li $v0, 5
	syscall
	sw $v0, 0(p)
	
	add k, k, 1
	j for_2_begin
for_2_end:

	add i, i, 1
	j for_1_begin
for_1_end:
	
	li $v0, 5
	syscall
	move start_i, $v0
	li $v0, 5
	syscall
	move start_j, $v0
	li $v0, 5
	syscall
	move end_i, $v0
	li $v0, 5
	syscall
	move end_j, $v0
	add start_i, start_i, -1
	add start_j, start_j, -1
	add end_i, end_i, -1
	add end_j, end_j, -1
	
	move $a0, start_i
	move $a1, start_j
	jal puzzle
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
puzzle:
	push($ra)
	move start_i, $a0
	move start_j, $a1
	
if_1_begin:
	bne start_i, end_i, if_1_end
	bne start_j, end_j, if_1_end
	li $v0, 1
	pop($ra)
	jr $ra
if_1_end:

if_2_begin:
	li cond, 0
	slt temp, start_i, $zero
	add cond, cond, temp
	sge temp, start_i, n
	add cond, cond, temp
	slt temp, start_j, $zero
	add cond, cond, temp
	sge temp, start_j, m
	add cond, cond, temp
	
	beqz cond, if_2_end
	li $v0, 0
	pop($ra)
	jr $ra
if_2_end:
	
if_3_begin:
	la p, matrix
	sll offset, start_i, 3
	add offset, offset, start_j
	sll offset, offset, 2
	add p, p, offset
	lw temp, 0(p)
	
	beqz temp, if_3_end
	li, $v0, 0
	pop($ra)
	jr $ra
if_3_end:

	li temp, 1
	sw temp, 0(p)
	
	li result, 0
	
	add $a0, start_i, -1
	move $a1, start_j
	push(p)
	push(result)
	push(start_i)
	push(start_j)
	jal puzzle
	pop(start_j)
	pop(start_i)
	pop(result)
	pop(p)
	add result, result, $v0
	
	add $a0, start_i, 1
	move $a1, start_j
	push(p)
	push(result)
	push(start_i)
	push(start_j)
	jal puzzle
	pop(start_j)
	pop(start_i)
	pop(result)
	pop(p)
	add result, result, $v0
	
	move $a0, start_i
	add $a1, start_j, -1
	push(p)
	push(result)
	push(start_i)
	push(start_j)
	jal puzzle
	pop(start_j)
	pop(start_i)
	pop(result)
	pop(p)
	add result, result, $v0
	
	move $a0, start_i
	add $a1, start_j, 1
	push(p)
	push(result)
	push(start_i)
	push(start_j)
	jal puzzle
	pop(start_j)
	pop(start_i)
	pop(result)
	pop(p)
	add result, result, $v0
	
	sw $zero, 0(p)
	
	move $v0, result
	pop($ra)
	jr $ra
	