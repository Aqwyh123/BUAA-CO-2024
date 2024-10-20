.eqv s $t9
.eqv t $t8
.eqv vs $t7 
.eqv vt $t6
.eqv i $t5
.eqv n $s7
.eqv flag $s6

.data
string: .byte 0: 20
.text
	la s, string
	li $v0, 5
	syscall
	move n, $v0
	li i, 0
loop:
	beq i, n, loop_end
	li $v0, 12
	syscall
	sb $v0, 0(s)
	add s, s, 1
	add i, i, 1
	j loop
loop_end:
	la t, string
	add s, s, -1
	li, flag, 1
loop_:
	ble 	s, t, loop_end_
	lb vs, 0(s)
	lb vt, 0(t)
if:
	beq vs, vt, end_if
	li, flag, 0
	j loop_end_
end_if:
	add, t, t, 1
	add, s, s, -1
	j loop_
loop_end_:
	move $a0, flag
	li $v0, 1
	syscall
	li $v0, 10
	syscall
	

	
	
	
	
