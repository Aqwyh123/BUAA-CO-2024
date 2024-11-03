// Author: 陈嘉民 23371149
// Address : http ://cscore.buaa.edu.cn/#/discussion_area/1491/1628/posts
    
#include <array>
#include <random>
#include <cstdio>
#include <cstdlib>
#include <climits>

using namespace std;

#define gpr_dex gpr[_index(generator)]
#define imm16 imm_16(generator)
#define rand dist(generator)
#define mod 12288

random_device seed;
uniform_int_distribution<int> _index(0, 25);
uniform_int_distribution<int> imm_16(0, 65535);
uniform_int_distribution<int> dist(INT_MIN, INT_MAX);
const array<int, 27> gpr = { 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 30, 31 };

class MIPS {
public:
    //        int gpr[32]{};
    //        int memory[3072]{};
    int cnt = 0, back_tot = 0, jal_tot = 0;

    /*MIPS() {
        // Initialize GPRs to 0
        for (int & reg : gpr) {
            reg = 0;
        }
        // Initialize memory to 0
        for (int & reg : memory) {
            reg = 0;
        }
    }*/

    void add(int rs, int rt, int rd)
    {
        printf("add $%d, $%d, $%d\n", rd, rs, rt);
        //            gpr[rd] = gpr[rs] + gpr[rt];
        //            gpr[0] = 0;
        cnt++;
    }

    void sub(int rs, int rt, int rd)
    {
        printf("sub $%d, $%d, $%d\n", rd, rs, rt);
        //            gpr[rd] = gpr[rs] - gpr[rt];
        //            gpr[0] = 0;
        cnt++;
    }

    void ori(int rs, int rt, int imm)
    {
        printf("ori $%d, $%d, %d\n", rt, rs, imm);
        //            gpr[rt] = gpr[rs] | imm;
        //            gpr[0] = 0;
        cnt++;
    }

    void lui(int rt, int imm)
    {
        printf("lui $%d, %d\n", rt, imm);
        //            gpr[rt] = imm << 16;
        //            gpr[0] = 0;
        cnt++;
    }

    void lw(int rt, int ofs)
    {
        printf("lw $%d, %d($0)\n", rt, ofs % mod >> 2 << 2);
        //            gpr[rt] = memory[ofs % mod >> 2];
        //            gpr[0] = 0;
        cnt++;
    }

    void sw(int rt, int ofs)
    {
        printf("sw $%d, %d($0)\n", rt, ofs % mod >> 2 << 2);
        //            memory[ofs % mod >> 2] = gpr[rt];
        cnt++;
    }

    void beq(int rs, int rt, const string &lab)
    {
        printf("beq $%d, $%d, %s\n", rs, rt, lab.c_str());
        cnt++;
    }

    void jal(const string &lab)
    {
        printf("jal %s\n", lab.c_str());
        cnt++;
        //            gpr[31] = (++cnt) << 2;
    }

    void jr()
    {
        puts("jr $ra");
        cnt++;
    }

    void nop()
    {
        puts("nop");
        cnt++;
    }

    void initialize_gpr()
    {
        for (auto dex : gpr) {
            mt19937 generator(seed());
            switch (rand & 3) {
                case 0: // Immediate16
                    ori(0, dex, imm16);
                    break;
                case 1: // value around 0
                    if (rand & 1) {
                        lui(1, 0xffff);
                        ori(1, 1, 0xffff - (rand & 3));
                        add(0, 1, dex);
                    }
                    else {
                        ori(0, dex, rand & 3);
                    }
                    break;
                case 2: // value around boundary
                    if (rand & 1) {
                        lui(1, 0x8000);
                        ori(1, 1, rand & 3);
                        add(0, 1, dex);
                    }
                    else {
                        lui(1, 0x7fff);
                        ori(1, 1, rand & 0xffff);
                        add(0, 1, dex);
                    }
                    break;
                default: // random value
                    lui(1, abs(rand) >> 16);
                    ori(1, 1, rand & 0xffff);
                    rand & 1 ? add(0, 1, dex) : sub(0, 1, dex);
                    break;
            }
        }
        beq(0, 0, "start");
    }

    void beq_backward()
    {
        uniform_int_distribution<int> back(1, 4);
        mt19937 generator(seed());
        back_tot = back(generator);
        for (int i = 0; i < back_tot; i++) {
            printf("beqBack_%d:\n", i);
            int beq_cnt = rand & 3;
            for (int j = 0; j < beq_cnt; j++) {
                switch (imm16 % 7) {
                    case 0:
                        add(gpr_dex, gpr_dex, gpr_dex);
                        break;
                    case 1:
                        sub(gpr_dex, gpr_dex, gpr_dex);
                        break;
                    case 2:
                        ori(gpr_dex, gpr_dex, imm16);
                        break;
                    case 3:
                        lui(gpr_dex, imm16);
                        break;
                    case 4:
                        lw(gpr_dex, imm16);
                        break;
                    case 5:
                        sw(gpr_dex, imm16);
                        break;
                    default:
                        nop();
                        break;
                }
            }
            beq(0, 0, "beqRet_" + to_string(i));
        }
    }

    void jal_jr()
    {
        uniform_int_distribution<int> back(1, 4);
        mt19937 generator(seed());
        jal_tot = back(generator);
        for (int i = 0; i < jal_tot; i++) {
            printf("jalBack_%d:\n", i);
            int beq_cnt = rand & 3;
            for (int j = 0; j < beq_cnt; j++) {
                switch (imm16 % 7) {
                    case 0:
                        add(gpr_dex, gpr_dex, gpr_dex);
                        break;
                    case 1:
                        sub(gpr_dex, gpr_dex, gpr_dex);
                        break;
                    case 2:
                        ori(gpr_dex, gpr_dex, imm16);
                        break;
                    case 3:
                        lui(gpr_dex, imm16);
                        break;
                    case 4:
                        lw(gpr_dex, imm16);
                        break;
                    case 5:
                        sw(gpr_dex, imm16);
                        break;
                    default:
                        nop();
                        break;
                }
            }
            jr();
        }
    }

    void rand_instructions()
    {
        puts("start:");
        bool forward_branch = false;
        mt19937 generator(seed());
        uniform_int_distribution<int> tot(81, 90);
        int total = tot(generator), backward = 0, forward = 0, jal_cnt = 0;
        for (int i = cnt; i < total; i++) {
            switch (imm16 % 10) {
                case 0:
                    add(gpr_dex, gpr_dex, gpr_dex);
                    break;
                case 1:
                    sub(gpr_dex, gpr_dex, gpr_dex);
                    break;
                case 2:
                    ori(gpr_dex, gpr_dex, imm16);
                    break;
                case 3:
                    lui(gpr_dex, imm16);
                    break;
                case 4:
                    lw(gpr_dex, imm16);
                    break;
                case 5:
                    sw(gpr_dex, imm16);
                    break;
                case 6:
                    if (rand & 1) {
                        if (backward == back_tot) {
                            continue;
                        }
                        beq(0, 0, "beqBack_" + to_string(backward));
                        printf("beqRet_%d:\n", backward++);
                    }
                    else {
                        if (!forward_branch) {
                            beq(gpr_dex, gpr_dex, "beqFront_" + to_string(forward));
                            forward_branch = true;
                        }
                        else {
                            printf("beqFront_%d:\n", forward++);
                            forward_branch = false;
                        }
                    }
                    break;
                case 7:
                    if (jal_cnt == jal_tot) {
                        continue;
                    }
                    jal("jalBack_" + to_string(jal_cnt++));
                    break;
                default:
                    nop();
                    break;
            }
        }
        if (forward_branch) {
            printf("beqFront_%d:\n", forward);
        }
        while (backward < back_tot) {
            printf("beqRet_%d:\n", backward++);
        }
    }
} mips;

int main()
{
    // freopen("std.asm", "w", stdout);
    mips.initialize_gpr();
    mips.beq_backward();
    mips.jal_jr();
    mips.rand_instructions();
    return 0;
}