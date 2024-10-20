module counting (
    input [1:0] num,
    input clk,
    output ans
);
    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    reg [1:0] state = 0, next_state = 0;
    always @(posedge clk) begin
        state <= next_state;
    end
    always @(*) begin
        case (state)
            S0: next_state = num == 2'b01 ? S1 : S0;
            S1:
            case (num)
                2'b00: next_state = S1;
                2'b01: next_state = S1;
                2'b10: next_state = S2;
                2'b11: next_state = S0;
            endcase
            S2:
            case (num)
                2'b00: next_state = S2;
                2'b01: next_state = S1;
                2'b10: next_state = S2;
                2'b11: next_state = S3;
            endcase
            S3: case (num)
                2'b00: next_state = S3;
                2'b01: next_state = S1;
                2'b10: next_state = S0;
                2'b11: next_state = S3;
            endcase
        endcase
    end
    assign ans = state == S3;
endmodule
