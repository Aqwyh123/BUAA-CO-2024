`include "macros.v"

module mips (
    input wire clk,
    input wire reset,
    input wire [31:0] i_inst_rdata,
    input wire [31:0] m_data_rdata,
    output wire [31:0] i_inst_addr,
    output wire [31:0] m_data_addr,
    output wire [31:0] m_data_wdata,
    output wire [3:0] m_data_byteen,
    output wire [31:0] m_inst_addr,
    output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    output wire [31:0] w_inst_addr
);
    wire [31:0] F_PC, D_PC, E_PC8, M_PC8, W_PC8;
`ifdef LOCAL
    wire [31:0] E_PC = E_PC8 >= 32'h00003008 ? E_PC8 - 32'd8 : 32'h00000000;
    wire [31:0] M_PC = M_PC8 >= 32'h00003008 ? M_PC8 - 32'd8 : 32'h00000000;
    wire [31:0] W_PC = W_PC8 >= 32'h00003008 ? W_PC8 - 32'd8 : 32'h00000000;
`endif
    wire [31:0] F_instr, D_instr, E_instr, M_instr, W_instr;
    reg D_REG_write_enable;
    wire E_REG_write_enable, M_REG_write_enable, W_REG_write_enable;
    reg [4:0] D_REG_write_number;
    wire [4:0] E_REG_write_number, M_REG_write_number, W_REG_write_number;
    wire signed [`T_SIZE - 1:0] D_Tuse_rs, D_Tuse_rt, E_Tuse_rs, E_Tuse_rt,
                                M_Tuse_rs, M_Tuse_rt, W_Tuse_rs, W_Tuse_rt;
    wire signed [`T_SIZE - 1:0] E_Tnew, M_Tnew, W_Tnew;

    wire [`REGSRC_SIZE - 1:0] D_RegSrc, E_RegSrc, M_RegSrc, W_RegSrc;
    wire [`MDUOP_SIZE - 1:0] D_MDUop, E_MDUop;
    wire D_request = D_RegSrc == `REGSRC_HI || D_RegSrc == `REGSRC_LO || D_MDUop != `MDUOP_NOOP;
    wire E_MDU_start, E_MDU_busy;
    wire E_busy = E_MDU_start || E_MDU_busy;

    wire stall;
    wire [`FWD_FROM_SIZE - 1:0] FWD_to_D_rs, FWD_to_D_rt, FWD_to_E_rs, FWD_to_E_rt, FWD_to_M_rt;

    wire [`BRANCH_SIZE - 1:0] D_Branch;
    wire [`JUMP_SIZE - 1:0] D_Jump;
    wire [`EXTOP_SIZE - 1:0] D_EXTop;
    wire [`CMPOP_SIZE -1:0] D_CMPop;
    wire [`REGDST_SIZE - 1:0] D_RegDst;
    wire [`REGWRITE_SIZE - 1:0] D_RegWrite;
    wire D_CMPSrc;
    wire [31:0] D_EXT_result, FD_next_PC;
    wire D_CMP_result;

    wire [`ALUSRC_SIZE - 1:0] E_ALUSrc;
    wire [`ALUOP_SIZE - 1:0] E_ALUop;
    wire [31:0] E_EXT_result, E_ALU_result, E_HI, E_LO;
    reg [31:0] E_ALUoperand1, E_ALUoperand2;

    wire [`MEMWRITE_SIZE - 1:0] M_MemWrite;
    wire [`DEOP_SIZE - 1:0] M_DEop;
    wire [31:0] M_ALU_result, M_MEM_read_data_raw, M_MEM_read_data, M_HI_LO;
    wire [31:0] M_MEM_write_data;
    wire [ 3:0] M_MEM_write_enable;

    wire [31:0] W_MEM_read_data, W_ALU_result, W_HI_LO;
    reg [31:0] W_REG_write_data;

    wire [31:0] D_rs_data_raw, D_rt_data_raw, E_rs_data_raw, E_rt_data_raw, M_rt_data_raw;
    wire [31:0] E_FWD_data = E_RegSrc == `REGSRC_PC8 ? E_PC8 : E_EXT_result;
    wire [31:0] M_FWD_data = M_RegSrc == `REGSRC_PC8 ? M_PC8 :
                             M_RegSrc == `REGSRC_HI || M_RegSrc == `REGSRC_LO ? M_HI_LO :
                             M_ALU_result;
    wire [31:0] W_FWD_data = W_REG_write_data;
    // D_data 已经经过内部转发，即 W->D ALU/MEM/PC8/HL 转发
    wire [31:0] D_rs_data = FWD_to_D_rs == `FWD_FROM_DE ? E_FWD_data :
                            FWD_to_D_rs == `FWD_FROM_EM ? M_FWD_data :
                            D_rs_data_raw;
    wire [31:0] D_rt_data = FWD_to_D_rt == `FWD_FROM_DE ? E_FWD_data :
                            FWD_to_D_rt == `FWD_FROM_EM ? M_FWD_data :
                            D_rt_data_raw;
    wire [31:0] E_rs_data = FWD_to_E_rs == `FWD_FROM_EM ? M_FWD_data :
                            FWD_to_E_rs == `FWD_FROM_MW ? W_FWD_data :
                            E_rs_data_raw;
    wire [31:0] E_rt_data = FWD_to_E_rt == `FWD_FROM_EM ? M_FWD_data :
                            FWD_to_E_rt == `FWD_FROM_MW ? W_FWD_data :
                            E_rt_data_raw;
    wire [31:0] M_rt_data = FWD_to_M_rt == `FWD_FROM_MW ? W_FWD_data : M_rt_data_raw;

    assign m_inst_addr = M_PC8 - 32'd8;  // 调试信息
    assign w_grf_addr = W_REG_write_number;
    assign w_grf_wdata = W_REG_write_data;
    assign w_grf_we = W_REG_write_enable;
    assign w_inst_addr = W_PC8 - 32'd8;

    HazardControl hazard_control (
        .D_rs(D_instr[`RS_MSB:`RS_LSB]),
        .D_rt(D_instr[`RT_MSB:`RT_LSB]),
        .D_Tuse_rs(D_Tuse_rs),
        .D_Tuse_rt(D_Tuse_rt),
        .D_request(D_request),
        .E_rs(E_instr[`RS_MSB:`RS_LSB]),
        .E_rt(E_instr[`RT_MSB:`RT_LSB]),
        .E_REG_write_number(E_REG_write_number),
        .E_REG_write_enable(E_REG_write_enable),
        .E_Tuse_rs(E_Tuse_rs),
        .E_Tuse_rt(E_Tuse_rt),
        .E_Tnew(E_Tnew),
        .E_busy(E_busy),
        .M_rs(M_instr[`RS_MSB:`RS_LSB]),
        .M_rt(M_instr[`RT_MSB:`RT_LSB]),
        .M_REG_write_number(M_REG_write_number),
        .M_REG_write_enable(M_REG_write_enable),
        .M_Tuse_rs(M_Tuse_rs),
        .M_Tuse_rt(M_Tuse_rt),
        .M_Tnew(M_Tnew),
        .W_rs(W_instr[`RS_MSB:`RS_LSB]),
        .W_rt(W_instr[`RT_MSB:`RT_LSB]),
        .W_REG_write_number(W_REG_write_number),
        .W_REG_write_enable(W_REG_write_enable),
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

    // 取指阶段 Fetch 开始
    PC F_pc (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_PC(FD_next_PC),
        .PC(F_PC)
    );
    assign i_inst_addr = F_PC;  // IM 输入地址
    assign F_instr = i_inst_rdata;  // IM 输出指令
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
    Control #(`STAGE_DECODE) D_control (  // D 控制器
        .instr(D_instr),
        .Branch(D_Branch),
        .Jump(D_Jump),
        .EXTop(D_EXTop),
        .CMPSrc(D_CMPSrc),
        .CMPop(D_CMPop),
        .RegDst(D_RegDst),
        .RegWrite(D_RegWrite),
        .RegSrc(D_RegSrc),
        .MDUop(D_MDUop),
        .Tuse_rs(D_Tuse_rs),
        .Tuse_rt(D_Tuse_rt)
    );

    // 写回阶段 Writeback 继续
    GRF DW_grf (  // 同时是 D 级和 W 级的组件
        .clk(clk),
        .reset(reset),
        .read_number1(D_instr[`RS_MSB:`RS_LSB]),
        .read_number2(D_instr[`RT_MSB:`RT_LSB]),
        .write_number(W_REG_write_number),
        .write_enable(W_REG_write_enable),
        .write_data(W_REG_write_data),
        .read_data1(D_rs_data_raw),
        .read_data2(D_rt_data_raw)
    );
    // 写回阶段 Writeback 结束

    EXT D_ext (
        .operand(D_instr[`IMM_MSB:`IMM_LSB]),
        .operation(D_EXTop),
        .result(D_EXT_result)
    );

    CMP D_cmp (
        .operand1(D_rs_data),
        .operand2(D_CMPSrc == `CMPSRC_RT ? D_rt_data : 32'd0),
        .operation(D_CMPop),
        .result(D_CMP_result)
    );

    NPC FD_npc (  // 同时是 F 级和 D 级的组件
        .F_PC(F_PC),
        .D_PC(D_PC),
        .instr_index_offset(D_instr[`INDEX_MSB:`INDEX_LSB]),
        .regester(D_rs_data),
        .branch(D_Branch),
        .jump(D_Jump),
        .condition(D_CMP_result),
        .next_PC(FD_next_PC)
    );

    always @(*) begin
        case (D_RegDst)
            `REGDST_RT: D_REG_write_number = D_instr[`RT_MSB:`RT_LSB];
            `REGDST_RD: D_REG_write_number = D_instr[`RD_MSB:`RD_LSB];
            `REGDST_RA: D_REG_write_number = 5'd31;
            default: D_REG_write_number = 5'bxxxxx;
        endcase
    end
    always @(*) begin
        case (D_RegWrite)
            `REGWRITE_DISABLE: D_REG_write_enable = 1'b0;
            `REGWRITE_UNCOND: D_REG_write_enable = 1'b1;
            `REGWRITE_COND: D_REG_write_enable = D_CMP_result;
            default: D_REG_write_enable = 1'bx;
        endcase
    end
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
        .D_REG_write_number(D_REG_write_number),
        .D_REG_write_enable(D_REG_write_enable),
        .E_PC8(E_PC8),
        .E_instr(E_instr),
        .E_rs_data(E_rs_data_raw),
        .E_rt_data(E_rt_data_raw),
        .E_EXT_result(E_EXT_result),
        .E_REG_write_number(E_REG_write_number),
        .E_REG_write_enable(E_REG_write_enable)
    );

    // 执行阶段 Execute 开始
    Control #(`STAGE_EXECUTE) E_control (  // E 控制器
        .instr(E_instr),
        .ALUSrc(E_ALUSrc),
        .ALUop(E_ALUop),
        .MDUop(E_MDUop),
        .RegSrc(E_RegSrc),
        .Tuse_rs(E_Tuse_rs),
        .Tuse_rt(E_Tuse_rt),
        .Tnew(E_Tnew)
    );

    always @(*) begin
        case (E_ALUSrc[0])
            `ALUSRC1_RS: E_ALUoperand1 = E_rs_data;
            `ALUSRC1_RT: E_ALUoperand1 = E_rt_data;
            default: E_ALUoperand1 = 32'hxxxxxxxx;
        endcase
        case (E_ALUSrc[`ALUSRC2_SIZE+`ALUSRC1_SIZE-1:`ALUSRC1_SIZE])
            `ALUSRC2_RT: E_ALUoperand2 = E_rt_data;
            `ALUSRC2_IMM_SHAMT: E_ALUoperand2 = E_EXT_result;
            `ALUSRC2_S: E_ALUoperand2 = {27'd0, E_instr[`SHAMT_MSB:`SHAMT_LSB]};
            `ALUSRC2_RS: E_ALUoperand2 = E_rs_data;
            default: E_ALUoperand2 = 32'hxxxxxxxx;
        endcase
    end
    ALU E_alu (
        .operand1(E_ALUoperand1),
        .operand2(E_ALUoperand2),
        .operation(E_ALUop),
        .result(E_ALU_result)
    );

    MDU E_mdu (
        .clk(clk),
        .reset(reset),
        .operand1(E_rs_data),
        .operand2(E_rt_data),
        .operation(E_MDUop),
        .HI(E_HI),
        .LO(E_LO),
        .start(E_MDU_start),
        .busy(E_MDU_busy)
    );
    // 执行阶段 Execute 结束

    EM_REG EM_reg (  // EM 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .E_PC8(E_PC8),
        .E_instr(E_instr),
        .E_rt_data(E_rt_data),
        .E_ALU_result(E_ALU_result),
        .E_HI_LO(E_RegSrc == `REGSRC_HI ? E_HI : E_LO),
        .E_REG_write_number(E_REG_write_number),
        .E_REG_write_enable(E_REG_write_enable),
        .M_PC8(M_PC8),
        .M_instr(M_instr),
        .M_rt_data(M_rt_data_raw),
        .M_ALU_result(M_ALU_result),
        .M_HI_LO(M_HI_LO),
        .M_REG_write_number(M_REG_write_number),
        .M_REG_write_enable(M_REG_write_enable)
    );

    // 访存阶段 Memory 开始
    Control #(`STAGE_MEMORY) M_control (  // M 控制器
        .instr(M_instr),
        .MemWrite(M_MemWrite),
        .DEop(M_DEop),
        .RegSrc(M_RegSrc),
        .Tuse_rs(M_Tuse_rs),
        .Tuse_rt(M_Tuse_rt),
        .Tnew(M_Tnew)
    );

    BE M_be (
        .ADDR(M_ALU_result[1:0]),
        .data_in(M_rt_data),
        .operation(M_MemWrite),
        .data_out(M_MEM_write_data),
        .data_enable(M_MEM_write_enable)
    );

    assign m_data_addr = M_ALU_result;  // DM 输入地址
    assign m_data_wdata = M_MEM_write_data;  // DM 写数据
    assign m_data_byteen = M_MEM_write_enable;  // DM 写字节使能
    assign M_MEM_read_data_raw = m_data_rdata;  // DM 读数据

    DE M_de (
        .ADDR(M_ALU_result[1:0]),
        .data_in(M_MEM_read_data_raw),
        .operation(M_DEop),
        .data_out(M_MEM_read_data)
    );
    // 访存阶段 Memory 结束

    MW_REG MW_reg (  // MW 流水线寄存器
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .M_PC8(M_PC8),
        .M_instr(M_instr),
        .M_ALU_result(M_ALU_result),
        .M_HI_LO(M_HI_LO),
        .M_MEM_read_data(M_MEM_read_data),
        .M_REG_write_number(M_REG_write_number),
        .M_REG_write_enable(M_REG_write_enable),
        .W_PC8(W_PC8),
        .W_instr(W_instr),
        .W_ALU_result(W_ALU_result),
        .W_HI_LO(W_HI_LO),
        .W_MEM_read_data(W_MEM_read_data),
        .W_REG_write_number(W_REG_write_number),
        .W_REG_write_enable(W_REG_write_enable)
    );

    // 写回阶段 Writeback 开始
    Control #(`STAGE_WRITEBACK) W_control (  // W 控制器
        .instr(W_instr),
        .RegSrc(W_RegSrc),
        .Tuse_rs(W_Tuse_rs),
        .Tuse_rt(W_Tuse_rt),
        .Tnew(W_Tnew)
    );

    always @(*) begin
        case (W_RegSrc)
            `REGSRC_ALU: begin
                W_REG_write_data = W_ALU_result;
            end
            `REGSRC_MEM: begin
                W_REG_write_data = W_MEM_read_data;
            end
            `REGSRC_PC8: begin
                W_REG_write_data = W_PC8;
            end
            `REGSRC_HI: begin
                W_REG_write_data = W_HI_LO;
            end
            `REGSRC_LO: begin
                W_REG_write_data = W_HI_LO;
            end
            default: W_REG_write_data = 32'hxxxxxxxx;
        endcase
    end
    // 写回阶段 Writeback 继续
endmodule
