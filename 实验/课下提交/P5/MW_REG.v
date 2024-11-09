`include "macros.v"

module MW_REG (
    input wire clk,
    input wire reset,
    input wire [31:0] M_instruction,
    input wire [31:0] M_PC8,
    input wire M_CMP_result,
    input wire [31:0] M_ALU_result,
    input wire [31:0] M_MEM_read_data,
    output wire [31:0] W_instruction,
    output wire [31:0] W_PC8,
    output wire W_CMP_result,
    output wire [31:0] W_ALU_result,
    output wire [31:0] W_MEM_read_data
);
    reg [31:0] W_instruction_reg, W_PC8_reg, W_MEM_read_data_reg, W_ALU_result_reg;
    reg W_CMP_result_reg;

    always @(posedge clk) begin
        if (reset) begin
            W_instruction_reg <= 32'd0;
            W_PC8_reg <= 32'd0;
            W_CMP_result_reg <= 1'b0;
            W_ALU_result_reg <= 32'd0;
            W_MEM_read_data_reg <= 32'd0;
        end else begin
            W_instruction_reg <= M_instruction;
            W_PC8_reg <= M_PC8;
            W_CMP_result_reg <= M_CMP_result;
            W_ALU_result_reg <= M_ALU_result;
            W_MEM_read_data_reg <= M_MEM_read_data;
        end
    end

    assign W_instruction = W_instruction_reg;
    assign W_PC8 = W_PC8_reg;
    assign W_CMP_result = W_CMP_result_reg;
    assign W_ALU_result = W_ALU_result_reg;
    assign W_MEM_read_data = W_MEM_read_data_reg;
endmodule
