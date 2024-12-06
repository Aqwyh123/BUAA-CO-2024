`include "macros.v"

module FD_REG (
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       req,
    input  wire                       stall,
    input  wire                       flush,
    input  wire [               31:0] F_PC,
    input  wire [               31:0] F_instr,
    input  wire [`EXCCODE_SIZE - 1:0] F_ExcCode,
    input  wire                       F_BD,
    output wire [               31:0] D_PC,
    output wire [               31:0] D_instr,
    output wire [`EXCCODE_SIZE - 1:0] D_ExcCode,
    output wire                       D_BD
);
    reg [31:0] D_PC_reg, D_instr_reg;
    reg [`EXCCODE_SIZE - 1:0] D_ExcCode_reg;
    reg                       D_BD_reg;
    assign D_PC      = D_PC_reg;
    assign D_instr   = D_instr_reg;
    assign D_ExcCode = D_ExcCode_reg;

    always @(posedge clk) begin
        if (reset) begin
            D_PC_reg      <= 32'd0;
            D_instr_reg   <= 32'd0;
            D_ExcCode_reg <= `EXCCODE_SIZE'd0;
            D_BD_reg      <= 1'b0;
        end else if (req) begin
            D_PC_reg      <= 32'd0;
            D_instr_reg   <= 32'd0;
            D_ExcCode_reg <= `EXCCODE_SIZE'd0;
            D_BD_reg      <= 1'b0;
        end else if (stall) begin
            D_PC_reg      <= D_PC_reg;
            D_instr_reg   <= D_instr_reg;
            D_ExcCode_reg <= D_ExcCode_reg;
            D_BD_reg      <= D_BD_reg;
        end else if (flush) begin
            D_PC_reg      <= 32'd0;
            D_instr_reg   <= 32'd0;
            D_ExcCode_reg <= `EXCCODE_SIZE'd0;
            D_BD_reg      <= 1'b0;
        end else begin
            D_PC_reg      <= F_PC;
            D_instr_reg   <= F_instr;
            D_ExcCode_reg <= F_ExcCode;
            D_BD_reg      <= F_BD;
        end
    end
endmodule
