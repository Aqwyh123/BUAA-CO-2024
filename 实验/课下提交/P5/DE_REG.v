`include "macros.v"

module DE_REG (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire [31:0] D_instruction,
    input wire [31:0] D_PC8,
    input wire [31:0] D_rs_base_data,
    input wire [31:0] D_rt_data,
    input wire [31:0] D_EXT_result,
    input wire D_CMP_result,
    output wire [31:0] E_PC,
    output wire [31:0] E_instruction,
    output wire [31:0] E_PC8,
    output wire [31:0] E_rs_base_data,
    output wire [31:0] E_rt_data,
    output wire [31:0] E_EXT_result,
    output wire E_CMP_result
);
    reg [31:0] E_instruction_reg, E_PC8_reg, E_rs_base_data_reg, E_rt_data_reg, E_EXT_result_reg;
    reg E_CMP_result_reg;

    always @(posedge clk) begin
        if (reset) begin
            E_instruction_reg <= 32'd0;
            E_PC8_reg <= 32'd0;
            E_rs_base_data_reg <= 32'd0;
            E_rt_data_reg <= 32'd0;
            E_EXT_result_reg <= 32'd0;
            E_CMP_result_reg <= 1'b0;
        end else if (flush) begin
            E_instruction_reg <= 32'd0;
            E_PC8_reg <= 32'd0;
            E_rs_base_data_reg <= 32'd0;
            E_rt_data_reg <= 32'd0;
            E_EXT_result_reg <= 32'd0;
            E_CMP_result_reg <= 1'b0;
        end else begin
            E_instruction_reg <= D_instruction;
            E_PC8_reg <= D_PC8;
            E_rs_base_data_reg <= D_rs_base_data;
            E_rt_data_reg <= D_rt_data;
            E_EXT_result_reg <= D_EXT_result;
            E_CMP_result_reg <= D_CMP_result;
        end
    end
    assign E_instruction = E_instruction_reg;
    assign E_PC8 = E_PC8_reg;
    assign E_rs_base_data = E_rs_base_data_reg;
    assign E_rt_data = E_rt_data_reg;
    assign E_EXT_result = E_EXT_result_reg;
    assign E_CMP_result = E_CMP_result_reg;
endmodule
