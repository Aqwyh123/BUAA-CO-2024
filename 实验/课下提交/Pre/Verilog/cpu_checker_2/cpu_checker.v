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
    input [15:0] freq,
    output reg [1:0] format_type,
    output reg [3:0] error_code
);
    localparam IDLE = 4'b0000, START = 4'b0001, TIME = 4'b0010, AT = 4'b0011, PC = 4'b0100, COLON = 4'b0101, SIGN = 4'b0110, GRF_OR_ADDR = 4'b0111, SPACE = 4'b1000 ,LESS = 4'b1001, EQUAL = 4'b1010, DATA = 4'b1011, DONE = 4'b1100, ERROR = 4'b1101, ERROR_DONE = 4'b1110;
    localparam FORMAT_ERROR = 2'b00, FORMAT_GRF = 2'b01, FORMAT_ADDR = 2'b10;
    localparam ERROR_FORMAT_OR_CORRECT = 4'b0000, ERROR_TIME = 4'b0001, ERROR_PC = 4'b0010, ERROR_ADDR = 4'b0100, ERROR_GRF = 4'b1000;

    reg [3:0] state, next_state, error_code_temp;
    reg [1:0] format_type_temp;
    integer time_count, pc_count, grf_or_addr_count, data_count;
    reg [15:0] time_bcd, grf_bcd;
    reg [31:0] pc, addr;

    wire is_dec_char = char >= "0" && char <= "9";
    wire is_hex_char = is_dec_char || char >= "a" && char <= "f";
    wire [3:0] char_to_bin = is_dec_char ? char - "0" : char - "a" + 10;

    function automatic [15:0] bcd_to_bin;
        input [15:0] bcd;
        bcd_to_bin = (bcd[15:12]<<9) + (bcd[15:12]<<8) + (bcd[15:12]<<7) + (bcd[15:12]<<6) + (bcd[15:12]<<5) + (bcd[15:12]<<3) + (bcd[11:8]<<6) + (bcd[11:8]<<5) + (bcd[11:8]<<2) + (bcd[7:4]<<3) + (bcd[7:4]<<1) + bcd[3:0];
    endfunction

    wire [15:0] time_bin = bcd_to_bin(time_bcd);
    wire [15:0] grf_bin = bcd_to_bin(grf_bcd);

    always @(posedge clk) begin
        if (reset) begin
            format_type <= FORMAT_ERROR;
            error_code <= ERROR_FORMAT_OR_CORRECT;

            state <= IDLE;
            next_state <= IDLE;
            format_type_temp <= FORMAT_ERROR;
            error_code_temp <= ERROR_FORMAT_OR_CORRECT;

            time_count <= 0;
            pc_count <= 0;
            grf_or_addr_count <= 0;
            data_count <= 0;

            time_bcd <= 0;
            pc <= 0;
            grf_bcd <= 0;
            addr <= 0;
        end else state <= next_state;
    end

    always @(state, char, time_count, pc_count, grf_or_addr_count, data_count,format_type_temp) begin
        case (state)
            IDLE: next_state = char == "^" ? START : IDLE;
            START: begin
                if (is_hex_char) begin
                    next_state = TIME;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            TIME: begin
                if (char == "@") begin
                    next_state = time_count >= 1 && time_count <= 4 ? AT : ERROR;
                end else if (is_dec_char) begin
                    next_state = TIME;
                end else next_state = char == "#" ? ERROR_DONE : ERROR;
            end
            AT: begin
                if (is_hex_char) begin
                    next_state = PC;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            PC: begin
                if (char == ":") begin
                    next_state = pc_count == 8 ? COLON : ERROR;
                end else if (is_hex_char) begin
                    next_state = PC;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            COLON: begin
                if (char == " ") begin
                    next_state = COLON;
                end else if (char == "$" || char == 8'd42) begin
                    next_state = SIGN;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            SIGN: begin
                if (is_hex_char || is_dec_char) begin
                    next_state = GRF_OR_ADDR;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            GRF_OR_ADDR:
            case (format_type_temp)
                FORMAT_GRF: begin
                    if (char == " ") begin
                        next_state = grf_or_addr_count >= 1 && grf_or_addr_count <= 4 ? SPACE : ERROR;
                    end else if (char == "<") begin
                        next_state = grf_or_addr_count >= 1 && grf_or_addr_count <= 4 ? LESS : ERROR;
                    end else if (is_hex_char) begin
                        next_state = GRF_OR_ADDR;
                    end else begin
                        next_state = char == "#" ? ERROR_DONE : ERROR;
                    end
                end
                FORMAT_ADDR: begin
                    if (char == " ") begin
                        next_state = grf_or_addr_count == 8 ? SPACE : ERROR;
                    end else if (char == "<") begin
                        next_state = grf_or_addr_count == 8 ? LESS : ERROR;
                    end else if (is_hex_char) begin
                        next_state = GRF_OR_ADDR;
                    end else begin
                        next_state = char == "#" ? ERROR_DONE : ERROR;
                    end
                end
                default begin
                    next_state = next_state;
                end
            endcase
            SPACE: begin
                if (char == " ") begin
                    next_state = SPACE;
                end else if (char == "<") begin
                    next_state = LESS;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            LESS: begin
                if (char == "=") begin
                    next_state = EQUAL;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            EQUAL: begin
                if (char == " ") begin
                    next_state = EQUAL;
                end else if (is_hex_char) begin
                    next_state = DATA;
                end else begin
                    next_state = char == "#" ? ERROR_DONE : ERROR;
                end
            end
            DATA: begin
                if (char == "#") begin
                    next_state = data_count == 8 ? DONE : ERROR_DONE;
                end else if (is_hex_char) begin
                    next_state = DATA;
                end else begin
                    next_state = ERROR;
                end
            end
            DONE: next_state = char == "^" ? START : IDLE;
            ERROR: next_state = char == "#" ? ERROR_DONE : ERROR;
            ERROR_DONE: next_state = char == "^" ? START : IDLE;
            default: next_state = next_state;
        endcase
    end

    always @(posedge clk) begin
        if (next_state == TIME) begin
            time_count <= time_count + 1;
            time_bcd   <= {time_bcd[23:0], char_to_bin};
        end else if (next_state == PC) begin
            pc_count <= pc_count + 1;
            pc <= {pc[55:0], char_to_bin};
        end else if (next_state == GRF_OR_ADDR) begin
            grf_or_addr_count <= grf_or_addr_count + 1;
            if (format_type_temp == FORMAT_GRF) begin
                grf_bcd <= {grf_bcd[23:0], char_to_bin};
            end else if (format_type_temp == FORMAT_ADDR) begin
                addr <= {addr[55:0], char_to_bin};
            end
        end else if (next_state == DATA) begin
            data_count <= data_count + 1;
        end else if (next_state == START) begin
            time_count <= 0;
            pc_count <= 0;
            grf_or_addr_count <= 0;
            data_count <= 0;

            time_bcd <= 0;
            pc <= 0;
            grf_bcd <= 0;
            addr <= 0;
        end
    end

    always @(char) begin
        if (char == "$") begin
            format_type_temp = FORMAT_GRF;
        end else if (char == 8'd42) begin
            format_type_temp = FORMAT_ADDR;
        end else begin
            format_type_temp = format_type_temp;
        end
    end

    always @(char, time_bin, grf_bin, pc, addr, format_type_temp, freq) begin
        if (char == "^") begin
            error_code_temp = ERROR_FORMAT_OR_CORRECT;
        end else begin
            if ((time_bin & (freq >> 1) - 16'd1) == 0) begin
                error_code_temp = error_code_temp & ~ERROR_TIME;
            end else begin
                error_code_temp = error_code_temp | ERROR_TIME;
            end
            if (pc >= 32'h0000_3000 && pc <= 32'h0000_4fff && (pc & 32'd4 - 32'd1) == 0) begin
                error_code_temp = error_code_temp & ~ERROR_PC;
            end else begin
                error_code_temp = error_code_temp | ERROR_PC;
            end
            case (format_type_temp)
                FORMAT_GRF: begin
                    if (grf_bin <= 16'd31) begin
                        error_code_temp = error_code_temp & ~ERROR_GRF;
                    end else begin
                        error_code_temp = error_code_temp | ERROR_GRF;
                    end
                end
                FORMAT_ADDR: begin
                    if (addr <= 32'h0000_2fff && (addr & 32'd4 - 32'd1) == 0) begin
                        error_code_temp = error_code_temp & ~ERROR_ADDR;
                    end else begin
                        error_code_temp = error_code_temp | ERROR_ADDR;
                    end
                end
                default error_code_temp = error_code_temp;
            endcase
        end
    end

    always @(state) begin
        if (state == DONE) begin
            format_type = format_type_temp;
            error_code  = error_code_temp;
        end else begin
            format_type = FORMAT_ERROR;
            error_code  = ERROR_FORMAT_OR_CORRECT;
        end
    end
endmodule
