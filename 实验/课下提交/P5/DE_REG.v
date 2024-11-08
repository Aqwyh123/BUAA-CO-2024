`include "macros.v"

module DE_REG (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] D_PC,
    input wire [31:0] D_instruction,
    input wire [31:0] D_rs_base_data,
    input wire [31:0] D_rt_data,
    input wire [4:0] D_REG_write_number,
    input wire [31:0] D_EXT_result,
    input wire D_CMP_result,
    output wire [31:0] R_PC,
    output wire [31:0] R_instruction,
    output wire [31:0] R_rs_base_data,
    output wire [31:0] R_rt_data,
    output wire [4:0] R_REG_write_number,
    output wire [31:0] R_EXT_result,
    output wire R_CMP_result
);
    reg [31:0] R_PC_reg, R_instruction_reg, R_rs_base_data_reg, R_rt_data_reg, R_EXT_result_reg;
    reg [4:0] R_REG_write_number_reg;
    reg R_CMP_result_reg;

    always @(posedge clk) begin
        if (reset) begin
            R_PC_reg <= 32'd0;
            R_instruction_reg <= 32'd0;
            R_rs_base_data_reg <= 32'd0;
            R_rt_data_reg <= 32'd0;
            R_REG_write_number_reg <= 5'd0;
            R_EXT_result_reg <= 32'd0;
            R_CMP_result_reg <= 1'b0;
        end else if (!stall) begin
            R_PC_reg <= D_PC;
            R_instruction_reg <= D_instruction;
            R_rs_base_data_reg <= D_rs_base_data;
            R_rt_data_reg <= D_rt_data;
            R_REG_write_number_reg <= D_REG_write_number;
            R_EXT_result_reg <= D_EXT_result;
            R_CMP_result_reg <= D_CMP_result;
        end
    end

    assign R_PC = R_PC_reg;
    assign R_instruction = R_instruction_reg;
    assign R_rs_base_data = R_rs_base_data_reg;
    assign R_rt_data = R_rt_data_reg;
    assign R_REG_write_number = R_REG_write_number_reg;
    assign R_EXT_result = R_EXT_result_reg;
    assign R_CMP_result = R_CMP_result_reg;
endmodule
