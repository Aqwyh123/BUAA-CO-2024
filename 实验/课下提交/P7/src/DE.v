`include "macros.v"

module DE (
    input  wire [            31:0] ADDR,
    input  wire [            31:0] data_in,
    input  wire [`DEOP_SIZE - 1:0] operation,
    output reg  [            31:0] data_out,
    output wire                    exception
);
    wire ADDR_valid = ADDR >= `DM_LSA && ADDR <= `DM_MSA ||
                      ADDR >= `TIMER0_LSA && ADDR <= `TIMER0_MSA ||
                      ADDR >= `TIMER1_LSA && ADDR <= `TIMER1_MSA ||
                      ADDR >= `INT_LSA && ADDR <= `INT_MSA;
    wire ADDR_Timer = ADDR >= `TIMER0_LSA && ADDR <= `TIMER0_MSA ||
                      ADDR >= `TIMER1_LSA && ADDR <= `TIMER1_MSA;
    wire operation_half = operation == `DEOP_HALF_UNSIGNED || operation == `DEOP_HALF_SIGNED;
    wire operation_byte = operation == `DEOP_BYTE_UNSIGNED || operation == `DEOP_BYTE_SIGNED;
    assign exception = !ADDR_valid ||  // 超出地址空间
        operation == `DEOP_WORD && ADDR[1:0] != 2'b00 ||  // 按字读未对齐
        operation_half && ADDR[0] == 1'b1 ||  // 按半字读未对齐
        ADDR_Timer && (operation_half || operation_byte);  // Timer 只许按字读

    always @(*) begin
        case (operation)
            `DEOP_NOOP: data_out = data_in;
            `DEOP_WORD: data_out = data_in;
            `DEOP_BYTE_UNSIGNED: begin
                case (ADDR[1:0])
                    2'b00:   data_out = {24'h000000, data_in[7:0]};
                    2'b01:   data_out = {24'h000000, data_in[15:8]};
                    2'b10:   data_out = {24'h000000, data_in[23:16]};
                    2'b11:   data_out = {24'h000000, data_in[31:24]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            `DEOP_BYTE_SIGNED: begin
                case (ADDR[1:0])
                    2'b00:   data_out = {{24{data_in[7]}}, data_in[7:0]};
                    2'b01:   data_out = {{24{data_in[15]}}, data_in[15:8]};
                    2'b10:   data_out = {{24{data_in[23]}}, data_in[23:16]};
                    2'b11:   data_out = {{24{data_in[31]}}, data_in[31:24]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            `DEOP_HALF_UNSIGNED: begin
                case (ADDR[1:0])
                    2'b00:   data_out = {16'h0000, data_in[15:0]};
                    2'b10:   data_out = {16'h0000, data_in[31:16]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            `DEOP_HALF_SIGNED: begin
                case (ADDR[1:0])
                    2'b00:   data_out = {{16{data_in[15]}}, data_in[15:0]};
                    2'b10:   data_out = {{16{data_in[31]}}, data_in[31:16]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            default:    data_out = 32'hxxxxxxxx;
        endcase
    end
endmodule
