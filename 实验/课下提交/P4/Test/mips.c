// Author: 杜选政 23230607
// Address : http ://cscore.buaa.edu.cn/#/discussion_area/1487/1828/posts

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define IM_SIZE 1024 // 指令内存大小，假设最多 1024 条指令
#define DM_SIZE 3072 // 数据内存大小，假设 3072 个 32 位数据
#define GRF_SIZE 32 // 通用寄存器文件大小，32 个寄存器

typedef struct {
    uint32_t instruction_memory[IM_SIZE];
    int instruction_count; // 统计指令数量
} IM;

typedef struct {
    uint32_t data_memory[DM_SIZE]; // 数据内存数组
} DM;

typedef struct {
    uint32_t registers[GRF_SIZE];
} GRF;

// 定义全局变量
IM im;
DM dm;
GRF grf;
uint32_t pc;
// 初始化指令内存为 0
void im_initialize()
{
    for (int i = 0; i < IM_SIZE; i++) {
        im.instruction_memory[i] = 0;
    }
}

// 初始化数据内存
void dm_initialize()
{
    for (int i = 0; i < DM_SIZE; i++) {
        dm.data_memory[i] = 0; // 将数据内存全部初始化为 0
    }
}

// 初始化寄存器文件
void gtf_initialize()
{
    for (int i = 0; i < GRF_SIZE; i++) {
        grf.registers[i] = 0; // 将所有寄存器初始化为 0
    }
}

// 加载指令
void load_instructions()
{
    printf("请直接粘贴指令，每条指令占 32 位 (例如：341c0000)。输入 'exit' 停止输入。\n");

    char input[16];
    im.instruction_count = 0; // 初始化指令数量
    while (im.instruction_count < IM_SIZE) {
        if (fgets(input, sizeof(input), stdin) == NULL) {
            break; // 若遇到输入错误或结束，则退出
        }

        // 去除换行符
        input[strcspn(input, "\n")] = '\0';

        // 如果输入的是 "exit"，则停止输入
        if (strcmp(input, "exit") == 0) {
            break;
        }

        // 将十六进制字符串转换为整数
        uint32_t instruction;
        if (sscanf(input, "%x", &instruction) == 1) {
            im.instruction_memory[im.instruction_count] = instruction;
            im.instruction_count++; // 增加指令计数
        }
        else {
            printf("输入格式错误，请重新输入！\n");
        }
    }
}

int32_t sign_extend(uint32_t immediate)
{
    // 如果立即数的最高位（第 15 位）为 1，则需要符号扩展
    if (immediate & 0x8000) {
        // 最高位为 1，进行符号扩展
        return (int32_t)(immediate | 0xFFFF0000); // 将高位填充为 1
    }
    else {
        // 最高位为 0，直接返回
        return (int32_t)immediate; // 直接返回
    }
}

// 定义 add 指令函数
void execute_add(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 再接下来的 5 位
    uint32_t rd = (instruction >> 11) & 0x1F;     // 再接下来的 5 位
    uint32_t shamt = (instruction >> 6) & 0x1F;   // 再接下来的 5 位
    uint32_t funct = instruction & 0x3F;          // 最后 6 位

    // 检查是否是 add 指令
    if (opcode == 0x00 && funct == 0x20) {
        if (rd == 0x00) {
            return;
        }
        // 从寄存器文件中读取 rs 和 rt 的值
        uint32_t rs_value = grf.registers[rs];
        uint32_t rt_value = grf.registers[rt];

        // 计算结果
        uint32_t result = rs_value + rt_value;

        // 将结果写入 rd 寄存器
        grf.registers[rd] = result;

        // 打印执行结果
        //printf("执行 ADD 指令: $%d = $%d + $%d -> %d + %d = %d\n", rd, rs, rt, rs_value, rt_value, result);
        printf("@%08x: $%2d <= %08x\n", pc, rd, grf.registers[rd]);
    }
    else {
        printf("错误：不是有效的 ADD 指令\n");
    }
}

void execute_sub(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 再接下来的 5 位
    uint32_t rd = (instruction >> 11) & 0x1F;     // 再接下来的 5 位
    uint32_t shamt = (instruction >> 6) & 0x1F;   // 再接下来的 5 位
    uint32_t funct = instruction & 0x3F;          // 最后 6 位

    // 检查是否是 sub 指令
    if (opcode == 0x00 && funct == 0x22) {
        if (rd == 0x00) {
            return;
        }
        // 从寄存器文件中读取 rs 和 rt 的值
        uint32_t rs_value = grf.registers[rs];
        uint32_t rt_value = grf.registers[rt];

        // 计算结果
        uint32_t result = rs_value - rt_value;

        // 将结果写入 rd 寄存器
        grf.registers[rd] = result;

        // 打印执行结果
        //printf("执行 SUB 指令: $%d = $%d - $%d -> %d - %d = %d\n", rd, rs, rt, rs_value, rt_value, result);
        printf("@%08x: $%2d <= %08x\n", pc, rd, grf.registers[rd]);
    }
    else {
        printf("错误：不是有效的 SUB 指令\n");
    }
}

void execute_ori(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 再接下来的 5 位
    uint32_t immediate = instruction & 0xFFFF;     // 最后 16 位

    // 检查是否是 ori 指令
    if (opcode == 0xD) {
        if (rt == 0x00) {
            return;
        }
        // 从寄存器文件中读取 rs 的值
        uint32_t rs_value = grf.registers[rs];

        // 计算结果
        uint32_t result = rs_value | immediate;

        // 将结果写入 rt 寄存器
        grf.registers[rt] = result;

        // 打印执行结果
        //printf("执行 ORI 指令: $%d = $%d | %u -> %d | %u = %d\n", rt, rs, immediate, rs_value, immediate, result);
        printf("@%08x: $%2d <= %08x\n", pc, rt, grf.registers[rt]);
    }
    else {
        printf("错误：不是有效的 ORI 指令\n");
    }
}

void execute_lui(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 接下来的 5 位
    uint32_t immediate = instruction & 0xFFFF;     // 最后 16 位

    // 检查是否是 lui 指令
    if (opcode == 0xF) {
        if (rt == 0x00) {
            return;
        }
        // 将立即数加载到 rt 寄存器的高 16 位，并清零低 16 位
        grf.registers[rt] = immediate << 16;

        // 打印执行结果
        //printf("执行 LUI 指令: $%d = %u << 16 -> %u\n", rt, immediate, grf.registers[rt]);
        printf("@%08x: $%2d <= %08x\n", pc, rt, grf.registers[rt]);

    }
    else {
        printf("错误：不是有效的 LUI 指令\n");
    }
}

void execute_lw(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 再接下来的 5 位
    uint32_t offset = instruction & 0xFFFF;
    int32_t extended_offset = sign_extend(offset); // 最后 16 位

    // 检查是否是 lw 指令
    if (opcode == 0x23) {
        if (rt == 0x00) {
            return;
        }
        // 计算内存地址
        uint32_t address = grf.registers[rs] + extended_offset;

        // 从数据内存中加载数据
        grf.registers[rt] = dm.data_memory[address / 4]; // 读取字（4 字节）

        // 打印执行结果
        //printf("@%08X: *%08X <= %08X\n", pc, address, grf.registers[rt]);
        printf("@%08x: $%2d <= %08x\n", pc, rt, dm.data_memory[address / 4]);
    }
    else {
        printf("错误：不是有效的 LW 指令\n");
    }
}

void execute_sw(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 再接下来的 5 位
    uint32_t offset = instruction & 0xFFFF;
    int32_t extended_offset = sign_extend(offset); // 最后 16 位

    // 检查是否是 sw 指令
    if (opcode == 0x2B) {
        // 计算内存地址
        uint32_t address = grf.registers[rs] + extended_offset;
        // 从源寄存器中获取数据，并存入数据内存
        dm.data_memory[address / 4] = grf.registers[rt]; // 存储字（4 字节）

        // 打印执行结果
        //printf("执行 SW 指令: MEM[$%d + %d] = $%d -> %u\n", rs, extended_offset, rt, grf.registers[rt]);
        printf("@%08x: *%08x <= %08x\n", pc, address, grf.registers[rt]);
    }
    else {
        printf("错误：不是有效的 SW 指令\n");
    }
}

int execute_beq(uint32_t instruction, int current_position)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t rt = (instruction >> 16) & 0x1F;     // 再接下来的 5 位
    uint32_t offset = instruction & 0xFFFF;
    int32_t extended_offset = sign_extend(offset); // 最后 16 位

    // 检查是否是 beq 指令
    if (opcode == 0x04) {
        // 从寄存器文件中读取 rs 和 rt 的值
        uint32_t rs_value = grf.registers[rs];
        uint32_t rt_value = grf.registers[rt];

        // 检查两个寄存器的值是否相等
        if (rs_value == rt_value) {
            // 如果相等，计算新的指令位置
            return current_position + 4 + (extended_offset << 2); // 左移 2 位以转换为字节
        }
    }

    // 如果不跳转，返回当前指令的下一个位置
    return current_position + 4; // 默认下一个指令位置
}

int execute_j(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t address = instruction & 0x3FFFFFF;   // 后 26 位

    // 检查是否是 j 指令
    if (opcode == 0x02) {
        // 将 26 位地址转换为字节地址
        return (address << 2); // 左移 2 位以转换为字节
    }
    else {
        printf("错误：不是有效的 J 指令\n");
        return -1; // 返回无效值
    }
}

int execute_jal(uint32_t instruction, int current_position)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t address = instruction & 0x3FFFFFF;   // 后 26 位

    // 检查是否是 jal 指令
    if (opcode == 0x03) {
        // 将返回地址存入 $ra（寄存器 31）
        grf.registers[31] = current_position + 4; // 当前指令位置 + 4（下一条指令地址）

        // 将 26 位地址转换为字节地址
        int target_address = (address << 2); // 左移 2 位以转换为字节

        // 打印跳转信息
       // printf("执行 JAL 指令: 跳转到地址 %d，返回地址存入 $ra: %d\n", target_address, grf.registers[31]);
        printf("@%08x: $31 <= %08x\n", pc, grf.registers[31]);
        // 跳转到目标地址
        return target_address;
    }
    else {
        printf("错误：不是有效的 JAL 指令\n");
    }
}

int execute_jr(uint32_t instruction)
{
    // 提取指令字段
    uint32_t opcode = (instruction >> 26) & 0x3F; // 前 6 位
    uint32_t rs = (instruction >> 21) & 0x1F;     // 接下来的 5 位
    uint32_t funct = instruction & 0x3F;          // 最后 6 位
    // 检查是否是 jr 指令
    if (opcode == 0 && funct == 0x08) {
        // 从寄存器文件中读取目标地址
        int jump_address = grf.registers[rs];

        // 打印跳转信息
        //printf("执行 JR 指令: 跳转到地址 %d\n", jump_address);

        // 返回跳转地址
        return jump_address;
    }
    else {
        printf("错误：不是有效的 JR 指令\n");
        return -1; // 返回无效值
    }
}

int execute_instruction(uint32_t instruction, int current_position)
{
    uint32_t opcode = (instruction >> 26) & 0x3F; // 提取前 6 位作为 opcode
    uint32_t funct = instruction & 0x3F;
    switch (opcode) {
        case 0x00: // R 类型指令
            // 提取 funct 字段
            switch (funct) {
                case 0x20: // add
                    execute_add(instruction);
                    return current_position + 4; // 返回下一条指令地址
                case 0x22: // sub
                    execute_sub(instruction);
                    return current_position + 4; // 返回下一条指令地址
                case 0x0C: // syscall (假设你要实现这个指令)
                    // 这里可以添加 syscall 的处理
                case 0x08: // jr
                    return execute_jr(instruction); // 返回跳转地址
                    break;
                    // 其他 R 类型指令...
                case 0x00:
                    return current_position + 4;
                default:
                    printf("未知的 R 类型指令\n");
                    return -1; // 返回无效值
            }

        case 0x0D: // ori
            execute_ori(instruction);
            return current_position + 4; // 返回下一条指令地址

        case 0x0F: // lui
            execute_lui(instruction);
            return current_position + 4; // 返回下一条指令地址

        case 0x23: // lw
            execute_lw(instruction);
            return current_position + 4; // 返回下一条指令地址

        case 0x2B: // sw
            execute_sw(instruction);
            return current_position + 4; // 返回下一条指令地址

        case 0x04: // beq
            return execute_beq(instruction, current_position); // 返回跳转地址

        case 0x02: // j
            return execute_j(instruction); // 返回跳转地址

        case 0x03: // jal
            return execute_jal(instruction, current_position); // 返回跳转地址


        default:
            printf("未知的指令\n");
            return -1; // 返回无效值
    }

    return current_position + 4; // 默认返回下一条指令地址
}





int main()
{
    pc = 0x3000; // 初始化 PC
    uint32_t instruction;
    // 初始化内存和寄存器文件
    im_initialize();
    dm_initialize();
    gtf_initialize();
    int instrnum = 0;
    // 加载指令
    load_instructions();

    // 输出加载的指令进行验证
   // printf("\n已加载的指令:\n");
   // for (int i = 0; i < im.instruction_count; i++) {
     //   printf("指令 %d: 0x%08X\n", i, im.instruction_memory[i]);
  //  } 
    while (pc < 0x3000 + (IM_SIZE * 4)) { // 假设指令内存的范围
        int index = (pc - 0x3000) / 4; // 计算指令存储器索引
        instrnum++;
        if (instrnum >= 2048) {//执行指令数小于2048
            break;
        }
        instruction = im.instruction_memory[index]; // 从指令内存获取指令

        // 执行指令
        if (index >= im.instruction_count) {
            break;
        }
        pc = execute_instruction(instruction, pc); // 更新 PC
        // 检查返回值是否有效
        if (pc == -1) {
            break; // 处理无效指令
        }

    }

    return 0;
}
