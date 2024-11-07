`include "macros.v"
module IM (
    input  wire [31:0] ADDR,
    output wire [31:0] instruction
);
`ifdef DEBUG
`ifdef LOCAL
    integer fd;
`endif
`endif

    reg [31:0] ROM[`IM_BEGIN:`IM_BEGIN + `IM_SIZE - 1];
`ifdef DEBUG
    initial begin
        $readmemh(`INPUT_PATH, ROM);
`ifdef LOCAL
        fd = $fopen(`OUTPUT_PATH, "w");
        $fclose(fd);
`endif
    end
`endif
    assign instruction = ROM[ADDR>>2];
endmodule
