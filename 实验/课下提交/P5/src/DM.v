`include "macros.v"

module DM (
    input wire clk,
    input wire reset,
    input wire [31:0] ADDR,
    input wire [31:0] write_data,
    input wire [3:0] write_enable,
`ifdef DEBUG
    input wire [31:0] PC,
`endif
    output wire [31:0] read_data
);

    reg [31:0] memory[0:`DM_SIZE - 1];
    assign read_data = memory[ADDR>>2];

    reg [31:0] write_data_fix;
    always @(*) begin
        write_data_fix = read_data;
        write_data_fix[7:0] = write_enable[0] ? write_data[7:0] : write_data_fix[7:0];
        write_data_fix[15:8] = write_enable[1] ? write_data[15:8] : write_data_fix[15:8];
        write_data_fix[23:16] = write_enable[2] ? write_data[23:16] : write_data_fix[23:16];
        write_data_fix[31:24] = write_enable[3] ? write_data[31:24] : write_data_fix[31:24];
    end

    integer i;
`ifdef DEBUG
`ifdef LOCAL
    integer fd;
`endif
`endif
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < `DM_SIZE; i = i + 1) memory[i] <= 32'd0;
        end else if (|write_enable) begin
            memory[ADDR>>2] <= write_data_fix;
`ifdef DEBUG
            $display("%d@%h: *%h <= %h", $time, PC, {ADDR[31:2], 2'b00}, write_data_fix);
`ifdef LOCAL
            fd = $fopen(`OUTPUT_PATH, "a");
            $fwrite(fd, "@%h: *%h <= %h\n", PC, {ADDR[31:2], 2'b00}, write_data_fix);
            $fclose(fd);
`endif
`endif
        end
    end
endmodule
