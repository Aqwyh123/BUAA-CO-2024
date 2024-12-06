`include "macros.v"

module Bridge (
    input  wire        req,
    input  wire [31:0] PrAddr,
    input  wire [31:0] PrWD,
    input  wire [ 3:0] PrWE,
    input  wire [31:0] DM_RD,
    input  wire [31:0] timer0_RD,
    input  wire [31:0] timer1_RD,
    input  wire [31:0] INT_RD,
    output wire [31:0] PrRD,
    output wire [31:0] DEV_Addr,
    output wire [31:0] DEV_WD,
    output wire [ 3:0] DM_WE,
    output wire        timer0_WE,
    output wire        timer1_WE,
    output wire [ 3:0] INT_WE
);
    wire hit_DM = PrAddr >= `DM_LSA && PrAddr <= `DM_MSA;
    wire hit_timer0 = PrAddr >= `TIMER0_LSA && PrAddr <= `TIMER0_MSA;
    wire hit_timer1 = PrAddr >= `TIMER1_LSA && PrAddr <= `TIMER1_MSA;
    wire hit_INT = PrAddr >= `INT_LSA && PrAddr <= `INT_MSA;

    assign DEV_Addr = PrAddr;
    assign PrRD = hit_DM ? DM_RD :
                  hit_timer0 ? timer0_RD :
                  hit_timer1 ? timer1_RD :
                  hit_INT ? INT_RD : 32'hxxxxxxxx;
    assign DEV_WD = PrWD;

    assign DM_WE = !req && hit_DM ? PrWE : 4'b0000;
    assign timer0_WE = !req && hit_timer0 ? |PrWE : 1'b0;
    assign timer1_WE = !req && hit_timer1 ? |PrWE : 1'b0;
    assign INT_WE = !req && hit_INT ? PrWE : 4'b0000;
endmodule
