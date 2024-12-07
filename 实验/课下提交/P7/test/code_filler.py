import sys

std_num = 4096

with open(sys.argv[1], 'r+') as f:
    lines = f.readlines()
    now_num = len(lines)
    for i in range(now_num, std_num):
        if i == std_num - 2:
            f.write('1000ffff\n')  # beq $0, $0, 0
        else:
            f.write('00000000\n')
