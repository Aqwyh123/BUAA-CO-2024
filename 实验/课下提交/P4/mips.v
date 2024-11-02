`include "macros.v"
module mips (
    input wire clk,
    input wire reset
);

    wire [31:0] PC, instruction;
    IFU ifu (
        .clk(clk),
        .reset(reset),
        .next_PC(next_PC),
`ifdef DEBUG
        .PC(PC),
`endif
        .instruction(instruction)
    );
    wire [5:0] opcode = instruction[31:26], funct = instruction[5:0];
    wire [4:0] rs = instruction[25:21], rt = instruction[20:16], rd = instruction[15:11],
    s = instruction[10:6];
    wire [15:0] immediate_offset = instruction[15:0];
    wire [25:0] instr_index = instruction[25:0];

    wire [3:0] ALUSrc;
    wire [1:0] RegSrc;
    wire [1:0] RegDst;
    wire RegWrite;
    wire [1:0] MemSrc;
    wire [2:0] MemDst;
    wire MemWrite;
    wire [1:0] Branch;
    wire [1:0] Jump;
    wire [1:0] EXTop;
    wire [3:0] ALUop;
    Control control (
        .opcode(opcode),
        .funct(funct),
        .rt(rt),
        .ALUSrc(ALUSrc),
        .RegSrc(RegSrc),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .MemSrc(MemSrc),
        .MemDst(MemDst),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Jump(Jump),
        .EXTop(EXTop),
        .ALUop(ALUop)
    );

    wire [31:0] rs_data, rt_data;
    reg [31:0] REG_write_data;
    reg [ 4:0] write_REG;
    always @(*) begin
        case (RegSrc)
            `REGSRC_ALU: begin
                REG_write_data = ALU_result;
            end
            `REGSRC_MEM: begin
                REG_write_data = MEM_data;
            end
            `REGSRC_PC: begin
                REG_write_data = PC + 32'd4;
            end
            default REG_write_data = 32'hffffffff;
        endcase
        case (RegDst)
            `REGDST_RT: begin
                write_REG = rt;
            end
            `REGDST_RD: begin
                write_REG = rd;
            end
            `REGDST_RA: begin
                write_REG = 5'd31;
            end
            default write_REG = 5'h1f;
        endcase
    end
    GRF grf (
        .clk(clk),
        .reset(reset),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_REG),
        .write_enable(RegWrite),
        .write_data(REG_write_data),
        .PC(PC),
        .read_data1(rs_data),
        .read_data2(rt_data)
    );

    wire [31:0] EXT_result;
    EXT ext (
        .operand(immediate_offset),
        .operation(EXTop),
        .result(EXT_result)
    );

    reg [31:0] ALUoperand1, ALUoperand2;
    wire [31:0] ALU_result;
    wire ALU_zero;
    always @(*) begin
        case (ALUSrc[0])
            `ALUSRC1_RS: begin
                ALUoperand1 = rs_data;
            end
            `ALUSRC1_RT: begin
                ALUoperand1 = rt_data;
            end
            default ALUoperand1 = 32'hffffffff;
        endcase
        case (ALUSrc[2:1])
            `ALUSRC2_RT: begin
                ALUoperand2 = rt_data;
            end
            `ALUSRC2_IMM_SHAMT: begin
                ALUoperand2 = EXT_result;
            end
            `ALUSRC2_ZERO: begin
                ALUoperand2 = 32'b0;
            end
            `ALUSRC2_S: begin
                ALUoperand2 = {27'b0, s};
            end
            `ALUSRC2_RS: begin
                ALUoperand2 = rs_data;
            end
            default ALUoperand2 = 32'hffffffff;
        endcase
    end
    ALU alu (
        .operand1(ALUoperand1),
        .operand2(ALUoperand2),
        .operation(ALUop),
        .result(ALU_result),
        .zero(ALU_zero)
    );

    wire [31:0] MEM_raw_data;
    reg [31:0] MEM_data, MEM_write_data;
    always @(*) begin
        case (MemSrc)
            `MEMSRC_BYTE: begin
                case (ALU_result[1:0])
                    2'b00: MEM_write_data = {MEM_raw_data[31:8], rt_data[7:0]};
                    2'b01: MEM_write_data = {MEM_raw_data[31:16], rt_data[7:0], MEM_raw_data[7:0]};
                    2'b10: MEM_write_data = {MEM_raw_data[31:24], rt_data[7:0], MEM_raw_data[15:0]};
                    2'b11: MEM_write_data = {rt_data[7:0], MEM_raw_data[23:0]};
                    default MEM_write_data = 32'hffffffff;
                endcase
            end
            `MEMSRC_HALF: begin
                case (ALU_result[1:0])
                    2'b00: MEM_write_data = {MEM_raw_data[31:16], rt_data[15:0]};
                    2'b10: MEM_write_data = {rt_data[15:0], MEM_raw_data[15:0]};
                    default MEM_write_data = 32'hffffffff;
                endcase
            end
            `MEMSRC_WORD: begin
                MEM_write_data = rt_data;
            end
            default MEM_write_data = 32'hffffffff;
        endcase
        case (MemDst)
            `MEMDST_BYTE: begin
                MEM_data = {{24{MEM_raw_data[7]}}, MEM_raw_data[7:0]};
            end
            `MEMDST_HALF: begin
                MEM_data = {{16{MEM_raw_data[15]}}, MEM_raw_data[15:0]};
            end
            `MEMDST_WORD: begin
                MEM_data = MEM_raw_data;
            end
            `MEMDST_BYTEU: begin
                MEM_data = {24'b0, MEM_raw_data[7:0]};
            end
            `MEMDST_HALFU: begin
                MEM_data = {16'b0, MEM_raw_data[15:0]};
            end
            default MEM_data = 32'hffffffff;
        endcase
    end
    DM dm (
        .clk(clk),
        .reset(reset),
        .ADDR(ALU_result),
        .data_in(MEM_write_data),
        .write_enable(MemWrite),
`ifdef DEBUG
        .PC(PC),
`endif
        .data_out(MEM_raw_data)
    );

    wire [31:0] next_PC;
    NPC npc (
        .PC(PC),
        .offset(immediate_offset),
        .instr_index(instr_index),
        .regester(rs_data),
        .ALU_zero(ALU_zero),
        .branch(Branch),
        .jump(Jump),
        .next_PC(next_PC)
    );

endmodule
