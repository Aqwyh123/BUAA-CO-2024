`include "macros.v"

module mips (
    input wire clk,
    input wire reset
);
    wire [31:0] F_PC, D_PC, E_PC8, M_PC8, W_PC8;
    wire [31:0] F_instr, D_instr, E_instr, M_instr, W_instr;
    wire [4:0] D_rs = D_instr[25:21], D_rt = D_instr[20:16], D_rd = D_instr[15:11];
    wire [4:0] E_rs = E_instr[25:21], E_rt = E_instr[20:16], E_rd = E_instr[15:11];
    wire [4:0] M_rs = M_instr[25:21], M_rt = M_instr[20:16], M_rd = M_instr[15:11];
    wire [4:0] W_rs = W_instr[25:21], W_rt = W_instr[20:16], W_rd = W_instr[15:11];
    reg [4:0] E_REG_write_number, M_REG_write_number, W_REG_write_number;
    wire E_RegWrite, M_RegWrite, W_RegWrite;
    wire signed [`T_SIZE - 1:0] D_Tuse_rs, D_Tuse_rt,
                                E_Tuse_rs, E_Tuse_rt,
                                M_Tuse_rs, M_Tuse_rt,
                                W_Tuse_rs, W_Tuse_rt;
    wire signed [`T_SIZE - 1:0] E_Tnew, M_Tnew, W_Tnew;
`ifdef DEBUG
`ifdef LOCAL
    wire [31:0] E_PC = E_PC8 >= 32'h00003008 ? E_PC8 - 32'd8 : 32'h00000000;
    wire [31:0] M_PC = M_PC8 >= 32'h00003008 ? M_PC8 - 32'd8 : 32'h00000000;
    wire [31:0] W_PC = W_PC8 >= 32'h00003008 ? W_PC8 - 32'd8 : 32'h00000000;
`endif
`endif

    HazardControl hazard_control (
        .D_rs(D_rs),
        .D_rt(D_rt),
        .D_Tuse_rs(D_Tuse_rs),
        .D_Tuse_rt(D_Tuse_rt),
        .E_rs(E_rs),
        .E_rt(E_rt),
        .E_REG_write_number(E_REG_write_number),
        .E_REG_write_enable(E_RegWrite),
        .E_Tuse_rs(E_Tuse_rs),
        .E_Tuse_rt(E_Tuse_rt),
        .E_Tnew(E_Tnew),
        .M_rs(M_rs),
        .M_rt(M_rt),
        .M_REG_write_number(M_REG_write_number),
        .M_REG_write_enable(M_RegWrite),
        .M_Tuse_rs(M_Tuse_rs),
        .M_Tuse_rt(M_Tuse_rt),
        .M_Tnew(M_Tnew),
        .W_rs(W_rs),
        .W_rt(W_rt),
        .W_REG_write_number(W_REG_write_number),
        .W_REG_write_enable(W_RegWrite),
        .W_Tuse_rs(W_Tuse_rs),
        .W_Tuse_rt(W_Tuse_rt),
        .W_Tnew(W_Tnew),
        .stall(stall),
        .FWD_to_D_rs(FWD_to_D_rs),
        .FWD_to_D_rt(FWD_to_D_rt),
        .FWD_to_E_rs(FWD_to_E_rs),
        .FWD_to_E_rt(FWD_to_E_rt),
        .FWD_to_M_rt(FWD_to_M_rt)
    );
    wire stall;
    wire [`FWD_FROM_SIZE - 1:0] FWD_to_D_rs, FWD_to_D_rt, FWD_to_E_rs, FWD_to_E_rt, FWD_to_M_rt;

    // 取指阶段 Fetch 开始
    IFU F_ifu (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_PC(D_next_PC),
        .PC(F_PC),
        .instr(F_instr)
    );
    // 取指阶段 Fetch 结束

    FD_REG FD_reg (  // FD 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(D_Branch == `BRANCH_LIKELY && !D_CMP_result),
        .F_PC(F_PC),
        .F_instr(F_instr),
        .D_PC(D_PC),
        .D_instr(D_instr)
    );

    // 译码阶段 Decode 开始
    wire [15:0] D_immediate_offset = D_instr[15:0];
    wire [25:0] D_instr_index_offset = D_instr[25:0];

    Control #(`STAGE_DECODE) D_control (  // D 控制器
        .instr(D_instr),
        .Branch(D_Branch),
        .Jump(D_Jump),
        .EXTop(D_EXTop),
        .CMPSrc(D_CMPSrc),
        .CMPop(D_CMPop),
        .Tuse_rs(D_Tuse_rs),
        .Tuse_rt(D_Tuse_rt)
    );
    wire [`BRANCH_SIZE - 1:0] D_Branch;
    wire [`JUMP_SIZE - 1:0] D_Jump;
    wire [`EXTOP_SIZE - 1:0] D_EXTop;
    wire [`CMPOP_SIZE -1:0] D_CMPop;
    wire D_CMPSrc;

    // 写回阶段 Writeback 继续
    GRF DW_grf (  // 同时是 D 级和 W 级的组件
        .clk(clk),
        .reset(reset),
        .read_number1(D_rs),
        .read_number2(D_rt),
        .write_number(W_REG_write_number),
        .write_enable(W_RegWrite),
        .write_data(W_REG_write_data),
`ifdef DEBUG
        .PC(W_PC8 - 32'd8),
`endif
        .read_data1(D_rs_data_raw),
        .read_data2(D_rt_data_raw)
    );
    wire [31:0] D_rs_data_raw, D_rt_data_raw; // 已经经过内部转发，即 W->D ALU/MEM/PC8 转发
    wire [31:0] D_rs_data = FWD_to_D_rs == `FWD_FROM_DE ? E_FWD_data :
                            FWD_to_D_rs == `FWD_FROM_EM ? M_FWD_data :
                            D_rs_data_raw;
    wire [31:0] D_rt_data = FWD_to_D_rt == `FWD_FROM_DE ? E_FWD_data :
                            FWD_to_D_rt == `FWD_FROM_EM ? M_FWD_data :
                            D_rt_data_raw;
    // 写回阶段 Writeback 结束

    EXT D_ext (
        .operand(D_immediate_offset),
        .operation(D_EXTop),
        .result(D_EXT_result)
    );
    wire [31:0] D_EXT_result;

    CMP D_cmp (
        .operand1(D_rs_data),
        .operand2(D_CMPSrc == `CMPSRC_RT ? D_rt_data : 32'd0),
        .operation(D_CMPop),
        .result(D_CMP_result)
    );
    wire D_CMP_result;

    NPC FD_npc (  // 同时是 F 级和 D 级的组件
        .F_PC(F_PC),
        .D_PC(D_PC),
        .instr_index_offset(D_instr_index_offset),
        .regester(D_rs_data),
        .branch(D_Branch),
        .jump(D_Jump),
        .CMP_result(D_CMP_result),
        .next_PC(D_next_PC)
    );
    wire [31:0] D_next_PC;
    // 译码阶段 Decode 结束

    DE_REG DE_reg (  // DE 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(stall),
        .D_PC8(D_PC + 32'd8),
        .D_instr(D_instr),
        .D_rs_data(D_rs_data),
        .D_rt_data(D_rt_data),
        .D_EXT_result(D_EXT_result),
        .E_PC8(E_PC8),
        .E_instr(E_instr),
        .E_rs_data(E_rs_data_raw),
        .E_rt_data(E_rt_data_raw),
        .E_EXT_result(E_EXT_result)
    );
    wire [31:0] E_rs_data_raw, E_rt_data_raw, E_EXT_result;
    wire [31:0] E_rs_data = FWD_to_E_rs == `FWD_FROM_EM ? M_FWD_data :
                            FWD_to_E_rs == `FWD_FROM_MW ? W_FWD_data :
                            E_rs_data_raw;
    wire [31:0] E_rt_data = FWD_to_E_rt == `FWD_FROM_EM ? M_FWD_data :
                            FWD_to_E_rt == `FWD_FROM_MW ? W_FWD_data :
                            E_rt_data_raw;
    wire [31:0] E_FWD_data = E_Jump == `JUMP_INDEX ? E_PC8 : E_EXT_result;

    // 执行阶段 Execute 开始
    wire [4:0] E_shamt = E_instr[10:6];

    Control #(`STAGE_EXECUTE) E_control (  // E 控制器
        .instr(E_instr),
        .Jump(E_Jump),
        .RegDst(E_RegDst),
        .RegWrite(E_RegWrite),
        .ALUSrc(E_ALUSrc),
        .ALUop(E_ALUop),
        .Tuse_rs(E_Tuse_rs),
        .Tuse_rt(E_Tuse_rt),
        .Tnew(E_Tnew)
    );
    wire [`REGDST_SIZE - 1:0] E_RegDst;
    wire [  `JUMP_SIZE - 1:0] E_Jump;
    wire [`ALUSRC_SIZE - 1:0] E_ALUSrc;
    wire [ `ALUOP_SIZE - 1:0] E_ALUop;

    always @(*) begin
        case (E_RegDst)
            `REGDST_RT: begin
                E_REG_write_number = E_rt;
            end
            `REGDST_RD: begin
                E_REG_write_number = E_rd;
            end
            `REGDST_RA: begin
                E_REG_write_number = 5'd31;
            end
            default E_REG_write_number = 5'd0;
        endcase
    end

    always @(*) begin
        case (E_ALUSrc[0])
            `ALUSRC1_RS: begin
                E_ALUoperand1 = E_rs_data;
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
                E_ALUoperand2 = E_rs_data;
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

    EM_REG EM_reg (  // EM 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .E_PC8(E_PC8),
        .E_instr(E_instr),
        .E_rt_data(E_rt_data),
        .E_ALU_result(E_ALU_result),
        .M_PC8(M_PC8),
        .M_instr(M_instr),
        .M_rt_data(M_rt_data_raw),
        .M_ALU_result(M_ALU_result)
    );
    wire [31:0] M_rt_data_raw, M_ALU_result;
    wire [31:0] M_rt_data = FWD_to_M_rt == `FWD_FROM_MW ? W_FWD_data : M_rt_data_raw;
    wire [31:0] M_FWD_data = M_Jump == `JUMP_INDEX ? M_PC8 : M_ALU_result;

    // 访存阶段 Memory 开始
    Control #(`STAGE_MEMORY) M_control (  // M 控制器
        .instr(M_instr),
        .Jump(M_Jump),
        .RegDst(M_RegDst),
        .RegWrite(M_RegWrite),
        .DMop(M_DMop),
        .Tuse_rs(M_Tuse_rs),
        .Tuse_rt(M_Tuse_rt),
        .Tnew(M_Tnew)
    );
    wire [  `JUMP_SIZE - 1:0] M_Jump;
    wire [`REGDST_SIZE - 1:0] M_RegDst;
    wire [  `DMOP_SIZE - 1:0] M_DMop;

    always @(*) begin
        case (M_RegDst)
            `REGDST_RT: begin
                M_REG_write_number = M_rt;
            end
            `REGDST_RD: begin
                M_REG_write_number = M_rd;
            end
            `REGDST_RA: begin
                M_REG_write_number = 5'd31;
            end
            default M_REG_write_number = 5'd0;
        endcase
    end

    DM M_dm (
        .clk(clk),
        .reset(reset),
        .ADDR(M_ALU_result),
        .write_data_raw(M_rt_data),
        .operation(M_DMop),
`ifdef DEBUG
        .PC(M_PC8 - 32'd8),
`endif
        .read_data(M_MEM_read_data)
    );
    wire [31:0] M_MEM_read_data;
    // 访存阶段 Memory 结束

    MW_REG MW_reg (  // MW 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .M_PC8(M_PC8),
        .M_instr(M_instr),
        .M_ALU_result(M_ALU_result),
        .M_MEM_read_data(M_MEM_read_data),
        .W_PC8(W_PC8),
        .W_instr(W_instr),
        .W_ALU_result(W_ALU_result),
        .W_MEM_read_data(W_MEM_read_data)
    );
    wire [31:0] W_MEM_read_data, W_ALU_result;
    wire [31:0] W_FWD_data = W_REG_write_data;

    // 写回阶段 Writeback 开始
    Control #(`STAGE_WRITEBACK) W_control (  // W 控制器
        .instr(W_instr),
        .RegDst(W_RegDst),
        .RegSrc(W_RegSrc),
        .RegWrite(W_RegWrite),
        .Tuse_rs(W_Tuse_rs),
        .Tuse_rt(W_Tuse_rt),
        .Tnew(W_Tnew)
    );
    wire [`REGDST_SIZE - 1:0] W_RegDst;
    wire [`REGSRC_SIZE - 1:0] W_RegSrc;

    always @(*) begin
        case (W_RegDst)
            `REGDST_RT: begin
                W_REG_write_number = W_rt;
            end
            `REGDST_RD: begin
                W_REG_write_number = W_rd;
            end
            `REGDST_RA: begin
                W_REG_write_number = 5'd31;
            end
            default W_REG_write_number = 5'd0;
        endcase
    end

    always @(*) begin
        case (W_RegSrc)
            `REGSRC_ALU: begin
                W_REG_write_data = W_ALU_result;
            end
            `REGSRC_MEM: begin
                W_REG_write_data = W_MEM_read_data;
            end
            `REGSRC_PC: begin
                W_REG_write_data = W_PC8;
            end
            default W_REG_write_data = 32'hffffffff;
        endcase
    end
    reg [31:0] W_REG_write_data;
    // 写回阶段 Writeback 继续
endmodule
