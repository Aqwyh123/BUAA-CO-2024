`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   10:11:14 08/22/2024
// Design Name:   id_fsm
// Module Name:   /home/Aqwyh/Documents/id_fsm/id_fsm_tb.v
// Project Name:  id_fsm
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: id_fsm
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module id_fsm_tb;

    // Inputs
    reg [7:0] char;
    reg clk;

    // Outputs
    wire out;

    // Instantiate the Unit Under Test (UUT)
    id_fsm uut (
        .char(char),
        .clk (clk),
        .out (out)
    );

    initial begin
        // Initialize Inputs
        char = 0;
        clk  = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        char = 8'h41;
        #10;
        char = 8'h42;
        #10;
        char = 8'h43;
        #10;
        char = 8'h44;
        #10;
        char = 8'h30;
        #10;
        char = 8'h31;
        #10;
        char = 8'h32;
        #10;
        char = 8'h33;
        #10;
        char = 8'h00;
        #10;
        char = 8'h41;
        #10;
        char = 8'h42;
        #10;
        char = 8'h30;
        #10;
        char = 8'h31;
        #10;

    end
    always #5 clk = ~clk;

endmodule
