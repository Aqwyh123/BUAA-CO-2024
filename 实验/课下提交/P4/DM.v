`include "macros.v"
module DM (
    input wire clk,
    input wire reset,
    input wire [31:0] ADDR,
    input wire [31:0] write_data,
    input wire write_enable,
`ifdef DEBUG
    input wire [31:0] PC,
`endif
    output wire [31:0] read_data
);
`ifdef DEBUG
`ifdef LOCAL
    integer fd;
`endif
`endif

    reg [31:0] memory[0:`DM_SIZE - 1];
    assign read_data = memory[ADDR>>2];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < `DM_SIZE; i = i + 1) begin
                memory[i] = 32'd0;
            end
        end else begin
            if (write_enable) begin
                memory[ADDR>>2] = write_data;
`ifdef DEBUG
                $display("@%h: *%h <= %h", PC, {ADDR[31:2], 2'b00}, write_data);
`ifdef LOCAL
                fd = $fopen(`OUTPUT_PATH, "a");
                $fwrite(fd, "@%h: *%h <= %h\n", PC, {ADDR[31:2], 2'b00}, write_data);
                $fclose(fd);
`endif
`endif
            end
        end
    end
endmodule
