.text
main:
    li      $t0,        400
    li      $t1,        100
    li      $t2,        4
    addi    $v0,        $0,     5           # system call #5 - input int
    syscall                                 # execute system call
    div     $v0,        $t0
    mfhi    $t3
    beq     $t3,        $0,     prime
    div     $v0,        $t1
    mfhi    $t3
    beq     $t3,        $0,     not_prime
    div     $v0,        $t2
    mfhi    $t3
    beq     $t3,        $0,     prime
    j       not_prime

prime:
    addi    $v0,        $0,     1           # system call #1 - print int
    addi    $a0,        $0,     1
    syscall                                 # execute
    j       exit
not_prime:
    addi    $v0,        $0,     1           # system call #1 - print int
    addi    $a0,        $0,     0
    syscall                                 # execute
    j       exit
exit:
    addi    $v0,        $0,     10          # System call 10 - Exit
    syscall                                 # execute