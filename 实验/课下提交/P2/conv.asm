.eqv x1 $t9
.eqv x2 $t8
.eqv r $t7
.eqv m1 $s7
.eqv n1 $s6
.eqv m2 $s5
.eqv n2 $s4
.eqv num1 $t6
.eqv num2 $t5
.eqv b1 $t6
.eqv b2 $t5
.eqv i1 $t4
.eqv i2 $t3
.eqv i3 $t2
.eqv i4 $t1
.eqv sum $t0
.eqv offset1 $s3
.eqv offset2 $s2
.eqv val1 $s1
.eqv val2 $s0

.data
	matrix1: .word 0: 100
	matrix2: .word 0: 100
	result: .word 0: 100
	space: .asciiz " "
	newline: .asciiz "\n"
.text 
main:
	li $v0, 5
	syscall
	move m1, $v0
	li $v0, 5
	syscall
	move n1, $v0
	li $v0, 5
	syscall
	move m2, $v0
	li $v0, 5
	syscall
	move n2, $v0

	mul num1, m1, n1
	la x1, matrix1
	li i1, 0
for_begin_1:
	beq i1, num1, for_end_1
	li $v0, 5
	syscall
	sw $v0, 0(x1)
	add x1, x1, 4
	add i1, i1, 1
	j for_begin_1
for_end_1:

	mul num2, m2, n2
	la x2, matrix2
	li i2, 0
for_begin_2:
	beq i2, num2, for_end_2
	li $v0, 5
	syscall
	sw $v0, 0(x2)
	add x2, x2, 4
	add i2, i2, 1
	j for_begin_2
for_end_2:

	sub b1, m1, m2
	add b1, b1, 1
	sub b2, n1, n2
	add b2, b2, 1
	
	li i1, 0
for_begin_a:
	beq i1, b1, for_end_a
	
	li i2, 0
for_begin_b:
	beq i2, b2, for_end_b
	
	li sum, 0
	
	li i3, 0
for_begin_c:
	beq i3, m2, for_end_c
	
	li i4, 0
for_begin_d:
	beq i4, n2, for_end_d
	
	la x1, matrix1
	add offset1, i1, i3
	mul offset1, offset1, n1
	add offset1, offset1, i2
	add offset1, offset1, i4
	sll offset1, offset1, 2
	add x1, x1, offset1
	lw val1, 0(x1)
	
	la x2, matrix2
	mul offset2, i3, n2
	add offset2, offset2, i4
	sll offset2, offset2, 2
	add x2, x2, offset2
	lw val2, 0(x2)
	
	mul val1, val1, val2
	add sum, sum, val1
	
	add i4, i4, 1
	j for_begin_d
for_end_d:
	add i3, i3, 1
	j for_begin_c
for_end_c:
	la r, result
	mul offset1, i1, b2
	add offset1, offset1, i2
	sll offset1, offset1, 2
	add r, r, offset1
	sw sum, 0(r)
	
	add i2, i2, 1
	j for_begin_b
for_end_b:
	add i1, i1, 1
	j for_begin_a
for_end_a:

	li i1, 0
for_begin_A:
	beq i1, b1, for_end_A
	
	li i2, 0
for_begin_B:
	beq i2, b2, for_end_B
	
	la r, result
	mul offset1, i1, b2
	add offset1, offset1, i2
	sll offset1, offset1, 2
	add r, r, offset1
	lw $a0, 0(r)
	li $v0, 1
	syscall
	la $a0, space
	li $v0, 4
	syscall
	
	add i2, i2, 1
	j for_begin_B
for_end_B:
	la $a0, newline
	li $v0, 4
	syscall
	
	add i1, i1, 1
	j for_begin_A
for_end_A:
	li $v0, 10
	syscall
	
	
	
	
	
	






