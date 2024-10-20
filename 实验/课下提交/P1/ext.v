module ext (
    input [15:0] imm,
    input [1:0] EOp,
    output reg [31:0] ext
);

  always @(*) begin
    case (EOp)
      2'b00:   ext = {{16{imm[15]}}, imm};
      2'b01:   ext = {16'b0, imm};
      2'b10:   ext = {imm, 16'b0};
      2'b11:   ext = {{16{imm[15]}}, imm} << 2;
      default: ext = 32'b0;
    endcase
  end

endmodule
