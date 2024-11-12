`include "macros.v"

module CMP (
    input wire signed [31:0] operand1,
    input wire signed [31:0] operand2,
    input wire [`CMPOP_SIZE - 1:0] operation,
    output reg result
);
    always @(*) begin
        case (operation)
            `CMPOP_EQ: result = operand1 == operand2;
            `CMPOP_NE: result = operand1 != operand2;
            `CMPOP_LT: result = operand1 < operand2;
            `CMPOP_LE: result = operand1 <= operand2;
            `CMPOP_GT: result = operand1 > operand2;
            `CMPOP_GE: result = operand1 >= operand2;
            default:   result = 1'b0;
        endcase
    end
endmodule
