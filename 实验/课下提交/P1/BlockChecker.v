`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:23:19 10/10/2024
// Design Name:
// Module Name:    BlockChecker
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
module BlockChecker (
    input clk,
    input reset,
    input [7:0] in,
    output result
);
    localparam SPACE = 10'b0000000001,ALPHA = 10'b0000000010,
  B = 10'b0000000100,E1 = 10'b0000001000,G = 10'b0000010000,
  I = 10'b0000100000, N1 = 10'b0001000000,E2 = 10'b0010000000,
  N2 = 10'b0100000000,D = 10'b1000000000;
    reg [9:0] state, next_state;
    reg signed [31:0] count, count_now;
    reg [2:0] op;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= SPACE;
        end else begin
            state <= next_state;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            count_now <= 0;
        end else if(count >= 0)begin
            if (next_state == N1) begin
                count_now <= count + 1;
            end else if (next_state == D) begin
                count_now <= count - 1;
            end else if(next_state != SPACE) begin
                count_now <= count;
            end
            if ((state == N1 || state == D) && next_state == SPACE) begin
                count <= count_now;
            end
        end
    end

    always @(*) begin
        case (state)
            SPACE: begin
                if (in == " ") next_state = SPACE;
                else if (in == "B" || in == "b") next_state = B;
                else if (in == "E" || in == "e") next_state = E2;
                else next_state = ALPHA;
            end
            ALPHA: begin
                if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            B: begin
                if (in == "E" || in == "e") next_state = E1;
                else if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            E1: begin
                if (in == "G" || in == "g") next_state = G;
                else if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            G: begin
                if (in == "I" || in == "i") next_state = I;
                else if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            I: begin
                if (in == "N" || in == "n") next_state = N1;
                else if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            N1: begin
                if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            E2: begin
                if (in == "N" || in == "n") next_state = N2;
                else if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            N2: begin
                if (in == "D" || in == "d") next_state = D;
                else if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            D: begin
                if (in == " ") next_state = SPACE;
                else next_state = ALPHA;
            end
            default: next_state = SPACE;
        endcase
    end

    assign result = count_now == 0;

endmodule
