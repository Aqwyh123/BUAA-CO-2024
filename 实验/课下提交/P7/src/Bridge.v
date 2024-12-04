`include "macros.v"

module Bridge (
    input wire [31:0] PrAddr,
    input wire [31:0] PrWD,
    input wire [3:0] PrWE,
    input wire [31:0] MEM_RD,
    input wire [31:0] timer0_RD,
    input wire [31:0] timer1_RD,
    input wire [31:0] INT_RD,
    output wire [31:0] PrRD,
    output wire [31:0] DEV_Addr,
    output wire [31:0] DEV_WD,
    output wire [3:0] MEM_WE,
    output wire timer0_WE,
    output wire timer1_WE,
    output wire [3:0] INT_WE
);
    wire hit_MEM = PrAddr >= `MEM_LSA && PrAddr <= `MEM_MSA;
    wire hit_timer0 = PrAddr >= `TIMER0_LSA && PrAddr <= `TIMER0_MSA;
    wire hit_timer1 = PrAddr >= `TIMER1_LSA && PrAddr <= `TIMEE1_MSA;
    wire hit_INT = PrAddr >= `INT_LSA && PrAddr <= `INT_MSA;

    assign DEV_Addr = PrAddr;
    assign PrRD = hit_MEM ? MEM_RD :
                  hit_timer0 ? timer0_RD :
                  hit_timer1 ? timer1_RD :
                  hit_INT ? INT_RD : 32'hxxxxxxxx;
    assign DEV_WD = PrWD;

    assign MEM_WE = hit_MEM ? PrWE : 4'b0000;
    assign timer0_WE = hit_timer0 ? |PrWE : 1'b0;
    assign timer1_WE = hit_timer1 ? |PrWE : 1'b0;
    assign INT_WE = hit_INT ? PrWE : 4'b0000;
endmodule
