`include "macros.v"
module NPC (
    input wire [31:0] PC,
    input wire [15:0] offset,
    input wire [25:0] instr_index,
    input wire [31:0] regester,
    input wire ALU_zero,
    input wire [1:0] branch,
    input wire [1:0] jump,
    output reg [31:0] next_PC
);

    always @(*) begin
        case (jump)
            `JUMP_INDEX: next_PC = {PC[31:28], instr_index, 2'b00};
            `JUMP_REG:   next_PC = regester;
            default: begin
                case (branch)
                    `BRANCH_ZERO:
                    next_PC = ALU_zero ? PC + 32'd4 + ({{16{offset[15]}},offset}<<2) : PC + 32'd4;
                    `BRANCH_NONZERO:
                    next_PC = ALU_zero ? PC + 32'd4 : PC + 32'd4 + ({{16{offset[15]}},offset}<<2);
                    default: next_PC = PC + 4;
                endcase
            end
        endcase
    end

endmodule
