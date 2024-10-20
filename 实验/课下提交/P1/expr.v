module expr (
    input clk,
    input clr,
    input [7:0] in,
    output out
);
  localparam IDLE = 4'b0001, NUM = 4'b0010, OP = 4'b0100, ERR = 4'b1000;

  reg [3:0] state, next_state;

  assign isNum = in >= 8'd48 && in <= 8'd57;
  assign isOp  = in == 8'd42 || in == 8'd43;

  always @(posedge clk or posedge clr) begin
    if (clr) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      IDLE: next_state = isNum ? NUM : ERR;
      NUM: next_state = isOp ? OP : ERR;
      OP: next_state = isNum ? NUM : ERR;
      ERR: next_state = ERR;
      default: next_state = IDLE;
    endcase
  end

  assign out = state == NUM;

endmodule
