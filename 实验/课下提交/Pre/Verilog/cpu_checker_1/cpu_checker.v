`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:03:49 08/22/2024
// Design Name:
// Module Name:    cpu_checker
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
module cpu_checker (
    input clk,
    input reset,
    input [7:0] char,
    output reg [1:0] format_type
);
    localparam IDLE = 4'b0000, START = 4'b0001, TIME = 4'b0010, AT = 4'b0011, PC = 4'b0100, COLON = 4'b0101, SIGN = 4'b0110, GRF_OR_ADDR = 4'b0111, SPACE = 4'b1000 ,LESS = 4'b1001, EQUAL = 4'b1010, DATA = 4'b1011, DONE = 4'b1100, ERROR = 4'b1101;
    localparam NONE = 2'b00, GRF = 2'b01, ADDR = 2'b10;

    reg [3:0] state, next_state;
    reg [1:0] grf_or_addr;
    integer time_count, pc_count, grf_or_addr_count, data_count;

    wire dec = char >= 8'd48 && char <= 8'd57;
    wire hex = char >= 8'd48 && char <= 8'd57 || char >= "a" && char <= "f";

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            next_state <= IDLE;
            grf_or_addr <= NONE;
            time_count <= 0;
            pc_count <= 0;
            grf_or_addr_count <= 0;
            data_count <= 0;
        end else state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: next_state = char == "^" ? START : IDLE;
            START: next_state = dec ? TIME : ERROR;
            TIME: begin
                if (char == "@") begin
                    next_state = time_count >= 1 && time_count <= 4 ? AT : ERROR;
                end else begin
                    next_state = dec ? TIME : ERROR;
                end
            end
            AT: next_state = hex ? PC : ERROR;
            PC: begin
                if (char == ":") begin
                    next_state = pc_count == 8 ? COLON : ERROR;
                end else begin
                    next_state = hex ? PC : ERROR;
                end
            end
            COLON: begin
                next_state = char == " " ? COLON : char == "$" || char == "*" ? GRF_OR_ADDR : ERROR;
                grf_or_addr = char == "$" ? GRF : char == "*" ? ADDR : NONE;
            end
            GRF_OR_ADDR: begin
                if (grf_or_addr == GRF) begin
                    if (char == " ") begin
                        next_state = grf_or_addr_count >=1 && grf_or_addr_count<=4 ? SPACE : ERROR;
                    end else if (char == "<") begin
                        next_state = grf_or_addr_count >=1 && grf_or_addr_count<=4 ? LESS : ERROR;
                    end else begin
                        next_state = dec ? GRF_OR_ADDR : ERROR;
                    end
                end else if (grf_or_addr == ADDR) begin
                    if (char == " ") begin
                        next_state = grf_or_addr_count == 8 ? SPACE : ERROR;
                    end else if (char == "<") begin
                        next_state = grf_or_addr_count == 8 ? LESS : ERROR;
                    end else begin
                        next_state = hex ? GRF_OR_ADDR : ERROR;
                    end
                end
            end
            SPACE: next_state = char == " " ? SPACE : char == "<" ? LESS : ERROR;
            LESS: next_state = char == "=" ? EQUAL : ERROR;
            EQUAL: next_state = char == " " ? EQUAL : hex ? DATA : ERROR;
            DATA: begin
                if (char == "#") begin
                    next_state = data_count == 8 ? DONE : ERROR;
                end else begin
                    next_state = hex ? DATA : ERROR;
                end
            end
            DONE: next_state = char == "^" ? START : ERROR;
            ERROR: next_state = char == "^" ? START : ERROR;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (next_state == TIME) begin
            time_count <= time_count + 1;
        end else if (next_state == PC) begin
            pc_count <= pc_count + 1;
        end else if (state == GRF_OR_ADDR) begin
            grf_or_addr_count <= grf_or_addr_count + 1;
        end else if (next_state == DATA) begin
            data_count <= data_count + 1;
        end else if (next_state == START) begin
            grf_or_addr <= NONE;
            time_count <= 0;
            pc_count <= 0;
            grf_or_addr_count <= 0;
            data_count <= 0;
        end
    end

    always @(*) begin
        if (state == DONE) begin
            format_type = grf_or_addr == GRF ? GRF : (grf_or_addr == ADDR ? ADDR : NONE);
        end else begin
            format_type = NONE;
        end
    end
endmodule
