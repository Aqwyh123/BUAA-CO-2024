`include "macros.v"

module PC (
    input  wire        clk,
    input  wire        reset,
    input  wire        req,
    input  wire        stall,
    input  wire [31:0] next_PC,
    output wire [31:0] PC
);
    reg [31:0] PC_reg;
    assign PC = PC_reg;
    always @(posedge clk) begin
        if (reset) begin
            PC_reg <= `PC_INIT;
        end else if (req) begin
            PC_reg <= `EXC_ADDR;
        end else if (stall) begin
            PC_reg <= PC_reg;
        end else begin
            PC_reg <= next_PC;
        end
    end
endmodule
