`include "macros.v"

module BE (
    input wire [1:0] ADDR,
    input wire [31:0] data_in,
    input wire [`BEOP_SIZE - 1:0] operation,
    output reg [31:0] data_out
);
    always @(*) begin
        case (operation)
            `BEOP_NOOP: data_out = data_in;
            `BEOP_BYTE_UNSIGNED: begin
                case (ADDR)
                    2'b00:   data_out = {24'h000000, data_in[7:0]};
                    2'b01:   data_out = {24'h000000, data_in[15:8]};
                    2'b10:   data_out = {24'h000000, data_in[23:16]};
                    2'b11:   data_out = {24'h000000, data_in[31:24]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            `BEOP_BYTE_SIGNED: begin
                case (ADDR)
                    2'b00:   data_out = {{24{data_in[7]}}, data_in[7:0]};
                    2'b01:   data_out = {{24{data_in[15]}}, data_in[15:8]};
                    2'b10:   data_out = {{24{data_in[23]}}, data_in[23:16]};
                    2'b11:   data_out = {{24{data_in[31]}}, data_in[31:24]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            `BEOP_HALF_UNSIGNED: begin
                case (ADDR)
                    2'b00:   data_out = {16'h0000, data_in[15:0]};
                    2'b10:   data_out = {16'h0000, data_in[23:8]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            `BEOP_HALF_SIGNED: begin
                case (ADDR)
                    2'b00:   data_out = {{16{data_in[15]}}, data_in[15:0]};
                    2'b10:   data_out = {{16{data_in[23]}}, data_in[23:8]};
                    default: data_out = 32'hxxxxxxxx;
                endcase
            end
            default: data_out = 32'hxxxxxxxx;
        endcase
    end
endmodule
