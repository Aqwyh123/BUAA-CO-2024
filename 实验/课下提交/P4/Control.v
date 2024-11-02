`include "macros.v"
module Control (
    input wire [5:0] opcode,
    input wire [5:0] funct,
    input wire [4:0] rt,
    output reg [3:0] ALUSrc,
    output reg [1:0] RegSrc,
    output reg [1:0] RegDst,
    output reg RegWrite,
    output reg [1:0] MemSrc,
    output reg [2:0] MemDst,
    output reg MemWrite,
    output reg [1:0] Branch,
    output reg [1:0] Jump,
    output reg [1:0] EXTop,
    output reg [3:0] ALUop
);
    always @(*) begin
        case (opcode)
            6'b000000: begin
                case (funct)
                    6'b100000: begin  // add
                        ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                        RegSrc = `REGSRC_ALU;
                        RegDst = `REGDST_RD;
                        RegWrite = 1'b1;
                        MemSrc = 2'b00;
                        MemDst = 2'b00;
                        MemWrite = 1'b0;
                        Branch = 2'b00;
                        Jump = 2'b00;
                        EXTop = 2'b00;
                        ALUop = `ALUOP_ADD;
                    end
                    6'b100010: begin  // sub
                        ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                        RegSrc = `REGSRC_ALU;
                        RegDst = `REGDST_RD;
                        RegWrite = 1'b1;
                        MemSrc = 2'b00;
                        MemDst = 2'b00;
                        MemWrite = 1'b0;
                        Branch = 2'b00;
                        Jump = 2'b00;
                        EXTop = 2'b00;
                        ALUop = `ALUOP_SUB;
                    end
                    6'b001000: begin  // jr
                        ALUSrc = 4'b0000;
                        RegSrc = 3'b000;
                        RegDst = 2'b00;
                        RegWrite = 1'b0;
                        MemSrc = 2'b00;
                        MemDst = 3'b000;
                        MemWrite = 1'b0;
                        Branch = 2'b00;
                        Jump = `JUMP_REG;
                        EXTop = 2'b00;
                        ALUop = 4'b0000;
                    end
                    default: begin
                        ALUSrc = 4'b0000;
                        RegSrc = 2'b00;
                        RegDst = 2'b00;
                        RegWrite = 1'b0;
                        MemSrc = 2'b00;
                        MemDst = 3'b000;
                        MemWrite = 1'b0;
                        Branch = 2'b00;
                        Jump = 2'b00;
                        EXTop = 2'b00;
                        ALUop = 4'b0000;
                    end
                endcase
            end
            6'b001101: begin  // ori
                ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                RegSrc = `REGSRC_ALU;
                RegDst = `REGDST_RT;
                RegWrite = 1'b1;
                MemSrc = 2'b00;
                MemDst = 2'b00;
                MemWrite = 1'b0;
                Branch = 2'b00;
                Jump = 2'b00;
                EXTop = `EXTOP_ZERO;
                ALUop = `ALUOP_OR;
            end
            6'b100011: begin  // lw
                ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                RegSrc = `REGSRC_MEM;
                RegDst = `REGDST_RT;
                RegWrite = 1'b1;
                MemSrc = 2'b00;
                MemDst = `MEMDST_WORD;
                MemWrite = 1'b0;
                Branch = 2'b00;
                Jump = 2'b00;
                EXTop = `EXTOP_SIGN;
                ALUop = `ALUOP_ADD;
            end
            6'b101011: begin  // sw
                ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                RegSrc = 2'b00;
                RegDst = `REGDST_RT;
                RegWrite = 1'b0;
                MemSrc = `MEMSRC_WORD;
                MemDst = 2'b00;
                MemWrite = 1'b1;
                Branch = 2'b00;
                Jump = 2'b00;
                EXTop = `EXTOP_SIGN;
                ALUop = `ALUOP_ADD;
            end
            6'b000100: begin  // beq
                ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                RegSrc = `REGSRC_ALU;
                RegDst = 2'b00;
                RegWrite = 1'b0;
                MemSrc = 2'b00;
                MemDst = 3'b000;
                MemWrite = 1'b0;
                Branch = `BRANCH_ZERO;
                Jump = 2'b00;
                EXTop = 2'b00;
                ALUop = `ALUOP_SUB;
            end
            6'b001111: begin  // lui
                ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                RegSrc = `REGSRC_ALU;
                RegDst = `REGDST_RT;
                RegWrite = 1'b1;
                MemSrc = 2'b00;
                MemDst = 2'b00;
                MemWrite = 1'b0;
                Branch = 2'b00;
                Jump = 2'b00;
                EXTop = `EXTOP_UPPER;
                ALUop = `ALUOP_OR;
            end
            6'b000011: begin  // jal
                ALUSrc = 4'b0000;
                RegSrc = `REGSRC_PC;
                RegDst = `REGDST_RA;
                RegWrite = 1'b1;
                MemSrc = 2'b00;
                MemDst = 3'b000;
                MemWrite = 1'b0;
                Branch = 2'b00;
                Jump = `JUMP_INDEX;
                EXTop = 2'b00;
                ALUop = 4'b0000;
            end
            default: begin
                ALUSrc = 4'b0000;
                RegSrc = 2'b00;
                RegDst = 2'b00;
                RegWrite = 1'b0;
                MemSrc = 2'b00;
                MemDst = 3'b000;
                MemWrite = 1'b0;
                Branch = 2'b00;
                Jump = 2'b00;
                EXTop = 2'b00;
                ALUop = 4'b0000;
            end
        endcase
    end
    /*
    wire add = opcode == 6'b000000 && funct == 6'b100000;
    wire sub = opcode == 6'b000000 && funct == 6'b100010;
    wire jr = opcode == 6'b000000 && funct == 6'b001000;
    wire ori = opcode == 6'b001101;
    wire lw = opcode == 6'b100011;
    wire sw = opcode == 6'b101011;
    wire beq = opcode == 6'b000100;
    wire lui = opcode == 6'b001111;
    wire jal = opcode == 6'b000011;

    assign ALUSrc[0] = sll || srl || sra || sllv || srlv || srav ? `ALUSRC1_RT : // 移位指令
                        `ALUSRC1_RS; // 其他指令
    assign ALUSrc[3:0] = sllv || srlv || srav ? `ALUSRC2_RS : // 可变移位指令
                        sll || srl || sra ? `ALUSRC2_S : // 不可变移位指令
                        bgez, bgezal, bltz, bltzal ? `ALUSRC2_ZERO : // 不读寄存器的 0 比较分支指令
                        addi || addiu || slti || sltiu || lb || lh || lw || lbu || lhu || sb || sh || sw || andi || ori || xori || lui ? `ALUSRC2_IMM_SHAMT : // 立即数/偏移计算指令
                        `ALUSRC2_RT; // 其他指令
    assign RegSrc = bltzal || bgezal || jal || jral ? `REGSRC_PC : // 链接指令
                    lb || lh || lw || lbu || lhu ? `REGSRC_MEM : // 读内存指令
                    `REGSRC_ALU; // 算术指令
    assign RegDst = bltzal || bgezal || jal || jral ? `REGDST_RA : // 链接指令
                    add || addu || sub || subu || slt || sltu || and || or || xor || nor || sll || srl || sra || sllv || srlv || srav ? `REGDST_RD : // 三操作数指令
                    `REGDST_RT; // 两操作数指令
    assign RegWrite = !(beq || bne || blez || bgtz || bltz || bgez || j || jr || sb || sh || sw); // 写内存指令和仅跳转指令不写寄存器
    assign MemSrc = sb ? `MEMSRC_BYTE : // 按字节
                    sh ? `MEMSRC_HALF : // 按半字
                    sw ? `MEMSRC_WORD : // 按字
                    `MEMSRC_WORD; // 默认按字，便于调试
    assign MemDst = lb ? `MEMDST_BYTE : // 按字节
                    lh ? `MEMDST_HALF : // 按半字
                    lw ? `MEMDST_WORD : // 按字
                    lbu ? `MEMDST_BYTEU : // 按无符号字节
                    lhu ? `MEMDST_HALFU : // 按无符号半字
                    `MEMDST_WORD; // 默认按字，便于调试
    assign MemWrite = sw || sb || sh; // 写内存指令
    assign Branch = beq || blez || bgez || bgezal ? `BRANCH_ZERO : // 零分支
                    bne || bgtz || bltz || bltzal  ? `BRANCH_NOT_ZERO : // 非零分支
                    2'b00; // 非分支指令
    assign Jump = j || jal ? `JUMP_INDEX : // 跳转到指定地址
                    jr || jral ? `JUMP_REG : // 跳转到寄存器地址
                    2'b00; // 非跳转指令
    assign EXTop = lui ? `EXTOP_UPPER : // 加载到高 16 位
                    addi || addiu || slti || sltiu || ori || andi || xori ? `EXTOP_ZERO :
                    // 立即数指令零扩展
                    lb || lh || lw || lbu || lhu || sb || sh || sw ? `EXTOP_SIGN :
                    // 读写内存指令符号扩展
                    `EXTOP_ZERO; // 默认零扩展，便于调试
    assign ALUop = add || addi || addu || addiu || lb || lh || lw || lbu || lhu || sb || sh || sw ? `ALUOP_ADD :
                    sub || subu || beq || bne ? `ALUOP_SUB :
                    and || andi ? `ALUOP_AND :
                    or || ori || lui ? `ALUOP_OR :
                    xor || xori ? `ALUOP_XOR :
                    nor ? `ALUOP_NOR :
                    sll || sllv ? `ALUOP_SLL :
                    srl || srlv ? `ALUOP_SRL :
                    sra || srav ? `ALUOP_SRA :
                    slt || slti || bltz || bltzal || bgez || bgezal ? `ALUOP_LT :
                    blez || bgtz ? `ALUOP_GT :
                    sltu || sltiu ? `ALUOP_LTU :
                    `ALUOP_ADD; // 默认加法，便于调试
    */
endmodule
