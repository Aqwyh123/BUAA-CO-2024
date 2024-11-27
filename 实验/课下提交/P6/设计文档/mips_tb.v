`include "../src/macros.v"
`timescale 1ns / 1ps

module mips_txt;

    reg clk;
    reg reset;

    wire [31:0] i_inst_addr;
    wire [31:0] i_inst_rdata;

    wire [31:0] m_data_addr;
    wire [31:0] m_data_rdata;
    wire [31:0] m_data_wdata;
    wire [3 : 0] m_data_byteen;

    wire [31:0] m_inst_addr;

    wire w_grf_we;
    wire [4:0] w_grf_addr;
    wire [31:0] w_grf_wdata;

    wire [31:0] w_inst_addr;

    mips uut (
        .clk  (clk),
        .reset(reset),

        .i_inst_addr (i_inst_addr),
        .i_inst_rdata(i_inst_rdata),

        .m_data_addr  (m_data_addr),
        .m_data_rdata (m_data_rdata),
        .m_data_wdata (m_data_wdata),
        .m_data_byteen(m_data_byteen),

        .m_inst_addr(m_inst_addr),

        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),

        .w_inst_addr(w_inst_addr)
    );

    integer i;
    reg [31:0] fixed_addr;
    reg [31:0] fixed_wdata;
    reg [31:0] data[0:4095];
    reg [31:0] inst[0:4095];

    assign m_data_rdata = data[m_data_addr>>2];
    assign i_inst_rdata = inst[(i_inst_addr-32'h3000)>>2];

    initial begin
        $readmemh("code.txt", inst);
        for (i = 0; i < 4096; i = i + 1) data[i] <= 0;
    end

    initial begin
        clk   = 0;
        reset = 1;
        #20 reset = 0;
    end

`ifdef LOCAL
    integer fd, df;
    initial begin
        fd = $fopen("output.txt", "w");
        $fclose(fd);
        fd = $fopen("info.txt", "w");
        $fwrite(fd,
                "                Time :     F    |     D    |     E    |     M    |     W   \n");
        $fwrite(fd,
                "--------------------------------------------------------------------------\n");
        $fclose(fd);
    end
    always begin
        #2 if (!reset) begin
            fd = $fopen("info.txt", "a");
            $fwrite(fd, "%d : %h | %h | %h | %h | %h\n",
            $time, uut.F_PC, uut.D_PC, uut.E_PC, uut.M_PC, uut.W_PC);
            $fwrite(fd,
            "                     : %h | %h | %h | %h | %h\n",
            uut.F_instr, uut.D_instr, uut.E_instr, uut.M_instr, uut.W_instr);
            $fwrite(fd,
            "                                | %d %d  %d | %d %d %d | %d %d %d | %d %d %d\n",
            uut.D_Tuse_rs, uut.D_Tuse_rt, 3'bxxx,
            uut.E_Tuse_rs, uut.E_Tuse_rt, uut.E_Tnew,
            uut.M_Tuse_rs, uut.M_Tuse_rt, uut.M_Tnew,
            uut.W_Tuse_rs, uut.W_Tuse_rt, uut.W_Tnew);
            $fwrite(fd,
            "S : %d ; FT_D_RS : %d ; FT_D_RT : %d ; FT_E_RS : %d ; FT_E_RT : %d ; FT_M_RT : %d\n",
            uut.stall,
            uut.FWD_to_D_rs, uut.FWD_to_D_rt, uut.FWD_to_E_rs, uut.FWD_to_E_rt, uut.FWD_to_M_rt);
            $fwrite(fd,
            "--------------------------------------------------------------------------\n");
            $fclose(fd);
        end
    end
`endif

    always @(*) begin
        fixed_wdata = data[m_data_addr>>2];
        fixed_addr  = m_data_addr & 32'hfffffffc;
        if (m_data_byteen[3]) fixed_wdata[31:24] = m_data_wdata[31:24];
        if (m_data_byteen[2]) fixed_wdata[23:16] = m_data_wdata[23:16];
        if (m_data_byteen[1]) fixed_wdata[15:8] = m_data_wdata[15:8];
        if (m_data_byteen[0]) fixed_wdata[7 : 0] = m_data_wdata[7 : 0];
    end



    always @(posedge clk) begin
        if (~reset) begin
            if (w_grf_we && (w_grf_addr != 0)) begin
                $display("%d@%h: $%d <= %h", $time, w_inst_addr, w_grf_addr, w_grf_wdata);
`ifdef LOCAL
                df = $fopen("output.txt", "a");
                $fwrite(df, "@%h: $%d <= %h\n", w_inst_addr, w_grf_addr, w_grf_wdata);
                $fclose(df);
`endif
            end
        end
    end

always @(posedge clk) begin
        if (reset) for (i = 0; i < 4096; i = i + 1) data[i] <= 0;
        else if (|m_data_byteen) begin
            data[fixed_addr>>2] <= fixed_wdata;
            $display("%d@%h: *%h <= %h", $time, m_inst_addr, fixed_addr, fixed_wdata);
`ifdef LOCAL
            df = $fopen("output.txt", "a");
            $fwrite(df, "@%h: *%h <= %h\n", m_inst_addr, fixed_addr, fixed_wdata);
            $fclose(df);
`endif
        end
    end

    always #2 clk <= ~clk;
endmodule
