.eqv n $s7
.eqv m1 $s6
.eqv m2 $s5
.eqv m3 $s4
.eqv i1 $t9
.eqv i2 $t8
.eqv i3 $t7
.eqv offset1 $t6
.eqv offset2 $t5
.eqv offset3 $t4
.eqv addr1 $t3
.eqv addr2 $t2
.eqv addr3 $t1
.eqv sum $t0
.eqv val1 $s3
.eqv val2 $s2

.data
	matrix_1: .word 0: 64
	matrix_2: .word 0: 64
	matrix_3: .word 0: 64
	space: .asciiz " "
	next: .asciiz "\n"
.text
main:
	la m1, matrix_1
	la m2, matrix_2
	la m3, matrix_3
	li $v0, 5
	syscall
	move n, $v0
	
	mul $t0, n, n
	move addr1, m1
	li i1, 0
loop_1:
	beq i1, $t0, loop_end1
	li $v0, 5
	syscall
	sw $v0, 0(addr1)
	add addr1, addr1, 4
	add i1, i1, 1
	j loop_1
loop_end1:
	move addr2, m2
	li i2, 0
loop_2:
	beq i2, $t0, loop_end2
	li $v0, 5
	syscall
	sw $v0, 0(addr2)
	add addr2, addr2, 4
	add i2, i2, 1
	j loop_2
loop_end2:
	li i1, 0
loop_a:
	beq i1, n, loop_enda
	li i2, 0
loop_b:
	beq i2, n, loop_endb
	li sum, 0
	li i3, 0
loop_c:
	beq i3, n, loop_endc
	mul offset1, i1, n
	add offset1, offset1, i3
	sll offset1, offset1, 2
	mul offset2, i3, n
	add offset2, offset2, i2
	sll offset2, offset2, 2
	add addr1, m1, offset1
	add addr2, m2, offset2
	lw val1, 0(addr1)
	lw val2, 0(addr2)
	mul val1, val1, val2
	add sum, sum, val1
	add i3, i3, 1
	j loop_c
loop_endc:
	mul offset3, i1, n
	add offset3, offset3, i2
	sll offset3, offset3, 2
	add addr3, m3, offset3
	sw  sum, 0(addr3)
	add i2, i2, 1
	j loop_b
loop_endb:
	add i1, i1, 1
	j loop_a
loop_enda:
	li i1, 0
loop_A:
	beq i1, n, loop_endA
	li i2, 0
loop_B:
	beq i2, n, loop_endB
	mul offset3, i1, n
	add offset3, offset3, i2
	sll offset3, offset3, 2
	add addr3, m3, offset3
	lw $a0, 0(addr3)
	li $v0, 1
	syscall
	la $a0, space
	li $v0, 4
	syscall
	add i2, i2, 1
	j loop_B
loop_endB:
	la $a0, next
	li $v0, 4
	syscall
	add i1, i1, 1
	j loop_A
loop_endA:
	li $v0, 10
	syscall
	

	
	
	


	
	
	
	
	
