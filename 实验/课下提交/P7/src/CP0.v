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
    input  wire        clk,
    input  wire        reset,
    input  wire        req,
    input  wire [ 4:0] number,
    input  wire        write_enable,
    input  wire [31:0] write_data,
    input  wire [31:0] VPC,
    input  wire        BDIn,
    input  wire [ 4:0] ExcCodeIn,
    input  wire [ 5:0] HWInt,
    input  wire        EXLClr,
    output wire [31:0] read_data,
    output wire [31:0] EPCOut,
    output wire        Request
);
    reg [31:0] regfile[0:31];
    assign read_data = regfile[number];  // 无险情，无需内部转发
    assign EPCOut = !req && write_enable && number == `EPC_NUMBER ? write_data :
                     regfile[`EPC_NUMBER]; // 内部转发 EPC

    wire interupt = `IE & ~`EXL & |(`IM & HWInt); // 全局中断使能且不在异常处理状态且相应中断使能且相应中断请求
    wire exception = ~`EXL & |ExcCodeIn;  // 不在异常处理状态且有异常请求
    assign Request = exception | interupt;

`ifdef LOCAL
    wire [                     31:0] SR = `SR;
    wire [                     31:0] CAUSE = `CAUSE;
    wire [                     31:0] EPC = `EPC;
    wire [          `IM_MSB:`IM_LSB] IM = `IM;
    wire                             EXL = `EXL;
    wire                             IE = `IE;
    wire                             BD = `BD;
    wire [          `IP_MSB:`IP_LSB] IP = `IP;
    wire [`EXCCODE_MSB:`EXCCODE_LSB] EXCCODE = `EXCCODE;
`endif

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) regfile[i] <= 32'd0;
        end else begin
            `IP <= HWInt;
            if (EXLClr) begin  // 响应优先
                `EXL <= 1'b0;
            end else if (interupt) begin  // 中断次之
                `EXL     <= 1'b1;
                `EXCCODE <= `EXCCODE_INT;
                `BD      <= BDIn;
                `EPC     <= BDIn ? VPC - 32'd4 : VPC;
            end else if (exception) begin  // 异常再次
                `EXL     <= 1'b1;
                `EXCCODE <= ExcCodeIn;
                `BD      <= BDIn;
                `EPC     <= BDIn ? VPC - 32'd4 : VPC;
            end else if (write_enable && number != `CAUSE_NUMBER) begin  // 写入最次
                regfile[number] <= write_data;  // 规定不会写入CAUSE
            end
        end
    end
endmodule
