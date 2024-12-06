`include "macros.v"

module EXT (
    input  wire [             15:0] operand,
    input  wire [`EXTOP_SIZE - 1:0] operation,
    output reg  [             31:0] result
);
    always @(*) begin
        case (operation)
            `EXTOP_ZERO:  result = {16'd0, operand};
            `EXTOP_SIGN:  result = {{16{operand[15]}}, operand};
            `EXTOP_UPPER: result = {operand, 16'd0};
            default:      result = 32'hxxxxxxxx;
        endcase
    end
endmodule
