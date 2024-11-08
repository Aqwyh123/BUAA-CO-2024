`include "macros.v"

module NPC (
    input wire [31:0] PC,
    input wire [25:0] instr_index_offset,
    input wire [31:0] regester,
    input wire branch,
    input wire [1:0] jump,
    output reg [31:0] next_PC
);
    always @(*) begin
        case (jump)
            `JUMP_INDEX: next_PC = {PC[31:28], instr_index_offset, 2'b00};
            `JUMP_REG: next_PC = regester;
            default:
            next_PC = branch ? PC + 32'd4 + ({{16{instr_index_offset[15]}}, instr_index_offset[15:0]} << 2) : PC + 32'd4;
        endcase
    end
endmodule
