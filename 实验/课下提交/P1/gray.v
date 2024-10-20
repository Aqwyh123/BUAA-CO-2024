module gray (
    input Clk,
    input Reset,
    input En,
    output reg [2:0] Output = 3'b0,
    output reg Overflow = 1'b0
);

  always @(posedge Clk) begin
    if (Reset) begin
      Output   <= 3'b0;
      Overflow <= 1'b0;
    end else if (En) begin
      case (Output)
        3'b000:  Output <= 3'b001;
        3'b001:  Output <= 3'b011;
        3'b010:  Output <= 3'b110;
        3'b011:  Output <= 3'b010;
        3'b100:  Output <= 3'b000;
        3'b101:  Output <= 3'b100;
        3'b110:  Output <= 3'b111;
        3'b111:  Output <= 3'b101;
        default: Output <= 3'b000;
      endcase
      if (Output == 3'b100) begin
        Overflow <= 1'b1;
      end
    end
  end

endmodule
