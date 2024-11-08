`include "macros.v"

module EM_REG (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire [31:0] E_PC,
    input wire [31:0] E_instruction,
    input wire [31:0] E_rt_data,
    input wire [4:0] E_REG_write_number,
    input wire E_CMP_result,
    input wire [31:0] E_ALU_result,
    output wire [31:0] M_PC,
    output wire [31:0] M_instruction,
    output wire [31:0] M_rt_data,
    output wire [4:0] M_REG_write_number,
    output wire M_CMP_result,
    output wire [31:0] M_ALU_result
);
    reg [31:0] M_PC_reg, M_instruction_reg, M_ALU_result_reg, M_rt_data_reg;
    reg [4:0] M_REG_write_number_reg;
    reg M_CMP_result_reg;

    always @(posedge clk) begin
        if (reset) begin
            M_PC_reg <= 32'd0;
            M_instruction_reg <= 32'd0;
            M_rt_data_reg <= 32'd0;
            M_REG_write_number_reg <= 5'd0;
            M_CMP_result_reg <= 1'b0;
            M_ALU_result_reg <= 32'd0;
        end else if (flush) begin
            M_PC_reg <= 32'd0;
            M_instruction_reg <= 32'd0;
            M_rt_data_reg <= 32'd0;
            M_REG_write_number_reg <= 5'd0;
            M_CMP_result_reg <= 1'b0;
            M_ALU_result_reg <= 32'd0;
        end else begin
            M_PC_reg <= E_PC;
            M_instruction_reg <= E_instruction;
            M_rt_data_reg <= E_rt_data;
            M_REG_write_number_reg <= E_REG_write_number;
            M_CMP_result_reg <= E_CMP_result;
            M_ALU_result_reg <= E_ALU_result;
        end
    end

    assign M_PC = M_PC_reg;
    assign M_instruction = M_instruction_reg;
    assign M_rt_data = M_rt_data_reg;
    assign M_REG_write_number = M_REG_write_number_reg;
    assign M_CMP_result = M_CMP_result_reg;
    assign M_ALU_result = M_ALU_result_reg;
endmodule
