.text
ori $s0, $s0, 5		    # 自调用是否有问题
ori $s1, $zero, 4       # 
add $t0, $s0, $s1       # R型指令的两种转发是否有问题
lui $t1, 65535          # 与接下来的sub指令一起判断高位减法是否有问题
sw $s1, 0($s1)          # 判断line 3的指令写入GRF是否符合要求且无冲突
add $zero, $s1, $t0     # 给$0复制并观察是否转发数据为0
sub $t1, $zero, $t1     # 使用$0观察转发数据以及检查高位减法

lw $t1, 0($s1)          # 检查寄存器写入是否覆盖
sw $t1, 0($s1)          # 检查lw-sw的转发或阻塞是否实现

lw $t2, 0($s1)          
sub $t2, $s0, $s1
add $t4, $s0, $t2       # 以上三行检查R型指令转发的优先级是否正确

sub $s3, $s0, $s1       
ori $s4, $zero, 48
ori $s2, $zero, 12344   # 以上三行纯属为了凑数据()
lw $ra, 0($s1)          
sub $ra, $ra, $s1
jal tag1
nop                     #添加延时槽

tag1:
beq $ra, $s2, end1      # 以上六行反复对$ra更改以检查beq转发的优先级是否正确
nop
sw $ra, 0($s1)          
add $ra, $ra, $s1
end1:
sub $s0, $s0, $s3
beq $s0, $zero, end2    # 检查R型指令是否会对beq指令造成影响[笔者就在这里错了]
nop
jr $ra                  # 反复更改$ra后观察是否跳转到正确的pc值
nop

end2:
jal tag2                
nop
tag2:
lw $ra, 0($s1)
add $ra, $ra, $s4
jr $ra                  #以上六行检查jr指令转发的优先级是否正确
nop
lui $zero, 1111         # 最后jr $ra指令会跳转到该行