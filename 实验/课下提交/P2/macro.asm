.macro arrChr(%name, %len)
	%name: .byte 0: %len 
.end_macro

.macro arrInt(%name, %len)
	%name: .word 0: %len 
.end_macro

.macro string(%name,%cont)
	%name: .asciiz %cont
.end_macro

.macro printInt(%addr)
	move $a0, %addr
	li $v0, 1
	syscall
.end_macro

.macro printStr(%addr)
	move $a0, %addr
	li $v0, 4
	syscall
.end_macro

.macro printChr(%addr)
	move $a0, %addr
	li $v0, 11
	syscall
.end_macro

.macro scanInt(%addr)
	li $v0, 5
	syscall
	move %addr, $v0
.end_macro

.macro scanStr(%addr, %len)
	move $a0, %addr
	move $a1, %len
	li $v0, 8
	syscall
.end_macro

.macro scanChr(%addr)
	li $v0, 12
	syscall
	move %addr, $v0
.end_macro

.macro exit
	li $v0, 10
	syscall
.end_macro

.macro push(%num)
	add $sp $sp -4
	sw %num 0($sp)
.end_macro

.macro pop(%num)
	lw %num 0($sp)
	add $sp $sp 4
.end_macro

.macro getArrOff(%off, %i)
	sll off, 2
.end_macro

.macro getMatOff(%off, %row, %col, %rank)
    multu %row, %rank
    mflo %off
    addu %off, %off, %col
    sll %off, %off, 2
.end_macro

.data 
	arrInt(arrint,100)
.text
main:
	exit