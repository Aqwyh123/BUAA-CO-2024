`include "macros.v"

module MW_REG (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] M_instr,
    input wire [31:0] M_PC8,
    input wire [31:0] M_ALU_result,
    input wire [31:0] M_MEM_read_data,
    output wire [31:0] W_instr,
    output wire [31:0] W_PC8,
    output wire [31:0] W_ALU_result,
    output wire [31:0] W_MEM_read_data
);
    reg [31:0] W_instr_reg, W_PC8_reg, W_MEM_read_data_reg, W_ALU_result_reg;
    assign W_instr = W_instr_reg;
    assign W_PC8 = W_PC8_reg;
    assign W_ALU_result = W_ALU_result_reg;
    assign W_MEM_read_data = W_MEM_read_data_reg;

    always @(posedge clk) begin
        if (reset) begin
            W_instr_reg <= 32'd0;
            W_PC8_reg <= 32'd0;
            W_ALU_result_reg <= 32'd0;
            W_MEM_read_data_reg <= 32'd0;
        end else if (stall) begin
            W_instr_reg <= W_instr_reg;
            W_PC8_reg <= W_PC8_reg;
            W_ALU_result_reg <= W_ALU_result_reg;
            W_MEM_read_data_reg <= W_MEM_read_data_reg;
        end else begin
            W_instr_reg <= M_instr;
            W_PC8_reg <= M_PC8;
            W_ALU_result_reg <= M_ALU_result;
            W_MEM_read_data_reg <= M_MEM_read_data;
        end
    end
endmodule
