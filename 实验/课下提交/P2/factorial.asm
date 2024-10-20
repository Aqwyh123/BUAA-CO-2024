.eqv LEN 1000
.eqv n $s7
.eqv c $s6
.eqv i $t9
.eqv k $t8
.eqv u $t7
.eqv p $t6
.eqv o $t5
.eqv s $t4

.data
	r: .word 0: LEN
.text
main:
	li $t0, 1
	la p, r
	sw $t0, 0(p)
	
	li $v0, 5
	syscall
	move n, $v0
	
	li c, 1
	
	li i, 1
for_1_begin:
	bgt i, n, for_1_end
	
	li u, 0

	li k, 0
for_2_begin:
	beq k, c, for_2_end
	
	la p, r
	sll o, k, 2
	add p, p, o
	lw s, 0(p)
	mul s, s, i
	add s, s, u
	li $t0, 10
	div s, $t0
	mfhi $t0
	sw $t0 0(p)
	mflo u
	
	add k, k, 1
	j for_2_begin
for_2_end:

while_begin:
	beqz u, while_end
	la p, r
	sll o, c, 2
	add p, p, o
	li $t0, 10
	div u, $t0
	mfhi $t0
	sw $t0, 0(p)
	mflo u
	add c, c, 1
	j while_begin
while_end:

	add, i, i, 1
	j for_1_begin
for_1_end:

	add i, c, -1
for_3_begin:
	bltz i, for_3_end
	
	la p, r
	sll o, i, 2
	add p, p, o
	
	li $v0, 1
	lw $a0, 0(p)
	syscall
	
	add i, i, -1
	j for_3_begin
for_3_end:
	
	li $v0, 10
	syscall
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	