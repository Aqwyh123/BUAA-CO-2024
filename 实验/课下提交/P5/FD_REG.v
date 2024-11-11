`include "macros.v"

module FD_REG (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] F_PC,
    input wire [31:0] F_instr,
    output wire [31:0] D_PC,
    output wire [31:0] D_instr
);
    reg [31:0] D_PC_reg, D_instr_reg;

    always @(posedge clk) begin
        if (reset) begin
            D_PC_reg <= 32'd0;
            D_instr_reg <= 32'd0;
        end else if (!stall) begin
            D_PC_reg <= F_PC;
            D_instr_reg <= F_instr;
        end
    end

    assign D_PC = D_PC_reg;
    assign D_instr = D_instr_reg;
endmodule
