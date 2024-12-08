`include "macros.v"

module mips (
    input  wire        clk,            // 时钟信号
    input  wire        reset,          // 同步复位信号
    input  wire        interrupt,      // 外部中断信号
    output wire [31:0] macroscopic_pc, // 宏观 PC

    output wire [31:0] i_inst_addr,  // IM 读取地址（取指 PC）
    input  wire [31:0] i_inst_rdata, // IM 读取数据

    output wire [31:0] m_data_addr,   // DM 读写地址
    input  wire [31:0] m_data_rdata,  // DM 读取数据
    output wire [31:0] m_data_wdata,  // DM 待写入数据
    output wire [ 3:0] m_data_byteen, // DM 字节使能信号

    output wire [31:0] m_int_addr,   // 中断发生器待写入地址
    output wire [ 3:0] m_int_byteen, // 中断发生器字节使能信号

    output wire [31:0] m_inst_addr,  // M 级 PC

    output wire        w_grf_we,    // GRF 写使能信号
    output wire [ 4:0] w_grf_addr,  // GRF 待写入寄存器编号
    output wire [31:0] w_grf_wdata, // GRF 待写入数据

    output wire [31:0] w_inst_addr  // W 级 PC
);
    wire [31:0] MEM_ADDR, MEM_WD;  // 内存逻辑地址，内存待写入数据
    wire [31:0] DEV_ADDR, DEV_WD;  // 外设物理地址，外设待写入数据

    wire [31:0] MEM_RD;  // 内存读取数据
    wire [31:0] DM_RD, timer0_RD, timer1_RD, INT_RD;  // 外设读取数据

    wire [3:0] MEM_WE;  // 内存字节使能信号
    wire timer0_WE, timer1_WE;  // 定时器写使能信号
    wire [3:0] DM_WE, INT_WE;  // 外设字节使能信号

    wire timer0_IRQ, timer1_IRQ;  // 定时器中断信号
    wire [5:0] IRQ = {3'b000, interrupt, timer1_IRQ, timer0_IRQ};  // 中断信号

    CPU cpu (  // CPU
        .clk             (clk),
        .reset           (reset),
        .HWInt           (IRQ),
        .PC              (macroscopic_pc),
        .IM_ADDR         (i_inst_addr),
        .IM_read_data    (i_inst_rdata),
        .MEM_ADDR        (MEM_ADDR),
        .MEM_read_data   (MEM_RD),
        .MEM_write_data  (MEM_WD),
        .MEM_write_enable(MEM_WE),
        .MEM_PC          (m_inst_addr),
        .GRF_write_enable(w_grf_we),
        .GRF_write_number(w_grf_addr),
        .GRF_write_data  (w_grf_wdata),
        .GRF_PC          (w_inst_addr)
    );

    Bridge bridge (
        .PrAddr   (MEM_ADDR),
        .PrRD     (MEM_RD),
        .PrWD     (MEM_WD),
        .PrWE     (MEM_WE),
        .DM_RD    (DM_RD),
        .timer0_RD(timer0_RD),
        .timer1_RD(timer1_RD),
        .INT_RD   (INT_RD),
        .DEV_Addr (DEV_ADDR),
        .DEV_WD   (DEV_WD),
        .DM_WE    (DM_WE),
        .timer0_WE(timer0_WE),
        .timer1_WE(timer1_WE),
        .INT_WE   (INT_WE)
    );

    assign m_data_addr   = DEV_ADDR;  // DM 读写地址
    assign m_data_wdata  = DEV_WD;  // DM 待写入数据
    assign m_data_byteen = DM_WE;  // DM 字节使能信号
    assign DM_RD         = m_data_rdata;  // DM 读取数据

    TC timer0 (  // 定时器 0
        .clk  (clk),
        .reset(reset),
        .Addr (DEV_ADDR[31:2]),
        .WE   (timer0_WE),
        .Din  (DEV_WD),
        .Dout (timer0_RD),
        .IRQ  (timer0_IRQ)
    );
    TC timer1 (  // 定时器 1
        .clk  (clk),
        .reset(reset),
        .Addr (DEV_ADDR[31:2]),
        .WE   (timer1_WE),
        .Din  (DEV_WD),
        .Dout (timer1_RD),
        .IRQ  (timer1_IRQ)
    );

    assign INT_RD       = 32'h00000000;  // 规定为 0
    assign m_int_addr   = DEV_ADDR;
    assign m_int_byteen = INT_WE;
endmodule
