`include "macros.v"

module GRF (
    input wire clk,
    input wire reset,
    input wire [4:0] read_number1,
    input wire [4:0] read_number2,
    input wire [4:0] write_number,
    input wire write_enable,
    input wire [31:0] write_data,
`ifdef DEBUG
    input wire [31:0] PC,
`endif
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] regfile[0:31];
    assign read_data1 = write_enable && write_number != 5'd0 &&
                        read_number1 == write_number ? write_data : regfile[read_number1];
    assign read_data2 = write_enable && write_number != 5'd0 &&
                        read_number2 == write_number ? write_data : regfile[read_number2];
`ifdef DEBUG
`ifdef LOCAL
    integer fd;
`endif
`endif
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) regfile[i] <= 32'd0;
        end else if (write_enable && write_number != 5'd0) begin
            regfile[write_number] <= write_data;
`ifdef DEBUG
            $display("%d@%h: $%d <= %h", $time, PC, write_number, write_data);
`ifdef LOCAL
            fd = $fopen(`OUTPUT_PATH, "a");
            $fwrite(fd, "@%h: $%d <= %h\n", PC, write_number, write_data);
            $fclose(fd);
`endif
`endif
        end
    end
endmodule
