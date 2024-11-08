`include "macros.v"
module HazardControl (
    input wire [4:0] D_rs_base,
    input wire [4:0] D_rt,
    input wire [4:0] E_rs_base,
    input wire [4:0] E_rt,
    input wire [4:0] M_rs_base,
    input wire [4:0] M_rt,
    input wire [4:0] D_REG_write_number,
    input wire [4:0] E_REG_write_number,
    input wire [4:0] M_REG_write_number,
    input wire [1:0] D_T_use_rs_base,
    input wire [1:0] D_T_use_rt,
    input wire [1:0] D_T_new,
    input wire [1:0] E_T_use_rs_base,
    input wire [1:0] E_T_use_rt,
    input wire [1:0] E_T_new,
    input wire [1:0] M_T_use_rs_base,
    input wire [1:0] M_T_use_rt,
    input wire [1:0] M_T_new,
    output wire stall
);
    wire E_stall_rs = E_REG_write_number == D_rs_base && E_REG_write_number != 5'd0 && E_T_new > D_T_use_rs_base;
    wire E_stall_rt = E_REG_write_number == D_rt && E_REG_write_number != 5'd0 && E_T_new > D_T_use_rt;
    wire M_stall_rs = M_REG_write_number == D_rs_base && M_REG_write_number != 5'd0 && M_T_new > D_T_use_rs_base;
    wire M_stall_rt = M_REG_write_number == D_rt && M_REG_write_number != 5'd0 && M_T_new > D_T_use_rt;
    assign stall = E_stall_rs || E_stall_rt || M_stall_rs || M_stall_rt;

endmodule
