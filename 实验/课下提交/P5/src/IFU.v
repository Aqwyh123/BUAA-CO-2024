`include "macros.v"

module IFU (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] next_PC,
    output wire [31:0] PC,
    output wire [31:0] instr
);
    PC pc (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_PC(next_PC),
        .PC(PC)
    );
    IM im (
        .ADDR(PC),
        .instr(instr)
    );
endmodule
