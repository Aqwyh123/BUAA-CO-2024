`include "macros.v"

module DE_REG (
    input  wire                       clk,
    input  wire                       reset,
    inout  wire                       req,
    input  wire                       stall,
    input  wire                       flush,
    input  wire [               31:0] D_instr,
    input  wire [               31:0] D_PC,
    input  wire [               31:0] D_rs_data,
    input  wire [               31:0] D_rt_data,
    input  wire [               31:0] D_EXT_result,
    input  wire [                4:0] D_REG_write_number,
    input  wire                       D_REG_write_enable,
    input  wire [`EXCCODE_SIZE - 1:0] D_ExcCode,
    input  wire                       D_BD,
    output wire [               31:0] E_instr,
    output wire [               31:0] E_PC,
    output wire [               31:0] E_rs_data,
    output wire [               31:0] E_rt_data,
    output wire [               31:0] E_EXT_result,
    output wire [                4:0] E_REG_write_number,
    output wire                       E_REG_write_enable,
    output wire [`EXCCODE_SIZE - 1:0] E_ExcCode,
    output wire                       E_BD
);
    reg [31:0] E_instr_reg, E_PC_reg, E_rs_data_reg, E_rt_data_reg, E_EXT_result_reg;
    reg [4:0] E_REG_write_number_reg;
    reg E_REG_write_enable_reg, E_BD_reg;
    reg [`EXCCODE_SIZE - 1:0] E_ExcCode_reg;
    assign E_instr            = E_instr_reg;
    assign E_PC               = E_PC_reg;
    assign E_rs_data          = E_rs_data_reg;
    assign E_rt_data          = E_rt_data_reg;
    assign E_EXT_result       = E_EXT_result_reg;
    assign E_REG_write_number = E_REG_write_number_reg;
    assign E_REG_write_enable = E_REG_write_enable_reg;
    assign E_ExcCode          = E_ExcCode_reg;
    assign E_BD               = E_BD_reg;

    always @(posedge clk) begin
        if (reset) begin
            E_instr_reg            <= 32'd0;
            E_PC_reg               <= 32'd0;
            E_rs_data_reg          <= 32'd0;
            E_rt_data_reg          <= 32'd0;
            E_EXT_result_reg       <= 32'd0;
            E_REG_write_number_reg <= 5'd0;
            E_REG_write_enable_reg <= 1'b0;
            E_ExcCode_reg          <= `EXCCODE_SIZE'd0;
            E_BD_reg               <= 1'b0;
        end else if (req) begin
            E_instr_reg            <= 32'd0;
            E_PC_reg               <= 32'd0;
            E_rs_data_reg          <= 32'd0;
            E_rt_data_reg          <= 32'd0;
            E_EXT_result_reg       <= 32'd0;
            E_REG_write_number_reg <= 5'd0;
            E_REG_write_enable_reg <= 1'b0;
            E_ExcCode_reg          <= `EXCCODE_SIZE'd0;
            E_BD_reg               <= 1'b0;
        end else if (stall) begin
            E_instr_reg            <= E_instr_reg;
            E_PC_reg               <= E_PC_reg;
            E_rs_data_reg          <= E_rs_data_reg;
            E_rt_data_reg          <= E_rt_data_reg;
            E_EXT_result_reg       <= E_EXT_result_reg;
            E_REG_write_number_reg <= E_REG_write_number_reg;
            E_REG_write_enable_reg <= E_REG_write_enable_reg;
            E_ExcCode_reg          <= E_ExcCode_reg;
            E_BD_reg               <= E_BD_reg;
        end else if (flush) begin
            E_instr_reg            <= 32'd0;
            E_PC_reg               <= 32'd0;
            E_rs_data_reg          <= 32'd0;
            E_rt_data_reg          <= 32'd0;
            E_EXT_result_reg       <= 32'd0;
            E_REG_write_number_reg <= 5'd0;
            E_REG_write_enable_reg <= 1'b0;
            E_ExcCode_reg          <= `EXCCODE_SIZE'd0;
            E_BD_reg               <= 1'b0;
        end else begin
            E_instr_reg            <= D_instr;
            E_PC_reg               <= D_PC;
            E_rs_data_reg          <= D_rs_data;
            E_rt_data_reg          <= D_rt_data;
            E_EXT_result_reg       <= D_EXT_result;
            E_REG_write_number_reg <= D_REG_write_number;
            E_REG_write_enable_reg <= D_REG_write_enable;
            E_ExcCode_reg          <= D_ExcCode;
            E_BD_reg               <= D_BD;
        end
    end
endmodule
