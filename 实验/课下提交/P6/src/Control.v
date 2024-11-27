`include "macros.v"

module Control #(
    parameter integer PIPELINE = `STAGE_DEFAULT
) (
    input wire [31:0] instr,
    output reg [`BRANCH_SIZE - 1:0] Branch,
    output reg [`JUMP_SIZE - 1:0] Jump,
    output reg CMPSrc,
    output reg [`CMPOP_SIZE - 1:0] CMPop,
    output reg [`EXTOP_SIZE - 1:0] EXTop,
    output reg [`ALUSRC_SIZE - 1:0] ALUSrc,
    output reg [`ALUOP_SIZE - 1:0] ALUop,
    output reg [`MDUOP_SIZE - 1:0] MDUop,
    output reg [`MEMWRITE_SIZE - 1:0] MemWrite,
    output reg [`DEOP_SIZE - 1:0] DEop,
    output reg [`REGSRC_SIZE - 1:0] RegSrc,
    output reg [`REGDST_SIZE - 1:0] RegDst,
    output reg [`REGWRITE_SIZE -1:0] RegWrite,
    output reg signed [`T_SIZE - 1:0] Tuse_rs,
    output reg signed [`T_SIZE - 1:0] Tuse_rt,
    output reg signed [`T_SIZE - 1:0] Tnew
);
    wire [5:0] opcode = instr[`OPCODE_MSB:`OPCODE_LSB];
    wire [5:0] funct = instr[`FUNCT_MSB:`FUNCT_LSB];
    wire [4:0] rt = instr[`RT_MSB:`RT_LSB];

    always @(*) begin
        if (opcode == 6'b000000 && funct == 6'b000000 && rt == 5'b00000) begin  // nop
            ALUSrc = `ALUSRC_IGNORE;
            RegSrc = `REGSRC_IGNORE;
            RegDst = `REGDST_IGNORE;
            RegWrite = `REGWRITE_DISABLE;
            MemWrite = `MEMWRITE_DISABLE;
            DEop = `DEOP_IGNORE;
            Branch = `BRANCH_DISABLE;
            Jump = `JUMP_DISABLE;
            EXTop = `EXTOP_IGNORE;
            ALUop = `ALUOP_IGNORE;
            MDUop = `MDUOP_NOOP;
            CMPop = `CMPOP_IGNORE;
            CMPSrc = `CMPSRC_IGNORE;
            Tuse_rs = `TUSE_IGNORE;
            Tuse_rt = `TUSE_IGNORE;
            Tnew = `TNEW_IGNORE;
        end else begin
            case (opcode)
                6'b000000: begin
                    case (funct)
                        6'b100000: begin  // add
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_ADD;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b100010: begin  // sub
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_SUB;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b100100: begin  // and
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_AND;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b100101: begin  // or
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_OR;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b101010: begin  // slt
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_LT;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b101011: begin  // sltu
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_LTU;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b011000: begin  // mult
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_MULT;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = `TNEW_IGNORE;
                        end
                        6'b011001: begin  // multu
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_MULTU;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = `TNEW_IGNORE;
                        end
                        6'b011010: begin  // div
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_DIV;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = `TNEW_IGNORE;
                        end
                        6'b011011: begin  // divu
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_DIVU;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = `TNEW_IGNORE;
                        end
                        6'b010000: begin  //mfhi
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_HI;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = `TUSE_IGNORE;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b010010: begin  //mflo
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_LO;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = `TUSE_IGNORE;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b010001: begin  // mthi
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_MTHI;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = `TNEW_IGNORE;
                        end
                        6'b010011: begin  // mtlo
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_MTLO;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = `TNEW_IGNORE;
                        end
                        6'b001000: begin  // jr
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_REG;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd0;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = `TNEW_IGNORE;
                        end
                        default: begin
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            MemWrite = `MEMWRITE_DISABLE;
                            DEop = `DEOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            MDUop = `MDUOP_NOOP;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = `TUSE_IGNORE;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = `TNEW_IGNORE;
                        end
                    endcase
                end
                6'b001000: begin  // addi
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                end
                6'b001100: begin  // andi
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_ZERO;
                    ALUop = `ALUOP_AND;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                end
                6'b001101: begin  // ori
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_ZERO;
                    ALUop = `ALUOP_OR;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                end
                6'b100000: begin  // lb
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_MEM;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_BYTE_SIGNED;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd2 :
                           PIPELINE == `STAGE_MEMORY ? 2'd1 : 2'd0;
                end
                6'b100001: begin  // lh
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_MEM;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_HALF_SIGNED;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd2 :
                           PIPELINE == `STAGE_MEMORY ? 2'd1 : 2'd0;
                end
                6'b100011: begin  // lw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_MEM;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_NOOP;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_EXECUTE ? 2'd2 :
                           PIPELINE == `STAGE_MEMORY ? 2'd1 : 2'd0;
                end
                6'b101000: begin  // sb
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_DISABLE;
                    MemWrite = `MEMWRITE_BYTE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = 2'd2;
                    Tnew = `TNEW_IGNORE;
                end
                6'b101001: begin  // sh
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_DISABLE;
                    MemWrite = `MEMWRITE_HALF;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = 2'd2;
                    Tnew = `TNEW_IGNORE;
                end
                6'b101011: begin  // sw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_DISABLE;
                    MemWrite = `MEMWRITE_WORD;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = 2'd2;
                    Tnew = `TNEW_IGNORE;
                end
                6'b000100: begin  // beq
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_IGNORE;
                    RegWrite = `REGWRITE_DISABLE;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_UNLIKELY;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_EQ;
                    CMPSrc = `CMPSRC_RT;
                    Tuse_rs = 2'd0;
                    Tuse_rt = 2'd0;
                    Tnew = `TNEW_IGNORE;
                end
                6'b000101: begin  //bne
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_IGNORE;
                    RegWrite = `REGWRITE_DISABLE;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_UNLIKELY;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_NE;
                    CMPSrc = `CMPSRC_RT;
                    Tuse_rs = 2'd0;
                    Tuse_rt = 2'd0;
                    Tnew = `TNEW_IGNORE;
                end
                6'b001111: begin  // lui
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_UPPER;
                    ALUop = `ALUOP_OR;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = 2'd0;
                end
                6'b000011: begin  // jal
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_PC8;
                    RegDst = `REGDST_RA;
                    RegWrite = `REGWRITE_UNCOND;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_INDEX;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = `TUSE_IGNORE;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = 2'd0;
                end
                default: begin
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_IGNORE;
                    RegWrite = `REGWRITE_DISABLE;
                    MemWrite = `MEMWRITE_DISABLE;
                    DEop = `DEOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    MDUop = `MDUOP_NOOP;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = `TUSE_IGNORE;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = `TNEW_IGNORE;
                end
            endcase
        end
    end
endmodule
