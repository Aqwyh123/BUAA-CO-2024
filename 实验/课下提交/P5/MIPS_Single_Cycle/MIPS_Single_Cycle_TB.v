`include "../macros.v"
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   11:34:23 11/01/2024
// Design Name:   MIPS
// Module Name:   /home/Aqwyh/Documents/P4/MIPS_Single_Cycle/MIPS_Single_Cycle_TB.v
// Project Name:  MIPS_Single_Cycle
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: MIPS
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module MIPS_Single_Cycle_TB;

    // Inputs
    reg clk;
    reg reset;

    // Instantiate the Unit Under Test (UUT)
    mips uut (
        .clk  (clk),
        .reset(reset)
    );

    integer fd;

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;
`ifdef LOCAL
        fd = $fopen("info.txt", "w");
        $fwrite(fd, "                Time :     F    |     D    |     E    |     M    |     W   \n");
        $fwrite(fd, "--------------------------------------------------------------------------\n");
        $fclose(fd);
`endif
    end
    always #5 clk = ~clk;
`ifdef LOCAL
    always begin
        #10 if (!reset) begin
            fd = $fopen("info.txt", "a");
            $fwrite(fd, "%d : %h | %h | %h | %h | %h\n", $time, uut.F_instruction, uut.D_instruction, uut.E_instruction, uut.M_instruction, uut.W_instruction);
            $fwrite(fd, "                                | %d  %d  %d  | %d  %d  %d  | %d  %d  %d  | %d  %d  %d\n", uut.D_T_use_rs_base, uut.D_T_use_rt, 1'bx,
            uut.E_T_use_rs_base, uut.E_T_use_rt, uut.E_T_new,
            uut.M_T_use_rs_base, uut.M_T_use_rt, uut.M_T_new,
            uut.W_T_use_rs_base, uut.W_T_use_rt, uut.W_T_new);
            $fwrite(fd, "S : %d ; FT_D_RS : %d ; FT_D_RT : %d ; FT_E_RS : %d ; FT_E_RT : %d ; FT_M_RT : %d\n", uut.stall, uut.FWD_to_D_rs_base, uut.FWD_to_D_rt, uut.FWD_to_E_rs_base, uut.FWD_to_E_rt, uut.FWD_to_M_rt);
            $fwrite(fd, "--------------------------------------------------------------------------\n");
            $fclose(fd);
        end
    end
`endif
endmodule
