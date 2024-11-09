`include "macros.v"
module HazardControl (
    input wire [4:0] D_rs_base,
    input wire [4:0] D_rt,
    input wire [1:0] D_T_use_rs_base,
    input wire [1:0] D_T_use_rt,
    input wire [4:0] E_rs_base,
    input wire [4:0] E_rt,
    input wire [4:0] E_REG_write_number,
    input wire E_REG_write_enable,
    input wire [1:0] E_T_use_rs_base,
    input wire [1:0] E_T_use_rt,
    input wire [1:0] E_T_new,
    input wire [1:0] M_T_use_rs_base,
    input wire [1:0] M_T_use_rt,
    input wire [1:0] M_T_new,
    input wire [4:0] M_rs_base,
    input wire [4:0] M_rt,
    input wire [4:0] M_REG_write_number,
    input wire M_REG_write_enable,
    input wire [1:0] W_T_use_rs_base,
    input wire [1:0] W_T_use_rt,
    input wire [1:0] W_T_new,
    input wire [4:0] W_rs_base,
    input wire [4:0] W_rt,
    input wire [4:0] W_REG_write_number,
    input wire W_REG_write_enable,
    output wire stall,
    output wire [1:0] FWD_to_D_rs_base,
    output wire [1:0] FWD_to_D_rt,
    output wire [1:0] FWD_to_E_rs_base,
    output wire [1:0] FWD_to_E_rt,
    output wire [1:0] FWD_to_M_rt
);
    wire E_to_D_A_rs_base = E_REG_write_enable && E_REG_write_number == D_rs_base && E_REG_write_number != 5'd0; // E -> D
    wire E_to_D_A_rt = E_REG_write_enable && E_REG_write_number == D_rt && E_REG_write_number != 5'd0; // E -> D
    wire E_stall_rs = E_to_D_A_rs_base && E_T_new > D_T_use_rs_base;
    wire E_stall_rt = E_to_D_A_rt && E_T_new > D_T_use_rt;

    wire M_to_D_A_rs_base = M_REG_write_enable && M_REG_write_number == D_rs_base && M_REG_write_number != 5'd0; // M -> D
    wire M_to_D_A_rt = M_REG_write_enable && M_REG_write_number == D_rt && M_REG_write_number != 5'd0; // M -> D
    wire M_stall_rs = M_to_D_A_rs_base && M_T_new > D_T_use_rs_base;
    wire M_stall_rt = M_to_D_A_rt && M_T_new > D_T_use_rt;

    assign stall = E_stall_rs || E_stall_rt || M_stall_rs || M_stall_rt;

    wire W_to_E_A_rs_base = W_REG_write_enable && W_REG_write_number == E_rs_base && W_REG_write_number != 5'd0; // W -> E
    wire W_to_E_A_rt = W_REG_write_enable && W_REG_write_number == E_rt && W_REG_write_number != 5'd0;  // W -> E

    wire W_to_M_A_rs_base = W_REG_write_enable && W_REG_write_number == M_rs_base && W_REG_write_number != 5'd0; // W -> M
    wire W_to_M_A_rt = W_REG_write_enable && W_REG_write_number == M_rt && W_REG_write_number != 5'd0; // W -> M

    assign FWD_to_D_rs_base = E_to_D_A_rs_base && E_T_new == 2'd0 ? `FWD_FROM_DE_PC8 :
                              M_to_D_A_rs_base && M_T_new == 2'd0 ? `FWD_FROM_EM_ALU : `FWD_DISABLE;
    assign FWD_to_D_rt = E_to_D_A_rt && E_T_new == 2'd0 ? `FWD_FROM_DE_PC8 :
                         M_to_D_A_rt && M_T_new == 2'd0 ? `FWD_FROM_EM_ALU : `FWD_DISABLE;
    assign FWD_to_E_rs_base = W_to_E_A_rs_base && W_T_new == 2'd0 ? `FWD_FROM_MW_MEM : `FWD_DISABLE;
    assign FWD_to_E_rt = W_to_E_A_rt && W_T_new == 2'd0 ? `FWD_FROM_MW_MEM : `FWD_DISABLE;
    assign FWD_to_M_rt = W_to_M_A_rt && W_T_new == 2'd0 ? `FWD_FROM_MW_MEM : `FWD_DISABLE;

endmodule
