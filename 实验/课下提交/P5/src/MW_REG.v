`include "macros.v"

module MW_REG (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] M_instr,
    input wire [31:0] M_PC8,
    input wire [31:0] M_ALU_result,
    input wire [31:0] M_MEM_read_data,
    input wire [4:0] M_REG_write_number,
    input wire M_REG_write_enable,
    output wire [31:0] W_instr,
    output wire [31:0] W_PC8,
    output wire [31:0] W_ALU_result,
    output wire [31:0] W_MEM_read_data,
    output wire [4:0] W_REG_write_number,
    output wire W_REG_write_enable
);
    reg [31:0] W_instr_reg, W_PC8_reg, W_MEM_read_data_reg, W_ALU_result_reg;
    reg [4:0] W_REG_write_number_reg;
    reg W_REG_write_enable_reg;
    assign W_instr = W_instr_reg;
    assign W_PC8 = W_PC8_reg;
    assign W_ALU_result = W_ALU_result_reg;
    assign W_MEM_read_data = W_MEM_read_data_reg;
    assign W_REG_write_number = W_REG_write_number_reg;
    assign W_REG_write_enable = W_REG_write_enable_reg;

    always @(posedge clk) begin
        if (reset) begin
            W_instr_reg <= 32'd0;
            W_PC8_reg <= 32'd0;
            W_ALU_result_reg <= 32'd0;
            W_MEM_read_data_reg <= 32'd0;
            W_REG_write_number_reg <= 5'd0;
            W_REG_write_enable_reg <= 1'b0;
        end else if (stall) begin
            W_instr_reg <= W_instr_reg;
            W_PC8_reg <= W_PC8_reg;
            W_ALU_result_reg <= W_ALU_result_reg;
            W_MEM_read_data_reg <= W_MEM_read_data_reg;
            W_REG_write_number_reg <= W_REG_write_number_reg;
            W_REG_write_enable_reg <= W_REG_write_enable_reg;
        end else begin
            W_instr_reg <= M_instr;
            W_PC8_reg <= M_PC8;
            W_ALU_result_reg <= M_ALU_result;
            W_MEM_read_data_reg <= M_MEM_read_data;
            W_REG_write_number_reg <= M_REG_write_number;
            W_REG_write_enable_reg <= M_REG_write_enable;
        end
    end
endmodule
