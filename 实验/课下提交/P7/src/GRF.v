`include "macros.v"

module GRF (
    input  wire        clk,
    input  wire        reset,
    input  wire [ 4:0] read_number1,
    input  wire [ 4:0] read_number2,
    input  wire [ 4:0] write_number,
    input  wire        write_enable,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] regfile[0:31];
    assign read_data1 = write_enable && write_number != 5'd0 &&
                        read_number1 == write_number ? write_data : regfile[read_number1];
    assign read_data2 = write_enable && write_number != 5'd0 &&
                        read_number2 == write_number ? write_data : regfile[read_number2];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) regfile[i] <= 32'd0;
        end else if (write_enable) begin
            regfile[write_number] <= write_number == 5'd0 ? 32'd0 : write_data;
        end
    end
endmodule
