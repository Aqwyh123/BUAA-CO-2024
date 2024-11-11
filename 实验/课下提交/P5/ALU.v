`include "macros.v"

module ALU (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [`ALUOP_SIZE - 1:0] operation,
    output reg [31:0] result
);
    always @(*) begin
        case (operation)
            `ALUOP_ADD: result = operand1 + operand2;  // add
            `ALUOP_SUB: result = operand1 - operand2;  // sub
            `ALUOP_AND: result = operand1 & operand2;  // and
            `ALUOP_OR: result = operand1 | operand2;  // or
            `ALUOP_XOR: result = operand1 ^ operand2;  // xor
            `ALUOP_NOR: result = ~(operand1 | operand2);  // nor
            `ALUOP_SLL: result = operand1 << operand2[4:0];  // sll
            `ALUOP_SRL: result = operand1 >> operand2[4:0];  // srl
            `ALUOP_SRA: result = $signed(operand1) >>> operand2[4:0];  // sra
            `ALUOP_LT: result = $signed(operand1) < $signed(operand2) ? 32'd1 : 32'd0;  // slt
            `ALUOP_LTU: result = operand1 < operand2 ? 32'd1 : 32'd0;  // sltu
            default: result = 32'hffffffff;
        endcase
    end
endmodule
