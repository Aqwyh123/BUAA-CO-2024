`include "macros.v"

module IM (
    input  wire [31:0] ADDR,
    output wire [31:0] instr
);

    reg [31:0] ROM[`IM_BEGIN:`IM_BEGIN + `IM_SIZE - 1];
`ifdef DEBUG
    integer i;
    initial begin
        for (i = `IM_BEGIN; i < `IM_BEGIN + `IM_SIZE; i = i + 1) ROM[i] = 32'h00000000;
        $readmemh(`INPUT_PATH, ROM);
    end
`endif
    assign instr = ROM[ADDR>>2];
endmodule
