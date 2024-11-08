`include "macros.v"

module MW_REG (
    input wire clk,
    input wire reset,
    input wire [31:0] M_PC,
    input wire [31:0] M_instruction,
    input wire [31:0] M_REG_read_data,
    input wire [31:0] M_ALU_result,
    input wire M_CMP_result,
    output wire [31:0] W_PC,
    output wire [31:0] W_instruction,
    output wire [31:0] W_REG_read_data,
    output wire [31:0] W_ALU_result,
    output wire W_CMP_result
);
    reg [31:0] W_PC_reg, W_instruction_reg, W_REG_read_data_reg, W_ALU_result_reg;
    reg W_CMP_result_reg;

    always @(posedge clk) begin
        if(reset)begin
            W_PC_reg <= 32'd0;
            W_instruction_reg <= 32'd0;
            W_REG_read_data_reg <= 32'd0;
            W_ALU_result_reg <= 32'd0;
            W_CMP_result_reg <= 1'b0;
        end
        else begin
            W_PC_reg <= M_PC;
            W_instruction_reg <= M_instruction;
            W_REG_read_data_reg <= M_REG_read_data;
            W_ALU_result_reg <= M_ALU_result;
            W_CMP_result_reg <= M_CMP_result;
        end
    end

    assign W_PC = W_PC_reg;
    assign W_instruction = W_instruction_reg;
    assign W_REG_read_data = W_REG_read_data_reg;
    assign W_ALU_result = W_ALU_result_reg;
    assign W_CMP_result = W_CMP_result_reg;
endmodule
