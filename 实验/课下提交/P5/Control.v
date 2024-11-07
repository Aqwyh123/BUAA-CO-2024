`include "macros.v"
module Control (
    input wire [5:0] opcode,
    input wire [5:0] funct,
    input wire [4:0] rt,
    output reg [3:0] ALUSrc,
    output reg [1:0] RegSrc,
    output reg [1:0] RegDst,
    output reg RegWrite,
    output reg [3:0] DMop,
    output reg [1:0] Branch,
    output reg [1:0] Jump,
    output reg [1:0] EXTop,
    output reg [3:0] ALUop,
    output reg [2:0] CMPop
);
    always @(*) begin
        if (opcode == 6'b000000 && funct == 6'b000000 && rt == 5'b00000) begin  // nop
            ALUSrc = 4'b0000;
            RegSrc = 3'b000;
            RegDst = 2'b00;
            RegWrite = 1'b0;
            DMop = 4'b0000;
            Branch = 2'b00;
            Jump = 2'b00;
            EXTop = 2'b00;
            ALUop = 4'b0000;
            CMPop = 2'b00;
        end else begin
            case (opcode)
                6'b000000: begin
                    case (funct)
                        6'b100000: begin  // add
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = 1'b1;
                            DMop = 4'b0000;
                            Branch = 2'b00;
                            Jump = 2'b00;
                            EXTop = 2'b00;
                            ALUop = `ALUOP_ADD;
                            CMPop = 2'b00;
                        end
                        6'b100010: begin  // sub
                            ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                            RegSrc = `REGSRC_ALU;
                            RegDst = `REGDST_RD;
                            RegWrite = 1'b1;
                            DMop = 4'b0000;
                            Branch = 2'b00;
                            Jump = 2'b00;
                            EXTop = 2'b00;
                            ALUop = `ALUOP_SUB;
                            CMPop = 2'b00;
                        end
                        6'b001000: begin  // jr
                            ALUSrc = 4'b0000;
                            RegSrc = 3'b000;
                            RegDst = 2'b00;
                            RegWrite = 1'b0;
                            DMop = 4'b0000;
                            Branch = 2'b00;
                            Jump = `JUMP_REG;
                            EXTop = 2'b00;
                            ALUop = 4'b0000;
                            CMPop = 2'b00;
                        end
                        default: begin
                            ALUSrc = 4'b0000;
                            RegSrc = 2'b00;
                            RegDst = 2'b00;
                            RegWrite = 1'b0;
                            DMop = 4'b0000;
                            Branch = 2'b00;
                            Jump = 2'b00;
                            EXTop = 2'b00;
                            ALUop = 4'b0000;
                            CMPop = 2'b00;
                        end
                    endcase
                end
                6'b001101: begin  // ori
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = 1'b1;
                    DMop = 4'b0000;
                    Branch = 2'b00;
                    Jump = 2'b00;
                    EXTop = `EXTOP_ZERO;
                    ALUop = `ALUOP_OR;
                    CMPop = 2'b00;
                end
                6'b100011: begin  // lw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_MEM;
                    RegDst = `REGDST_RT;
                    RegWrite = 1'b1;
                    DMop = {`DMOP_WORD, 1'b0};
                    Branch = 2'b00;
                    Jump = 2'b00;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    CMPop = 2'b00;
                end
                6'b101011: begin  // sw
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = 2'b00;
                    RegDst = `REGDST_RT;
                    RegWrite = 1'b0;
                    DMop = {`DMOP_WORD, 1'b1};
                    Branch = 2'b00;
                    Jump = 2'b00;
                    EXTop = `EXTOP_SIGN;
                    ALUop = `ALUOP_ADD;
                    CMPop = 2'b00;
                end
                6'b000100: begin  // beq
                    ALUSrc = {`ALUSRC2_RT, `ALUSRC1_RS};
                    RegSrc = 3'b000;
                    RegDst = 2'b00;
                    RegWrite = 1'b0;
                    DMop = 4'b0000;
                    Branch = `BRANCH;
                    Jump = 2'b00;
                    EXTop = 2'b00;
                    ALUop = 4'b0000;
                    CMPop = `CMPOP_EQ;
                end
                6'b001111: begin  // lui
                    ALUSrc = {`ALUSRC2_IMM_SHAMT, `ALUSRC1_RS};
                    RegSrc = `REGSRC_ALU;
                    RegDst = `REGDST_RT;
                    RegWrite = 1'b1;
                    DMop = 4'b0000;
                    Branch = 2'b00;
                    Jump = 2'b00;
                    EXTop = `EXTOP_UPPER;
                    ALUop = `ALUOP_OR;
                    CMPop = 2'b00;
                end
                6'b000011: begin  // jal
                    ALUSrc = 4'b0000;
                    RegSrc = `REGSRC_PC;
                    RegDst = `REGDST_RA;
                    RegWrite = 1'b1;
                    DMop = 4'b0000;
                    Branch = 2'b00;
                    Jump = `JUMP_INDEX;
                    EXTop = 2'b00;
                    ALUop = 4'b0000;
                    CMPop = 2'b00;
                end
                default: begin
                    ALUSrc = 4'b0000;
                    RegSrc = 2'b00;
                    RegDst = 2'b00;
                    RegWrite = 1'b0;
                    DMop = 4'b0000;
                    Branch = 2'b00;
                    Jump = 2'b00;
                    EXTop = 2'b00;
                    ALUop = 4'b0000;
                    CMPop = 2'b00;
                end
            endcase
        end
    end
endmodule
