`include "macros.v"

module MDU (
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     req,
    input  wire [             31:0] operand1,
    input  wire [             31:0] operand2,
    input  wire [`MDUOP_SIZE - 1:0] operation,
    input  wire [              1:0] write_enable,
    output wire [             31:0] HI,
    output wire [             31:0] LO,
    output wire                     start,
    output wire                     busy
);
    reg [31:0] HI_reg, LO_reg;
    reg [31:0] operand1_reg, operand2_reg;
    reg [`MDUOP_SIZE - 1:0] operation_reg;
    reg [`DELAY_SIZE - 1:0] delay;

    assign HI = HI_reg, LO = LO_reg;
    wire ready = !req && delay == 4'd0;
    assign start = ready && operation != `MDUOP_NOOP;
    assign busy  = delay != 4'd0;

    always @(posedge clk) begin
        if (reset) begin
            delay         <= 4'd0;
            operation_reg <= `MDUOP_NOOP;
            operand1_reg  <= 32'd0;
            operand2_reg  <= 32'd0;
        end else if (ready) begin  // 检查乘除
            case (operation)
                `MDUOP_MULT: begin
                    delay         <= `DELAY_MUTI;
                    operation_reg <= operation;
                    operand1_reg  <= operand1;
                    operand2_reg  <= operand2;
                end
                `MDUOP_MULTU: begin
                    delay         <= `DELAY_MUTI;
                    operation_reg <= operation;
                    operand1_reg  <= operand1;
                    operand2_reg  <= operand2;
                end
                `MDUOP_DIV: begin
                    delay         <= `DELAY_DIV;
                    operation_reg <= operation;
                    operand1_reg  <= operand1;
                    operand2_reg  <= operand2;
                end
                `MDUOP_DIVU: begin
                    delay         <= `DELAY_DIV;
                    operation_reg <= operation;
                    operand1_reg  <= operand1;
                    operand2_reg  <= operand2;
                end
                default: begin
                    delay         <= 4'd0;
                    operation_reg <= `MDUOP_NOOP;
                    operand1_reg  <= 32'd0;
                    operand2_reg  <= 32'd0;
                end
            endcase
        end else begin  // 检查延迟
            delay         <= delay == 4'd0 ? 4'd0 : delay - 4'd1;
            operation_reg <= delay == 4'd1 ? `MDUOP_NOOP : operation_reg;
            operand1_reg  <= delay == 4'd1 ? 32'd0 : operand1_reg;
            operand2_reg  <= delay == 4'd1 ? 32'd0 : operand2_reg;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            HI_reg <= 32'd0;
            LO_reg <= 32'd0;
        end else if (ready) begin  // 检查直接写入
            if (write_enable[1]) begin
                HI_reg <= operand1;
            end else if (write_enable[0]) begin
                LO_reg <= operand1;
            end
        end else if (delay == 4'd1) begin  // 检查延迟乘除
            case (operation_reg)
                `MDUOP_MULT:  {HI_reg, LO_reg} <= $signed(operand1_reg) * $signed(operand2_reg);
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
                default:      ;
            endcase
        end
    end
endmodule
