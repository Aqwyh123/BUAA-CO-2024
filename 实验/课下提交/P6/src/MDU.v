`include "macros.v"

module MDU (
    input wire clk,
    input wire reset,
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [`MDUOP_SIZE - 1:0] operation,
    output wire [31:0] HI,
    output wire [31:0] LO,
    output wire start,
    output wire busy
);
    reg [31:0] HI_reg, LO_reg;
    reg [31:0] operand1_reg, operand2_reg;
    reg [`DELAY_SIZE - 1:0] delay;
    reg [`MDUOP_SIZE - 1:0] operation_now;
    assign HI = HI_reg, LO = LO_reg;
    assign start = operation == `MDUOP_MULT || operation == `MDUOP_MULTU ||
                   operation == `MDUOP_DIV || operation == `MDUOP_DIVU;
    assign busy = delay != 4'd0;

    always @(posedge clk) begin
        if (reset) begin
            delay <= 4'd0;
            operation_now <= `MDUOP_NOOP;
            operand1_reg <= 32'd0;
            operand2_reg <= 32'd0;
        end else if (start) begin
            case (operation)
                `MDUOP_MULT: delay <= `DELAY_MUTI;
                `MDUOP_MULTU: delay <= `DELAY_MUTI;
                `MDUOP_DIV: delay <= `DELAY_DIV;
                `MDUOP_DIVU: delay <= `DELAY_DIV;
                default: delay <= 4'd0;
            endcase
            operation_now <= operation;
            operand1_reg  <= operand1;
            operand2_reg  <= operand2;
        end else begin
            delay <= delay == 4'd0 ? 4'd0 : delay - 4'd1;
            operation_now <= delay == 4'd1 ? `MDUOP_NOOP : operation_now;
            operand1_reg <= delay == 4'd1 ? 32'd0 : operand1_reg;
            operand2_reg <= delay == 4'd1 ? 32'd0 : operand2_reg;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            HI_reg <= 32'd0;
            LO_reg <= 32'd0;
        end else begin
            if (operation == `MDUOP_MTHI) begin
                HI_reg <= operand1;
            end else if (operation == `MDUOP_MTLO) begin
                LO_reg <= operand1;
            end else if (!start && delay == 4'd1) begin
                case (operation_now)
                    `MDUOP_MULT: {HI_reg, LO_reg} <= $signed(operand1_reg) * $signed(operand2_reg);
                    `MDUOP_MULTU: {HI_reg, LO_reg} <= operand1_reg * operand2_reg;
                    `MDUOP_DIV: begin
                        if (operand2_reg != 32'd0) begin
                            LO_reg <= $signed(operand1_reg) / $signed(operand2_reg);
                            HI_reg <= $signed(operand1_reg) % $signed(operand2_reg);
                        end
                    end
                    `MDUOP_DIVU: begin
                        if (operand2_reg != 32'd0) begin
                            LO_reg <= operand1_reg / operand2_reg;
                            HI_reg <= operand1_reg % operand2_reg;
                        end
                    end
                    default: ;
                endcase
            end
        end
    end
endmodule
