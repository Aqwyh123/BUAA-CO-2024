`include "macros.v"

module EM_REG (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] E_instr,
    input wire [31:0] E_PC8,
    input wire [31:0] E_rt_data,
    input wire [31:0] E_ALU_result,
    input wire [4:0] E_REG_write_number,
    input wire E_REG_write_enable,
    output wire [31:0] M_instr,
    output wire [31:0] M_PC8,
    output wire [31:0] M_rt_data,
    output wire [31:0] M_ALU_result,
    output wire [4:0] M_REG_write_number,
    output wire M_REG_write_enable
);
    reg [31:0] M_instr_reg, M_PC8_reg, M_ALU_result_reg, M_rt_data_reg;
    reg [4:0] M_REG_write_number_reg;
    reg M_REG_write_enable_reg;
    assign M_PC8 = M_PC8_reg;
    assign M_instr = M_instr_reg;
    assign M_rt_data = M_rt_data_reg;
    assign M_ALU_result = M_ALU_result_reg;
    assign M_REG_write_number = M_REG_write_number_reg;
    assign M_REG_write_enable = M_REG_write_enable_reg;

    always @(posedge clk) begin
        if (reset) begin
            M_instr_reg <= 32'd0;
            M_PC8_reg <= 32'd0;
            M_rt_data_reg <= 32'd0;
            M_ALU_result_reg <= 32'd0;
            M_REG_write_number_reg <= 5'd0;
            M_REG_write_enable_reg <= 1'b0;
        end else if (stall) begin
            M_instr_reg <= M_instr_reg;
            M_PC8_reg <= M_PC8_reg;
            M_rt_data_reg <= M_rt_data_reg;
            M_ALU_result_reg <= M_ALU_result_reg;
            M_REG_write_number_reg <= M_REG_write_number_reg;
            M_REG_write_enable_reg <= M_REG_write_enable_reg;
        end else begin
            M_instr_reg <= E_instr;
            M_PC8_reg <= E_PC8;
            M_rt_data_reg <= E_rt_data;
            M_ALU_result_reg <= E_ALU_result;
            M_REG_write_number_reg <= E_REG_write_number;
            M_REG_write_enable_reg <= E_REG_write_enable;
        end
    end
endmodule
