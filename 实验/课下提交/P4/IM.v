`include "macros.v"
module IM (
    input  wire [31:0] ADDR,
    output wire [31:0] instruction
);
    reg [31:0] ROM[0:`IM_SIZE - 1];
    `ifdef DEBUG
    initial begin
        $readmemh(`CODE_PATH, ROM);
    end
    `endif
    assign instruction = ROM[(ADDR-32'h00003000)>>2];

endmodule
