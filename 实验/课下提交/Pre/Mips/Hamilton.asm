.data

Graph:  .word   0:64                                    # 8 * 8
Book:   .word   0:8                                     # 8

.text

main:

    la      $s0,                Graph                   # $s0 = Graph
    la      $s1,                Book                    # $s1 = Book
    li      $s2,                0                       # $s2 = ans = 0
    addi    $v0,                $0,     5
    syscall
    move    $s3,                $v0                     # $s3 = n
    addi    $v0,                $0,     5
    syscall
    move    $s4,                $v0                     # $s4 = m
    li      $s5,                1                       # $s5 = 1
    # $t0 = i, $t4 = offset, $s2 = ans

    li      $t0,                0
loop_main_judge:
    blt     $t0,                $s4,    loop_main_begin # while i < m
    j       loop_main_end
loop_main_begin:
    addi    $v0,                $0,     5
    syscall
    move    $t1,                $v0                     # $t1 = x
    addi    $v0,                $0,     5
    syscall
    move    $t2,                $v0                     # $t2 = y
    addi    $t1,                $t1,    -1              # x = x - 1
    addi    $t2,                $t2,    -1              # y = y - 1

    move    $t3,                $s0                     # $t3 = Graph
    mul     $t4,                $t1,    8               # offset = x * 8
    add     $t4,                $t4,    $t2             # offset = offset + y
    mul     $t4,                $t4,    4               # offset = offset * 4
    add     $t3,                $t3,    $t4             # $t3 = Graph + offset
    sw      $s5,                0($t3)                  # Graph[x][y] = 1

    move    $t3,                $s0                     # $t3 = Graph
    mul     $t4,                $t2,    8               # offset = y * 8
    add     $t4,                $t4,    $t1             # offset = offset + x
    mul     $t4,                $t4,    4               # offset = offset * 4
    add     $t3,                $t3,    $t4             # $t3 = Graph + offset
    sw      $s5,                0($t3)                  # Graph[y][x] = 1

    addi    $t0,                $t0,    1               # i = i + 1
    j       loop_main_judge
loop_main_end:
    #li      $t5,                0
    #li      $t6,                0
    #li      $t7,                0
    li      $a0,                0                       # parameter for dfs
    jal     dfs
    addi    $v0,                $0,     1
    add     $a0,                $0,     $s2
    syscall                                             # print ans
    li      $v0,                10
    syscall                                             # exit

dfs:
    addi    $sp,                $sp,    -4
    sw      $ra,                0($sp)                  # save $ra
    addi    $sp,                $sp,    -4
    sw      $t0,                0($sp)                  # save graph
    addi    $sp,                $sp,    -4
    sw      $t1,                0($sp)                  # save record
    addi    $sp,                $sp,    -4
    sw      $t2,                0($sp)                  # save offset
    addi    $sp,                $sp,    -4
    sw      $t3,                0($sp)                  # save flag
    addi    $sp,                $sp,    -4
    sw      $t4,                0($sp)                  # save i
    addi    $sp,                $sp,    -4
    sw      $t5,                0($sp)                  # save temp1
    addi    $sp,                $sp,    -4
    sw      $t6,                0($sp)                  # save temp2
    addi    $sp,                $sp,    -4
    sw      $t7,                0($sp)                  # save parameter

    move    $t7,                $a0                     # $t7 = parameter

    mul     $t2,                $t7,    4               # offset = parameter * 4
    add     $t1,                $s1,    $t2             # $t1 = Book + offset
    sw      $s5,                0($t1)                  # Book[parameter] = 1

    li      $t3,                1                       # flag = 1

    li      $t4,                0                       # i = 0
loop1_dfs_judge:
    blt     $t4,                $s3,    loop1_dfs_begin # while i < n
    j       loop1_dfs_end
loop1_dfs_begin:
    mul     $t2,                $t4,    4               # offset = i * 4
    add     $t1,                $s1,    $t2             # record = Book + offset
    lw      $t5,                0($t1)                  # temp1 = Book[i]
    and     $t3,                $t3,    $t5             # flag = flag & Book[i]
    addi    $t4,                $t4,    1               # i = i + 1
    j       loop1_dfs_judge
loop1_dfs_end:

    move    $t0,                $s0                     # graph = Graph
    mul     $t2,                $t7,    8               # offset = parameter * 8
    mul     $t2,                $t2,    4               # offset = offset * 4
    add     $t1,                $t0,    $t2             # graph = Graph + offset
    lw      $t5,                0($t1)                  # temp1 = Graph[parameter][0]

    beqz    $t3,                else1                   # if flag == 0, return
    beqz    $t5,                else1                   # if Graph[parameter][0] == 0, return
    j       dfs_end_with_1

else1:
    li      $t4,                0                       # i = 0
loop2_dfs_judge:
    blt     $t4,                $s3,    loop2_dfs_begin # while i < n
    j       loop2_dfs_end
loop2_dfs_begin:
    mul     $t2,                $t4,    4               # offset = i * 4
    add     $t1,                $s1,    $t2             # record = Book + offset
    lw      $t5,                0($t1)                  # temp1 = Book[i]
    move    $t0,                $s0                     # graph = Graph
    mul     $t2,                $t7,    8               # offset = parameter * 8
    add     $t2,                $t2,    $t4             # offset = offset + i
    mul     $t2,                $t2,    4               # offset = offset * 4
    add     $t0,                $t0,    $t2             # graph = Graph + offset
    lw      $t6,                0($t0)                  # temp2 = Graph[parameter][i]

    bgtz    $t5,                else2                   # if book[i] > 0 goto else
    beqz    $t6,                else2                   # if graph[parameter][i] == 0 goto else
    move    $a0,                $t4                     # parameter = i
    jal     dfs
else2:
    addi    $t4,                $t4,    1               # i = i + 1
    j       loop2_dfs_judge
loop2_dfs_end:

    mul     $t2,                $t7,    4               # offset = parameter * 4
    add     $t1,                $s1,    $t2             # $t1 = Book + offset
    sw      $0,                 0($t1)                  # Book[parameter] = 0
    j       dfs_end

dfs_end_with_1:
    move    $s2,                $s5                     # ans = 1
dfs_end:
    lw      $t7,                0($sp)                  # restore parameter
    addi    $sp,                $sp,    4
    lw      $t6,                0($sp)                  # restore temp2
    addi    $sp,                $sp,    4
    lw      $t5,                0($sp)                  # restore temp1
    addi    $sp,                $sp,    4
    lw      $t4,                0($sp)                  # restore i
    addi    $sp,                $sp,    4
    lw      $t3,                0($sp)                  # restore flag
    addi    $sp,                $sp,    4
    lw      $t2,                0($sp)                  # restore offset
    addi    $sp,                $sp,    4
    lw      $t1,                0($sp)                  # restore record
    addi    $sp,                $sp,    4
    lw      $t0,                0($sp)                  # restore graph
    addi    $sp,                $sp,    4
    lw      $ra,                0($sp)                  # restore $ra
    addi    $sp,                $sp,    4
    jr      $ra                                         # return

