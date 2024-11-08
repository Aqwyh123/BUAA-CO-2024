`include "macros.v"

module Control #(
    parameter PIPELINE = `STAGE_DEFAULT
) (
    input wire [31:0] instruction,
    output reg [1:0] Branch,
    output reg [1:0] Jump,
    output reg CMPSrc,
    output reg [2:0] CMPop,
    output reg [1:0] EXTop,
    output reg [2:0] ALUSrc,
    output reg [3:0] ALUop,
    output reg [3:0] DMop,
    output reg [1:0] RegSrc,
    output reg [1:0] RegDst,
    output reg RegWrite,
    output reg [1:0] T_use_rs_base,
    output reg [1:0] T_use_rt,
    output reg [1:0] T_new
);
    wire [5:0] opcode = instruction[`OPCODE_MSB:`OPCODE_LSB];
    wire [5:0] funct = instruction[`FUNCT_MSB:`FUNCT_LSB];
    wire [4:0] rt = instruction[`RT_MSB:`RT_LSB];

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
            T_use_rs_base = `T_USE_IGNORE;
            T_use_rt = `T_USE_IGNORE;
            T_new = `T_NEW_IGNORE;
        end else begin
            case (opcode)
                6'b000000: begin
                    case (funct)
                        6'b100000: begin  // add
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_ENABLE;
                            DMop = `DMOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_ADD;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            T_use_rs_base = 2'd1;
                            T_use_rt = 2'd1;
                            T_new = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                        end
                        6'b100010: begin  // sub
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = `REGWRITE_ENABLE;
                            DMop = `DMOP_IGNORE;
                            Branch = `BRANCH_DISABLE;
                            Jump = `JUMP_DISABLE;
                            EXTop = `EXTOP_IGNORE;
                            ALUop = `ALUOP_SUB;
                            CMPop = `CMPOP_IGNORE;
                            CMPSrc = `CMPSRC_IGNORE;
                            T_use_rs_base = 2'd1;
                            T_use_rt = 2'd1;
                            T_new = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
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
                            T_use_rs_base = `T_USE_IGNORE;
                            T_use_rt = `T_USE_IGNORE;
                            T_new = `T_NEW_IGNORE;
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
                            T_use_rs_base = `T_USE_IGNORE;
                            T_use_rt = `T_USE_IGNORE;
                            T_new = `T_NEW_IGNORE;
                        end
                    endcase
                end
                6'b001101: begin  // ori
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_ENABLE;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_ZERO;
                    ALUop = `ALUOP_OR;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    T_use_rs_base = 2'd1;
                    T_use_rt = `T_USE_IGNORE;
                    T_new = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                end
                6'b100011: begin  // lw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_MEM;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_ENABLE;
                    DMop = {`DMOP_WORD, `MEMREAD};
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    T_use_rs_base = 2'd1;
                    T_use_rt = `T_USE_IGNORE;
                    T_new = PIPELINE == `STAGE_EXECUTE ? 2'd2 : PIPELINE == `STAGE_MEMORY ? 2'd1 : 2'd0;
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
                    T_use_rs_base = 2'd1;
                    T_use_rt = 2'd2;
                    T_new = `T_NEW_IGNORE;
                end
                6'b000100: begin  // beq
                    ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_IGNORE;
                    RegDst = `REGDST_IGNORE;
                    RegWrite = `REGWRITE_DISABLE;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_COND;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    CMPop = `CMPOP_EQ;
                    CMPSrc = `CMPSRC_RT;
                    T_use_rs_base = `T_USE_IGNORE;
                    T_use_rt = `T_USE_IGNORE;
                    T_new = `T_NEW_IGNORE;
                end
                6'b001111: begin  // lui
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = `REGWRITE_ENABLE;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_DISABLE;
                    EXTop = `EXTOP_UPPER;
                    ALUop = `ALUOP_OR;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    T_use_rs_base = 2'd1;
                    T_use_rt = `T_USE_IGNORE;
                    T_new = PIPELINE == `STAGE_EXECUTE ? 2'd1 : 2'd0;
                end
                6'b000011: begin  // jal
                    ALUSrc = `ALUSRC_IGNORE;
                    RegSrc = `REGSRC_PC;
                    RegDst = `REGDST_RA;
                    RegWrite = `REGWRITE_ENABLE;
                    DMop = `DMOP_IGNORE;
                    Branch = `BRANCH_DISABLE;
                    Jump = `JUMP_INDEX;
                    EXTop = `EXTOP_IGNORE;
                    ALUop = `ALUOP_IGNORE;
                    CMPop = `CMPOP_IGNORE;
                    CMPSrc = `CMPSRC_IGNORE;
                    T_use_rs_base = `T_USE_IGNORE;
                    T_use_rt = `T_USE_IGNORE;
                    T_new = `T_NEW_IGNORE;
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
                    T_use_rs_base = `T_USE_IGNORE;
                    T_use_rt = `T_USE_IGNORE;
                    T_new = `T_NEW_IGNORE;
                end
            endcase
        end
    end
endmodule
