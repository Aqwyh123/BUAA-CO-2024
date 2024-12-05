`include "macros.v"

module ALU (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [`ALUOP_SIZE - 1:0] operation,
    output reg [31:0] result,
    output reg overflow
);
    reg [32:0] temp;
    always @(*) begin
        overflow = 1'b0;
        temp = 32'h00000000;
        case (operation)
            `ALUOP_NOOP: result = 32'h00000000;  // noop
            `ALUOP_ADD: begin  // add
                temp = {operand1[31], operand1} + {operand2[31], operand2};
                result = operand1 + operand2;
                overflow = temp[32] != temp[31];
            end
            `ALUOP_ADDU: result = operand1 + operand2;  // addu
            `ALUOP_SUB: begin
                temp = {operand1[31], operand1} - {operand2[31], operand2};
                result = operand1 - operand2;  // sub
                overflow = temp[32] != temp[31];
            end
            `ALUOP_SUBU: result = operand1 - operand2;  // subu
            `ALUOP_AND: result = operand1 & operand2;  // and
            `ALUOP_OR: result = operand1 | operand2;  // or
            `ALUOP_XOR: result = operand1 ^ operand2;  // xor
            `ALUOP_NOR: result = ~(operand1 | operand2);  // nor
            `ALUOP_SLL: result = operand1 << operand2[4:0];  // sll
            `ALUOP_SRL: result = operand1 >> operand2[4:0];  // srl
            `ALUOP_SRA: result = $signed(operand1) >>> operand2[4:0];  // sra
            `ALUOP_LT: result = $signed(operand1) < $signed(operand2);  // slt
            `ALUOP_LTU: result = operand1 < operand2;  // sltu
            default: result = 32'hxxxxxxxx;
        endcase
    end
endmodule
