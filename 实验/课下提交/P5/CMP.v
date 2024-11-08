`include "macros.v"

module CMP (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [2:0] operation,
    output reg result
);
    always @(*) begin
        case (operation)
            `CMPOP_EQ: result = operand1 == operand2;
            `CMPOP_NE: result = operand1 != operand2;
            `CMPOP_LT: result = $signed(operand1) < $signed(operand2);
            `CMPOP_LE: result = $signed(operand1) <= $signed(operand2);
            `CMPOP_GT: result = $signed(operand1) > $signed(operand2);
            `CMPOP_GE: result = $signed(operand1) >= $signed(operand2);
            default:   result = 1'b0;
        endcase
    end
endmodule
