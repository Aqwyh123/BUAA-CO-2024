`include "macros.v"

module PC (
    input wire clk,
    input wire reset,
    input wire [31:0] next_PC,
    output wire [31:0] PC
);
    reg [31:0] regester;
    always @(posedge clk) begin
        if (reset) begin
            regester <= `PC_INIT;
        end else begin
            regester <= next_PC;
        end
    end
    assign PC = regester;
endmodule
