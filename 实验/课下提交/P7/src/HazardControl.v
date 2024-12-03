`include "macros.v"

module HazardControl (
    input wire [4:0] D_rs,
    input wire [4:0] D_rt,
    input wire signed [`T_SIZE - 1:0] D_Tuse_rs,
    input wire signed [`T_SIZE - 1:0] D_Tuse_rt,
    input wire D_request,
    input wire [4:0] E_rs,
    input wire [4:0] E_rt,
    input wire [4:0] E_REG_write_number,
    input wire E_REG_write_enable,
    input wire signed [`T_SIZE - 1:0] E_Tuse_rs,
    input wire signed [`T_SIZE - 1:0] E_Tuse_rt,
    input wire signed [`T_SIZE - 1:0] E_Tnew,
    input wire E_busy,
    input wire signed [`T_SIZE - 1:0] M_Tuse_rs,
    input wire signed [`T_SIZE - 1:0] M_Tuse_rt,
    input wire signed [`T_SIZE - 1:0] M_Tnew,
    input wire [4:0] M_rs,
    input wire [4:0] M_rt,
    input wire [4:0] M_REG_write_number,
    input wire M_REG_write_enable,
    input wire signed [`T_SIZE - 1:0] W_Tuse_rs,
    input wire signed [`T_SIZE - 1:0] W_Tuse_rt,
    input wire signed [`T_SIZE - 1:0] W_Tnew,
    input wire [4:0] W_rs,
    input wire [4:0] W_rt,
    input wire [4:0] W_REG_write_number,
    input wire W_REG_write_enable,
    output wire stall,
    output wire [`FWD_FROM_SIZE - 1:0] FWD_to_D_rs,
    output wire [`FWD_FROM_SIZE - 1:0] FWD_to_D_rt,
    output wire [`FWD_FROM_SIZE - 1:0] FWD_to_E_rs,
    output wire [`FWD_FROM_SIZE - 1:0] FWD_to_E_rt,
    output wire [`FWD_FROM_SIZE - 1:0] FWD_to_M_rt
);
    wire E_to_D_A_rs = E_REG_write_enable && E_REG_write_number != 5'd0 &&
                       E_REG_write_number == D_rs &&  D_Tuse_rs != `TUSE_IGNORE;
    wire E_to_D_A_rt = E_REG_write_enable && E_REG_write_number != 5'd0 &&
                       E_REG_write_number == D_rt &&  D_Tuse_rt != `TUSE_IGNORE;
    wire M_to_D_A_rs = M_REG_write_enable && M_REG_write_number != 5'd0 &&
                       M_REG_write_number == D_rs &&  D_Tuse_rs != `TUSE_IGNORE;
    wire M_to_D_A_rt = M_REG_write_enable && M_REG_write_number != 5'd0 &&
                       M_REG_write_number == D_rt &&  D_Tuse_rt != `TUSE_IGNORE;
    wire M_to_E_A_rs = M_REG_write_enable && M_REG_write_number != 5'd0 &&
                       M_REG_write_number == E_rs &&  E_Tuse_rs != `TUSE_IGNORE;
    wire M_to_E_A_rt = M_REG_write_enable && M_REG_write_number != 5'd0 &&
                       M_REG_write_number == E_rt &&  E_Tuse_rt != `TUSE_IGNORE;
    wire W_to_E_A_rs = W_REG_write_enable && W_REG_write_number != 5'd0 &&
                       W_REG_write_number == E_rs &&  E_Tuse_rs != `TUSE_IGNORE;
    wire W_to_E_A_rt = W_REG_write_enable && W_REG_write_number != 5'd0 &&
                       W_REG_write_number == E_rt &&  E_Tuse_rt != `TUSE_IGNORE;
    wire W_to_M_A_rt = W_REG_write_enable && W_REG_write_number != 5'd0 &&
                       W_REG_write_number == M_rt &&  M_Tuse_rt != `TUSE_IGNORE;

    wire E_stall_rs = E_to_D_A_rs && E_Tnew > D_Tuse_rs;
    wire E_stall_rt = E_to_D_A_rt && E_Tnew > D_Tuse_rt;
    wire E_stall_hl = D_request && E_busy;
    wire M_stall_rs = M_to_D_A_rs && M_Tnew > D_Tuse_rs;
    wire M_stall_rt = M_to_D_A_rt && M_Tnew > D_Tuse_rt;

    assign stall = E_stall_rs || E_stall_rt || E_stall_hl || M_stall_rs || M_stall_rt;
    assign FWD_to_D_rs = E_to_D_A_rs && E_Tnew == 2'd0 ? `FWD_FROM_DE :
                         M_to_D_A_rs && M_Tnew == 2'd0 ? `FWD_FROM_EM :
                         `FWD_FROM_DISABLE;
    assign FWD_to_D_rt = E_to_D_A_rt && E_Tnew == 2'd0 ? `FWD_FROM_DE :
                         M_to_D_A_rt && M_Tnew == 2'd0 ? `FWD_FROM_EM :
                         `FWD_FROM_DISABLE;
    assign FWD_to_E_rs = M_to_E_A_rs && M_Tnew == 2'd0 ? `FWD_FROM_EM :
                         W_to_E_A_rs && W_Tnew == 2'd0 ? `FWD_FROM_MW :
                         `FWD_FROM_DISABLE;
    assign FWD_to_E_rt = M_to_E_A_rt && M_Tnew == 2'd0 ? `FWD_FROM_EM :
                         W_to_E_A_rt && W_Tnew == 2'd0 ? `FWD_FROM_MW :
                         `FWD_FROM_DISABLE;
    assign FWD_to_M_rt = W_to_M_A_rt && W_Tnew == 2'd0 ? `FWD_FROM_MW : `FWD_FROM_DISABLE;
endmodule
