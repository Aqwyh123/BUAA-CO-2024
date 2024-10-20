module top_module();
    reg clk;
    reg reset;
    reg t;
    wire q;
    tff tff0(
        .clk(clk),
        .reset(reset),
        .t(t),
        .q(q)
    );
    initial begin
        clk = 0;
        reset = 1;
        t = 0;
        #10 reset = 0;
        #10 t = 1;
    end
    always begin
        #5 clk = ~clk;
    end
endmodule

module tff (
    input clk,
    input reset,   // active-high synchronous reset
    input t,       // toggle
    output q
);
endmodule