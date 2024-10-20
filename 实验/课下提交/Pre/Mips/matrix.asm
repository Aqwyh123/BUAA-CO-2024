.data
matrix: .space  1020
.text
main:
    la      $s2,        matrix

    addi    $v0,        $0,         5
    syscall
    move    $s0,        $v0                     # n = $s0

    addi    $v0,        $0,         5
    syscall
    move    $s1,        $v0                     # m = $s1

    la      $t2,        matrix
init_i:
    addi    $t0,        $zero,      1
begin_i:
    bgt     $t0,        $s0,        end_loop_i
    #beq     $t0,        $s0,        end_loop_i
    # before_j
init_j:
    addi    $t1,        $zero,      1
begin_j:
    bgt     $t1,        $s1,        end_loop_j
    #beq     $t1,        $s1,        end_loop_j

    addi    $v0,        $0,         5
    syscall
    move    $t3,        $v0

    beq     $t3,        $zero,      end_j
    sw      $t0,        0($t2)
    addi    $t2,        $t2,        4
    sw      $t1,        0($t2)
    addi    $t2,        $t2,        4
    sw      $t3,        0($t2)
    addi    $t2,        $t2,        4
end_j:
    addi    $t1,        $t1,        1
    j       begin_j

end_loop_j:
    # after_j
    j       end_i

end_i:
    addi    $t0,        $t0,        1
    j       begin_i
end_loop_i:
    li      $t0,        12
loop:
    beq     $t2,        $s2,        exit

    addi    $v0,        $0,         1
    lw      $a0,        -12($t2)
    syscall
    addi    $v0,        $0,         11
    la      $a0,        ' '
    syscall
    addi    $v0,        $0,         1
    lw      $a0,        -8($t2)
    syscall
    addi    $v0,        $0,         11
    la      $a0,        ' '
    syscall
    addi    $v0,        $0,         1
    lw      $a0,        -4($t2)
    syscall
    addi    $v0,        $0,         11
    la      $a0,        '\n'
    syscall

    sub     $t2,        $t2,        $t0
    j       loop
exit:
    li      $v0,        10
    syscall
