`include "macros.v"

module BE (
    input  wire [                31:0] ADDR,
    input  wire [                31:0] data_in,
    input  wire [`MEMWRITE_SIZE - 1:0] operation,
    output reg  [                31:0] data_out,
    output reg  [                 3:0] data_enable,
    output wire                        exception
);
    wire ADDR_valid = ADDR >= `DM_LSA && ADDR <= `DM_MSA ||
                      ADDR >= `TIMER0_LSA && ADDR <= `TIMER0_MSA ||
                      ADDR >= `TIMER1_LSA && ADDR <= `TIMER1_MSA ||
                      ADDR >= `INT_LSA && ADDR <= `INT_MSA;
    wire ADDR_Timer = ADDR >= `TIMER0_LSA && ADDR <= `TIMER0_MSA ||
                      ADDR >= `TIMER1_LSA && ADDR <= `TIMER1_MSA;
    wire ADDR_Count = ADDR >= `TIMER0_MSA - 32'd3  && ADDR <= `TIMER0_MSA ||
                      ADDR >= `TIMER1_MSA - 32'd3  && ADDR <= `TIMER1_MSA;
    assign exception = !ADDR_valid ||  // 超出地址空间
        operation == `MEMWRITE_WORD && ADDR[1:0] != 2'b00 ||  // 按字写未对齐
        operation == `MEMWRITE_HALF && (ADDR[1:0] != 2'b00 || ADDR[1:0] != 2'b10) || // 按半字写未对齐
        ADDR_Timer && (operation == `MEMWRITE_HALF || operation == `MEMWRITE_BYTE) || // Timer 只许按字写
        ADDR_Count && operation != `MEMWRITE_DISABLE;  // Count 寄存器只读

    always @(*) begin
        data_out = 32'h00000000;
        case (operation)
            `MEMWRITE_DISABLE: begin
                data_out    = 32'h00000000;
                data_enable = 4'b0000;
            end
            `MEMWRITE_BYTE: begin
                case (ADDR[1:0])
                    2'b00: begin
                        data_out[7:0] = data_in[7:0];
                        data_enable   = 4'b0001;
                    end
                    2'b01: begin
                        data_out[15:8] = data_in[7:0];
                        data_enable    = 4'b0010;
                    end
                    2'b10: begin
                        data_out[23:16] = data_in[7:0];
                        data_enable     = 4'b0100;
                    end
                    2'b11: begin
                        data_out[31:24] = data_in[7:0];
                        data_enable     = 4'b1000;
                    end
                    default: begin
                        data_out    = 32'hxxxxxxxx;
                        data_enable = 4'bxxxx;
                    end
                endcase
            end
            `MEMWRITE_HALF: begin
                case (ADDR[1:0])
                    2'b00: begin
                        data_out[15:0] = data_in[15:0];
                        data_enable    = 4'b0011;
                    end
                    2'b10: begin
                        data_out[31:16] = data_in[15:0];
                        data_enable     = 4'b1100;
                    end
                    default: begin
                        data_out    = 32'hxxxxxxxx;
                        data_enable = 4'bxxxx;
                    end
                endcase
            end
            `MEMWRITE_WORD: begin
                data_out    = data_in;
                data_enable = 4'b1111;
            end
            default: begin
                data_out    = 32'hxxxxxxxx;
                data_enable = 4'bxxxx;
            end
        endcase
    end
endmodule
