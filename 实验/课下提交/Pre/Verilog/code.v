module code (
    input Clk,
    input Reset,
    input Slt,
    input En,
    output reg [63:0] Output0,
    output reg [63:0] Output1
);
    reg [2:0] cnt;
    always @(posedge Clk) begin
        if (Reset) begin
            Output0 <= 64'd0;
            Output1 <= 64'd0;
            cnt <= 3'd0;
        end else if (En) begin
            if (~Slt) begin
                Output0 <= Output0 + 64'd1;
            end else begin
                cnt <= cnt == 3'd3 ? 3'd0 : cnt + 3'd1;
                Output1 <= cnt == 3'd3 ? Output1 + 64'd1 : Output1;
            end
        end
    end
endmodule
