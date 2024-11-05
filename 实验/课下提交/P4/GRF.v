`include "macros.v"
module GRF (
    input wire clk,
    input wire reset,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire write_enable,
    input wire [31:0] write_data,
`ifdef DEBUG
    input wire [31:0] PC,
`endif
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] regfile[0:31];
    assign read_data1 = regfile[read_reg1];
    assign read_data2 = regfile[read_reg2];
    integer i;
`ifdef DEBUG
`ifdef LOCAL
    integer fd;
`endif
`endif

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'd0;
            end
        end else if (write_enable) begin
            regfile[write_reg] <= write_reg == 5'd0 ? 32'd0 : write_data;
`ifdef DEBUG
            $display("@%h: $%d <= %h", PC, write_reg, write_data);
`ifdef LOCAL
            fd = $fopen(`OUTPUT_PATH, "a");
            $fwrite(fd, "@%h: $%d <= %h\n", PC, write_reg, write_data);
            $fclose(fd);
`endif
`endif
        end
    end

endmodule
