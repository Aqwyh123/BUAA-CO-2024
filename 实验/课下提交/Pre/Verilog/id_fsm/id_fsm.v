`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:09:56 08/22/2024
// Design Name:
// Module Name:    id_fsm
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module id_fsm (
    input [7:0] char,
    input clk,
    output out
);
    localparam ERROR = 2'b00, ALPHA = 2'b01, DIGIT = 2'b10;
    reg [1:0] state = ERROR, next_state = ERROR;
    always @(posedge clk) begin
        state <= next_state;
    end
    always @(*) begin
        case (state)
            ERROR:
            next_state <= (char >= 8'h41 && char <= 8'h5A) || (char >= 8'h61 && char <= 8'h7A) ? ALPHA : ERROR;
            ALPHA:
            next_state <= (char >= 8'h30 && char <= 8'h39) ? DIGIT :
                        (char >= 8'h41 && char <= 8'h5A) || (char >= 8'h61 && char <= 8'h7A) ? ALPHA : ERROR;
            DIGIT:
            next_state <= (char >= 8'h30 && char <= 8'h39) ? DIGIT :
                        (char >= 8'h41 && char <= 8'h5A) || (char >= 8'h61 && char <= 8'h7A) ? ALPHA : ERROR;
            default : next_state <=ERROR;
        endcase
    end
    assign out = state == DIGIT;

endmodule
