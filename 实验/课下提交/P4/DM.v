`include "macros.v"
module DM (
    input wire clk,
    input wire reset,
    input wire [31:0] ADDR,
    input wire [31:0] data_in,
    input wire write_enable,
`ifdef DEBUG
    input wire [31:0] PC,
`endif
    output wire [31:0] data_out
);
    reg [31:0] memory[0:`DM_SIZE - 1];
    assign data_out = memory[ADDR>>2];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < `DM_SIZE; i = i + 1) begin
                memory[i] = 32'b0;
            end
        end else begin
            if (write_enable) begin
                memory[ADDR>>2] = data_in;
`ifdef DEBUG
                $display("@%h: *%h <= %h", PC, ADDR, data_in);
`endif
            end
        end
    end
endmodule
