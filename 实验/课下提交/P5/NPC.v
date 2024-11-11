`include "macros.v"

module NPC (
    input wire [31:0] F_PC,
    input wire [31:0] D_PC,
    input wire [25:0] instr_index_offset,
    input wire [31:0] regester,
    input wire [`BRANCH_SIZE - 1:0] branch,
    input wire [`JUMP_SIZE - 1:0] jump,
    input wire CMP_result,
    output reg [31:0] next_PC
);
    wire [15:0] offset = instr_index_offset[15:0];

    always @(*) begin
        case (jump)
            `JUMP_DISABLE: begin
                case (branch)
                    `BRANCH_DISABLE: next_PC = F_PC + 32'd4;
                    `BRANCH_COND:
                    next_PC = CMP_result ? D_PC + 32'd4 + ({{16{offset[15]}}, offset} << 2) : F_PC + 32'd4;
                    `BRANCH_UNCOND: next_PC = D_PC + 32'd4 + ({{16{offset[15]}}, offset} << 2);
                    default: next_PC = F_PC + 32'd4;
                endcase
            end
            `JUMP_INDEX: next_PC = {D_PC[31:28], instr_index_offset, 2'b00};
            `JUMP_REG: next_PC = regester;
            default: next_PC = F_PC + 32'd4;
        endcase
    end
endmodule
