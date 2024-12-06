`include "macros.v"

`define SR regfile[`SR_NUMBER]
`define CAUSE regfile[`CAUSE_NUMBER]
`define EPC regfile[`EPC_NUMBER]

`define IM `SR[`IM_MSB:`IM_LSB] // 中断掩码
`define EXL `SR[`EXL_POS] // 异常级别
`define IE `SR[`IE_POS] // 全局中断使能
`define BD `CAUSE[`BD_POS] // 分支延迟
`define IP `CAUSE[`IP_MSB:`IP_LSB] // 中断请求
`define EXCCODE `CAUSE[`EXCCODE_MSB:`EXCCODE_LSB] // 异常编码

module CP0 (
    input wire clk,
    input wire reset,
    input wire [4:0] number,
    output wire [31:0] read_data,
    input wire write_enable,
    input wire [31:0] write_data,
    input wire [31:0] VPC,
    input wire BDIn,
    input wire [4:0] ExcCodeIn,
    input wire [5:0] HWInt,
    input wire EXLClr,
    output wire [31:0] EPCOut,
    output wire [1:0] Request
);
    reg [31:0] regfile[0:31];
    assign read_data = regfile[number];
    assign EPCOut = regfile[`EPC_NUMBER];

    wire interupt = `IE & ~`EXL & |(`IM & HWInt); // 全局中断使能且不在异常处理状态且相应中断使能且相应中断请求
    wire exception = ~`EXL & |ExcCodeIn;  // 不在异常处理状态且有异常请求
    assign Request = {exception, interupt};

`ifdef LOCAL
    wire SR = `SR;
    wire CAUSE = `CAUSE;
    wire EPC = `EPC;
    wire IM = `IM;
    wire EXL = `EXL;
    wire IE = `IE;
    wire BD = `BD;
    wire IP = `IP;
    wire EXCCODE = `EXCCODE;
`endif

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) regfile[i] <= 32'd0;
        end else begin
            if (write_enable) begin
                regfile[number] <= write_data;  // 规定不会写入CAUSE
            end else begin
                `IP <= HWInt;
                if (EXLClr) begin  // 响应优先
                    `EXL <= 1'b0;
                end else if (interupt) begin  // 中断次之
                    `EXL <= 1'b1;
                    `EXCCODE <= `EXCCODE_INT;
                    `BD <= BDIn;
                    `EPC <= BDIn ? VPC : VPC - 32'd4;
                end else if (exception) begin  // 异常最次
                    `EXL <= 1'b1;
                    `EXCCODE <= ExcCodeIn;
                    `BD <= BDIn;
                    `EPC <= BDIn ? VPC : VPC - 32'd4;
                end
            end
        end
    end
endmodule
