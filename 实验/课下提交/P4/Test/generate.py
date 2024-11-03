# Author : 梁乐轩 23373299
# Address: http://cscore.buaa.edu.cn/#/discussion_area/1476/1767/posts

import random
import os

file_name = "std.asm"


def generate(instr_type: str, instr_num: int = 0, file_mode: str = "w"):
    file = open(file_name, file_mode)
    if instr_type == "ori":
        for line in range(0, instr_num // 2):
            a = random.randint(0, 31)
            while a == 28 or a == 29:
                a = random.randint(0, 31)
            b = random.randint(0, 31)
            while b == 28 or b == 29:
                b = random.randint(0, 31)
            c = random.randint(0, 65535)
            file.write(f"ori ${a}, ${b}, {c}\n")
            file.write(f"sw ${a}, {line * 4}($0)\n")
    elif instr_type == "lui":
        for line in range(0, instr_num // 2):
            a = random.randint(0, 31)
            while a == 28 or a == 29:
                a = random.randint(0, 31)
            c = random.randint(0, 65535)
            file.write(f"lui ${a}, {c}\n")
            file.write(f"sw ${a}, {line * 4}($0)\n")
    elif instr_type == "sw" or instr_type == "lw":
        for line in range(0, instr_num // 3):
            a = random.randint(0, 31)
            while a == 28 or a == 29:
                a = random.randint(0, 31)
            b = random.randint(0, 31)
            while b == 28 or b == 29:
                b = random.randint(0, 31)
            c = random.randint(0, 65535)
            if line != 0:
                file.write(f"lw ${b}, {(line - 1) * 4}($0)\n")
            file.write(f"ori ${a}, ${b}, {c}\n")
            file.write(f"sw ${a}, {line * 4}($0)\n")
    elif instr_type == "add":
        for line in range(0, instr_num // 6):
            a = random.randint(0, 31)
            while a == 28 or a == 29:
                a = random.randint(0, 31)
            b = random.randint(0, 31)
            while b == 28 or b == 29:
                b = random.randint(0, 31)
            c = random.randint(0, 65535)
            d = random.randint(0, 65535)
            e = random.randint(0, 65535)
            f = random.randint(0, 65535)

            file.write(f"lui ${a}, {c}\n")
            file.write(f"ori ${a}, ${a}, {d}\n")
            file.write(f"lui ${b}, {e}\n")
            file.write(f"ori ${b}, ${b}, {f}\n")
            file.write(f"add ${a}, ${a}, ${b}\n")
            file.write(f"sw ${a}, {line * 4}($0)\n")
    elif instr_type == "sub":
        for line in range(0, instr_num // 6):
            a = random.randint(0, 31)
            while a == 28 or a == 29:
                a = random.randint(0, 31)
            b = random.randint(0, 31)
            while b == 28 or b == 29:
                b = random.randint(0, 31)
            c = random.randint(0, 65535)
            d = random.randint(0, 65535)
            e = random.randint(0, 65535)
            f = random.randint(0, 65535)

            file.write(f"lui ${a}, {c}\n")
            file.write(f"ori ${a}, ${a}, {d}\n")
            file.write(f"lui ${b}, {e}\n")
            file.write(f"ori ${b}, ${b}, {f}\n")
            file.write(f"sub ${a}, ${a}, ${b}\n")
            file.write(f"sw ${a}, {line * 4}($0)\n")
    elif instr_type == "beq":
        write_temp = '''ori $t1, 4
ori $t2, 8
ori $t3, 16
ori $t4, 16
beq $t1, $t2, next
sw $t1, 0($t1)
next:
sw $t2, 0($t2)
add $t2, $t2, $t1
beq $t3, $t4, what
sw $t2, 0($t2)
what:
sw $t3, 0($t3)
'''
        file.write(write_temp)
    elif instr_type == "jr" or instr_type == "jal":
        write_temp = '''ori $t1, $zero, 0
ori $t2, $zero, 10
ori $t0, $zero, 1
ori $t4, $zero, 0
ori $t5, $zero, 4
ori $a0, $zero, 0
ori $a1, $zero, 10
for_i_begin:
beq $t1, $t2, for_i_end
add $t1, $t1, $t0
sw $t4, 0($t4)
add $t4, $t4, $t5
jal for_i_begin
beq $a0, $a1, true_end
add $a0, $a0, $t0
sw $t4, 0($t4)
add $t4, $t4, $t5
for_i_end:
jr $ra
true_end:
'''
        file.write(write_temp)
    file.close()


supported_instr = ["ori", "lui", "sw", "lw", "add", "sub", "beq", "jr", "jal"]
all_instr = ["ori", "lui", "lw", "add", "sub", "beq", "jal"]
no_need_num = ["beq", "jr", "jal"]

if __name__ == "__main__":
    if os.path.exists(file_name):
        os.remove(file_name)
    while True:
        input_type = input("Input the type of instruction: ")
        if input_type == "all":
            for instr in all_instr[::-1]:
                generate(instr, 30, "a")
            break
        if input_type not in supported_instr:
            print("Wrong input. Please try again!")
            continue
        if input_type not in no_need_num:
            input_num = input("Input the number of instructions: ")
            if not input_num.isdigit():
                print("Wrong input. Please try again!")
                continue
            generate(input_type, int(input_num))
            break
        generate(input_type)
        break
