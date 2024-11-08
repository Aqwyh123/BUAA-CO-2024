`include "macros.v"

module mips (
    input wire clk,
    input wire reset
);
    HazardControl hazard_control (
        .D_rs_base(D_rs_base),
        .D_rt(D_rt),
        .E_rs_base(E_rs_base),
        .E_rt(E_rt),
        .M_rs_base(M_rs_base),
        .M_rt(M_rt),
        .D_REG_write_number(D_REG_write_number),
        .E_REG_write_number(E_REG_write_number),
        .M_REG_write_number(M_REG_write_number),
        .D_T_use_rs_base(D_T_use_rs_base),
        .D_T_use_rt(D_T_use_rt),
        .D_T_new(D_T_new),
        .E_T_use_rs_base(E_T_use_rs_base),
        .E_T_use_rt(E_T_use_rt),
        .E_T_new(E_T_new),
        .M_T_use_rs_base(M_T_use_rs_base),
        .M_T_use_rt(M_T_use_rt),
        .M_T_new(M_T_new),
        .stall(stall)
    );

    // 取指阶段 Fetch 开始
    IFU F_ifu (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_PC(D_next_PC),
        .PC(F_PC),
        .instruction(F_instruction)
    );
    wire [31:0] F_PC, F_instruction;
    // 取指阶段 Fetch 结束

    FD_REG fd_reg (  // FD 流水线寄存器
        .clk(clk),
        .reset(reset),
        .F_PC(F_PC),
        .F_instruction(F_instruction),
        .D_PC(D_PC),
        .D_instruction(D_instruction)
    );
    wire [31:0] D_PC, D_instruction;

    // 译码阶段 Decode 开始
    wire [ 4:0] D_rs_base = D_instruction[25:21], D_rt = D_instruction[20:16], D_rd = D_instruction[15:11];
    wire [15:0] D_immediate_offset = D_instruction[15:0];
    wire [25:0] D_instr_index_offset = D_instruction[25:0];

    Control #(`STAGE_DECODE) D_control (  // D 控制器
        .instruction(D_instruction),
        .RegDst(D_RegDst),
        .Branch(D_Branch),
        .Jump(D_Jump),
        .EXTop(D_EXTop),
        .CMPSrc(D_CMPSrc),
        .CMPop(D_CMPop),
        .T_use_rs_base(D_T_use_rs_base),
        .T_use_rt(D_T_use_rt),
        .T_new(D_T_new)
    );
    wire [1:0] D_RegDst;
    wire [1:0] D_Branch;
    wire [1:0] D_Jump;
    wire [1:0] D_EXTop;
    wire D_CMPSrc;
    wire [2:0] D_CMPop;
    wire [1:0] D_T_use_rs_base, D_T_use_rt, D_T_new;

    always @(*) begin
        case (D_RegDst)
            `REGDST_RT: begin
                D_REG_write_number = D_rt;
            end
            `REGDST_RD: begin
                D_REG_write_number = D_rd;
            end
            `REGDST_RA: begin
                D_REG_write_number = 5'd31;
            end
            default D_REG_write_number = 5'h1f;
        endcase
    end
    reg [4:0] D_REG_write_number;

    // 写回阶段 Writeback 继续
    GRF DW_grf (
        .clk(clk),
        .reset(reset),
        .read_number1(D_rs_base),
        .read_number2(D_rt),
        .write_number(W_REG_write_number),
        .write_enable(W_Branch != `BRANCH_COND_LINK ? W_RegWrite : W_CMP_result),
        .write_data(W_REG_write_data),
`ifdef DEBUG
        .PC(PC),
`endif
        .read_data1(D_rs_base_data),
        .read_data2(D_rt_data)
    );
    wire [31:0] D_rs_base_data, D_rt_data;
    // 写回阶段 Writeback 结束

    EXT D_ext (
        .operand(D_immediate_offset),
        .operation(D_EXTop),
        .result(D_EXT_result)
    );
    wire [31:0] D_EXT_result;


    CMP D_cmp (
        .operand1(D_rs_base_data),
        .operand2(D_CMPSrc == `CMPSRC_RT ? D_rt_data : 32'd0),
        .operation(D_CMPop),
        .result(D_CMP_result)
    );
    wire D_CMP_result;

    NPC D_npc (
        .PC(D_PC),
        .instr_index_offset(D_instr_index_offset),
        .regester(D_rs_base_data),
        .branch(D_Branch && D_CMP_result),
        .jump(D_Jump),
        .next_PC(D_next_PC)
    );
    wire [31:0] D_next_PC;
    // 译码阶段 Decode 结束

    DE_REG de_reg (  // DE 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .D_PC(D_PC),
        .D_instruction(D_instruction),
        .D_rs_base_data(D_rs_base_data),
        .D_rt_data(D_rt_data),
        .D_REG_write_number(D_REG_write_number),
        .D_EXT_result(D_EXT_result),
        .D_CMP_result(D_CMP_result),
        .E_PC(E_PC),
        .E_instruction(E_instruction),
        .E_rs_base_data(E_rs_base_data),
        .E_rt_data(E_rt_data),
        .E_REG_write_number(E_REG_write_number),
        .E_EXT_result(E_EXT_result),
        .E_CMP_result(E_CMP_result)
    );
    wire [31:0] E_PC, E_instruction, E_rs_base_data, E_rt_data, E_EXT_result;
    wire [4:0] E_REG_write_number;
    wire E_CMP_result;

    // 执行阶段 Execute 开始
    wire [4:0] E_rs_base = E_instruction[25:21], E_rt = E_instruction[20:16],E_shamt = E_instruction[10:6];

    Contorl #(`STAGE_EXECUTE) E_control (  // E 控制器
        .instruction(E_instruction),
        .ALUSrc(E_ALUSrc),
        .ALUop(E_ALUop),
        .T_use_rs_base(E_T_use_rs_base),
        .T_use_rt(E_T_use_rt),
        .T_new(E_T_new)
    );
    wire [2:0] E_ALUSrc;
    wire [3:0] E_ALUop;
    wire [1:0] E_T_use_rs_base, E_T_use_rt, E_T_new;

    always @(*) begin
        case (E_ALUSrc[0])
            `ALUSRC1_RS: begin
                E_ALUoperand1 = E_rs_base_data;
            end
            `ALUSRC1_RT: begin
                E_ALUoperand1 = E_rt_data;
            end
            default E_ALUoperand1 = 32'hffffffff;
        endcase
        case (E_ALUSrc[2:1])
            `ALUSRC2_RT: begin
                E_ALUoperand2 = E_rt_data;
            end
            `ALUSRC2_IMM_SHAMT: begin
                E_ALUoperand2 = E_EXT_result;
            end
            `ALUSRC2_S: begin
                E_ALUoperand2 = {27'd0, E_shamt};
            end
            `ALUSRC2_RS: begin
                E_ALUoperand2 = E_rs_base_data;
            end
            default E_ALUoperand2 = 32'hffffffff;
        endcase
    end
    reg [31:0] E_ALUoperand1, E_ALUoperand2;
    ALU E_alu (
        .operand1(E_ALUoperand1),
        .operand2(E_ALUoperand2),
        .operation(E_ALUop),
        .result(E_ALU_result)
    );
    wire [31:0] E_ALU_result;
    // 执行阶段 Execute 结束

    EM_REG em_reg (  // EM 流水线寄存器
        .clk(clk),
        .reset(reset),
        .flush(stall),
        .E_PC(E_PC),
        .E_instruction(E_instruction),
        .E_rt_data(E_rt_data),
        .E_REG_write_number(E_REG_write_number),
        .E_CMP_result(E_CMP_result),
        .E_ALU_result(E_ALU_result),
        .M_PC(M_PC),
        .M_instruction(M_instruction),
        .M_rt_data(M_rt_data),
        .M_REG_write_number(M_REG_write_number),
        .M_CMP_result(M_CMP_result),
        .M_ALU_result(M_ALU_result)
    );
    wire [31:0] M_PC, M_instruction, M_rt_data, M_ALU_result;
    wire [4:0] M_REG_write_number;
    wire M_CMP_result;

    // 访存阶段 Memory 开始
    wire [4:0] M_rs_base = M_instruction[25:21], M_rt = M_instruction[20:16];

    Contorl #(`STAGE_MEMORY) M_control (  // M 控制器
        .instruction(M_instruction),
        .DMop(M_DMop)
    );

    DM M_dm (
        .clk(clk),
        .reset(reset),
        .ADDR(M_ALU_result),
        .write_data_raw(M_rt_data),
        .operation(M_DMop),
`ifdef DEBUG
        .PC(M_PC),
`endif
        .read_data(MEM_read_data)
    );
    wire [31:0] M_MEM_read_data;
    // 访存阶段 Memory 结束

    MW_REG mw_reg (  // MW 流水线寄存器
        .clk(clk),
        .reset(reset),
        .M_PC(M_PC),
        .M_instruction(M_instruction),
        .M_REG_write_number(M_REG_write_number),
        .M_CMP_result(M_CMP_result),
        .M_ALU_result(M_ALU_result),
        .MEM_read_data(M_MEM_read_data),
        .W_PC(W_PC),
        .W_instruction(W_instruction),
        .W_REG_write_number(W_REG_write_number),
        .W_CMP_result(W_CMP_result),
        .W_ALU_result(W_ALU_result),
        .W_MEM_read_data(W_MEM_read_data)
    );
    wire [31:0] W_PC, W_instruction, W_MEM_read_data, W_ALU_result;
    wire [4:0] W_REG_write_number;
    wire W_CMP_result;

    // 写回阶段 Writeback 开始
    wire [4:0] W_rt = W_instruction[20:16], W_rd = W_instruction[15:11];

    Contorl #(`STAGE_WRITEBACK) W_control (  // W 控制器
        .instruction(W_instruction),
        .RegDst(W_RegDst),
        .RegSrc(W_RegSrc),
        .RegWrite(W_RegWrite),
        .Branch(W_Branch),
        .T_use_rs_base(W_T_use_rs_base),
        .T_use_rt(W_T_use_rt),
        .T_new(W_T_new)
    );
    wire [1:0] W_RegDst, W_RegSrc;
    wire W_RegWrite, W_Branch;
    wire [1:0] W_T_use_rs_base, W_T_use_rt, W_T_new;

    always @(*) begin
        case (W_RegSrc)
            `REGSRC_ALU: begin
                W_REG_write_data = W_ALU_result;
            end
            `REGSRC_MEM: begin
                W_REG_write_data = W_MEM_read_data;
            end
            `REGSRC_PC: begin
                W_REG_write_data = W_PC + 32'd8;
            end
            default W_REG_write_data = 32'hffffffff;
        endcase
    end
    reg [31:0] W_REG_write_data;
    // 写回阶段 Writeback 继续
endmodule
