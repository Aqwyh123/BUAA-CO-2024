`include "macros.v"

module FD_REG (
    input wire clk,
    input wire reset,
    input wire [31:0] F_PC,
    input wire [31:0] F_instruction,
    output wire [31:0] D_PC,
    output wire [31:0] D_instruction
);
    reg [31:0] D_PC_reg, D_instruction_reg;
    
    always @(posedge clk) begin
        if (reset) begin
            D_PC_reg <= 32'b0;
            D_instruction_reg <= 32'b0;
        end else begin
            D_PC_reg <= F_PC;
            D_instruction_reg <= F_instruction;
        end
    end

    assign D_PC = D_PC_reg;
    assign D_instruction = D_instruction_reg;
endmodule
