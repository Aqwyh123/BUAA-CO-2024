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
    output reg [`DMOP_SIZE - 1:0] DMop,
    output reg [`REGSRC_SIZE - 1:0] RegSrc,
    output reg [`REGDST_SIZE - 1:0] RegDst,
    output reg [`REGWRITE_SIZE -1:0]RegWrite,
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
            DMop = `DMOP_IGNORE;
            Branch = `BRANCH_DISABLE;
            Jump = `JUMP_DISABLE;
            EXTop = `EXTOP_IGNORE;
            ALUop = `ALUOP_IGNORE;
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
                            DMop = `DMOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_ADD;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_DECODE ? 2'd2 :
                                   PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b100010: begin  // sub
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_UNCOND;
                            DMop = `DMOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_SUB;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = 2'd1;
                            Tuse_rt = 2'd1;
                            Tnew = PIPELINE == `STAGE_DECODE ? 2'd2 :
                                   PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b001000: begin  // jr
                            ALUSrc = `ALUSRC_IGNORE;
                            RegSrc = `REGSRC_IGNORE;
                            RegDst = `REGDST_IGNORE;
                            RegWrite = `REGWRITE_DISABLE;
                            DMop = `DMOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_REG;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
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
                            DMop = `DMOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_IGNORE;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            Tuse_rs = `TUSE_IGNORE;
                            Tuse_rt = `TUSE_IGNORE;
                            Tnew = `TNEW_IGNORE;
                        end
                    endcase
                end
                6'b001101: begin  // ori
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_ZERO;
                    ALUop = `ALUOP_OR;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_DECODE ? 2'd2 :
                           PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                end
                6'b100011: begin  // lw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_MEM;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_UNCOND;
                    DMop = {`DMOP_WORD, `MEMREAD};
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_DECODE ? 2'd3:
                           PIPELINE == `STAGE_EXECUTE ? 2'd2 :
                           PIPELINE == `STAGE_MEMORY ? 2'd1 : 2'd0;
                end
                6'b101011: begin  // sw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_DISABLE;
                    DMop = {`DMOP_WORD, `MEMWRITE};
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
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
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_UNLIKELY;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    CMPop = `CMPOP_EQ;
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
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_UPPER;
                    ALUop = `ALUOP_OR;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = 2'd1;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_DECODE ? 2'd1 : 2'd0;
                end
                6'b000011: begin  // jal
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_PC;
                    RegDst = `REGDST_RA;
                    RegWrite = `REGWRITE_UNCOND;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_INDEX;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    Tuse_rs = `TUSE_IGNORE;
                    Tuse_rt = `TUSE_IGNORE;
                    Tnew = PIPELINE == `STAGE_DECODE ? 2'd1 : 2'd0;
                end
                default: begin
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_IGNORE;
                    RegWrite = `REGWRITE_DISABLE;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
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
