`include "macros.v"

module DE_REG (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] D_instr,
    input wire [31:0] D_PC8,
    input wire [31:0] D_rs_data,
    input wire [31:0] D_rt_data,
    input wire [31:0] D_EXT_result,
    input wire [4:0] D_REG_write_number,
    input wire D_REG_write_enable,
    output wire [31:0] E_instr,
    output wire [31:0] E_PC8,
    output wire [31:0] E_rs_data,
    output wire [31:0] E_rt_data,
    output wire [31:0] E_EXT_result,
    output wire [4:0] E_REG_write_number,
    output wire E_REG_write_enable
);
    reg [31:0] E_instr_reg, E_PC8_reg, E_rs_data_reg, E_rt_data_reg, E_EXT_result_reg;
    reg [4:0] E_REG_write_number_reg;
    reg E_REG_write_enable_reg;
    assign E_instr = E_instr_reg;
    assign E_PC8 = E_PC8_reg;
    assign E_rs_data = E_rs_data_reg;
    assign E_rt_data = E_rt_data_reg;
    assign E_EXT_result = E_EXT_result_reg;
    assign E_REG_write_number = E_REG_write_number_reg;
    assign E_REG_write_enable = E_REG_write_enable_reg;

    always @(posedge clk) begin
        if (reset) begin
            E_instr_reg <= 32'd0;
            E_PC8_reg <= 32'd0;
            E_rs_data_reg <= 32'd0;
            E_rt_data_reg <= 32'd0;
            E_EXT_result_reg <= 32'd0;
            E_REG_write_number_reg <= 5'd0;
            E_REG_write_enable_reg <= 1'b0;
        end else if (stall) begin
            E_instr_reg <= E_instr_reg;
            E_PC8_reg <= E_PC8_reg;
            E_rs_data_reg <= E_rs_data_reg;
            E_rt_data_reg <= E_rt_data_reg;
            E_EXT_result_reg <= E_EXT_result_reg;
            E_REG_write_number_reg <= E_REG_write_number_reg;
            E_REG_write_enable_reg <= E_REG_write_enable_reg;
        end else if (flush) begin
            E_instr_reg <= 32'd0;
            E_PC8_reg <= 32'd0;
            E_rs_data_reg <= 32'd0;
            E_rt_data_reg <= 32'd0;
            E_EXT_result_reg <= 32'd0;
            E_REG_write_number_reg <= 5'd0;
            E_REG_write_enable_reg <= 1'b0;
        end else begin
            E_instr_reg <= D_instr;
            E_PC8_reg <= D_PC8;
            E_rs_data_reg <= D_rs_data;
            E_rt_data_reg <= D_rt_data;
            E_EXT_result_reg <= D_EXT_result;
            E_REG_write_number_reg <= D_REG_write_number;
            E_REG_write_enable_reg <= D_REG_write_enable;
        end
    end
endmodule
