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
    wire [4:0] rs_base = instruction[25:21], rt = instruction[20:16], rd = instruction[15:11],
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
    wire [2:0] CMPop;
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
        .ALUop(ALUop),
        .CMPop(CMPop)
    );

    wire [31:0] rs_base_data, rt_data;
    reg [31:0] REG_write_data;
    reg [ 4:0] REG_write_number;
    always @(*) begin
        case (RegSrc)
            `REGSRC_ALU: begin
                REG_write_data = ALU_result;
            end
            `REGSRC_MEM: begin
                REG_write_data = MEM_read_data;
            end
            `REGSRC_PC: begin
                REG_write_data = PC + 32'd4;
            end
            default REG_write_data = 32'hffffffff;
        endcase
        case (RegDst)
            `REGDST_RT: begin
                REG_write_number = rt;
            end
            `REGDST_RD: begin
                REG_write_number = rd;
            end
            `REGDST_RA: begin
                REG_write_number = 5'd31;
            end
            default REG_write_number = 5'h1f;
        endcase
    end
    GRF grf (
        .clk(clk),
        .reset(reset),
        .read_number1(rs_base),
        .read_number2(rt),
        .write_number(REG_write_number),
        .write_enable(Branch == `BRANCH_LINK ? CMP_result : RegWrite),
        .write_data(REG_write_data),
        .PC(PC),
        .read_data1(rs_base_data),
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
    always @(*) begin
        case (ALUSrc[0])
            `ALUSRC1_RS: begin
                ALUoperand1 = rs_base_data;
            end
            `ALUSRC1_RT: begin
                ALUoperand1 = rt_data;
            end
            default ALUoperand1 = 32'hffffffff;
        endcase
        case (ALUSrc[3:1])
            `ALUSRC2_RT: begin
                ALUoperand2 = rt_data;
            end
            `ALUSRC2_IMM_SHAMT: begin
                ALUoperand2 = EXT_result;
            end
            `ALUSRC2_ZERO: begin
                ALUoperand2 = 32'd0;
            end
            `ALUSRC2_S: begin
                ALUoperand2 = {27'd0, s};
            end
            `ALUSRC2_RS: begin
                ALUoperand2 = rs_base_data;
            end
            default ALUoperand2 = 32'hffffffff;
        endcase
    end
    ALU alu (
        .operand1(ALUoperand1),
        .operand2(ALUoperand2),
        .operation(ALUop),
        .result(ALU_result)
    );

    wire CMP_result;
    CMP cmp (
        .operand1(rs_base_data),
        .operand2(rt_data),
        .operation(CMPop),
        .result(CMP_result)
    );

    wire [31:0] MEM_read_data_raw;
    reg [31:0] MEM_read_data, MEM_write_data;
    always @(*) begin
        case (MemSrc)
            `MEMSRC_BYTE: begin
                case (ALU_result[1:0])
                    2'b00: MEM_write_data = {MEM_read_data_raw[31:8], rt_data[7:0]};
                    2'b01:
                    MEM_write_data = {
                        MEM_read_data_raw[31:16], rt_data[7:0], MEM_read_data_raw[7:0]
                    };
                    2'b10:
                    MEM_write_data = {
                        MEM_read_data_raw[31:24], rt_data[7:0], MEM_read_data_raw[15:0]
                    };
                    2'b11: MEM_write_data = {rt_data[7:0], MEM_read_data_raw[23:0]};
                    default MEM_write_data = 32'hffffffff;
                endcase
            end
            `MEMSRC_HALF: begin
                case (ALU_result[1:0])
                    2'b00: MEM_write_data = {MEM_read_data_raw[31:16], rt_data[15:0]};
                    2'b10: MEM_write_data = {rt_data[15:0], MEM_read_data_raw[15:0]};
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
                case (ALU_result[1:0])
                    2'b00: MEM_read_data = {{24{MEM_read_data_raw[7]}}, MEM_read_data_raw[7:0]};
                    2'b01: MEM_read_data = {{24{MEM_read_data_raw[15]}}, MEM_read_data_raw[15:8]};
                    2'b10: MEM_read_data = {{24{MEM_read_data_raw[23]}}, MEM_read_data_raw[23:16]};
                    2'b11: MEM_read_data = {{24{MEM_read_data_raw[31]}}, MEM_read_data_raw[31:24]};
                    default MEM_read_data = 32'hffffffff;
                endcase
            end
            `MEMDST_HALF: begin
                case (ALU_result[1:0])
                    2'b00: MEM_read_data = {{16{MEM_read_data_raw[15]}}, MEM_read_data_raw[15:0]};
                    2'b10: MEM_read_data = {{16{MEM_read_data_raw[31]}}, MEM_read_data_raw[31:16]};
                    default MEM_read_data = 32'hffffffff;
                endcase
            end
            `MEMDST_WORD: begin
                MEM_read_data = MEM_read_data_raw;
            end
            `MEMDST_BYTEU: begin
                case (ALU_result[1:0])
                    2'b00: MEM_read_data = {24'd0, MEM_read_data_raw[7:0]};
                    2'b01: MEM_read_data = {24'd0, MEM_read_data_raw[15:8]};
                    2'b10: MEM_read_data = {24'd0, MEM_read_data_raw[23:16]};
                    2'b11: MEM_read_data = {24'd0, MEM_read_data_raw[31:24]};
                    default MEM_read_data = 32'hffffffff;
                endcase
            end
            `MEMDST_HALFU: begin
                case (ALU_result[1:0])
                    2'b00: MEM_read_data = {16'd0, MEM_read_data_raw[15:0]};
                    2'b10: MEM_read_data = {16'd0, MEM_read_data_raw[31:16]};
                    default MEM_read_data = 32'hffffffff;
                endcase
            end
            default MEM_read_data = 32'hffffffff;
        endcase
    end
    DM dm (
        .clk(clk),
        .reset(reset),
        .ADDR(ALU_result),
        .write_data(MEM_write_data),
        .write_enable(MemWrite),
`ifdef DEBUG
        .PC(PC),
`endif
        .read_data(MEM_read_data_raw)
    );

    wire [31:0] next_PC;
    NPC npc (
        .PC(PC),
        .offset(immediate_offset),
        .instr_index(instr_index),
        .regester(rs_base_data),
        .branch(Branch && CMP_result),
        .jump(Jump),
        .next_PC(next_PC)
    );
endmodule
