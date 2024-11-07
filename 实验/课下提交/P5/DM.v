`include "macros.v"
module DM (
    input wire clk,
    input wire reset,
    input wire [31:0] ADDR,
    input wire [31:0] write_data_raw,
    input wire [3:0] operation,
`ifdef DEBUG
    input wire [31:0] PC,
`endif
    output reg [31:0] read_data
);
`ifdef DEBUG
`ifdef LOCAL
    integer fd;
`endif
`endif

    reg [31:0] memory[0:`DM_SIZE - 1];

// 读取
    wire [31:0] read_raw_data = memory[ADDR>>2]; // 原始读取数据
    always @(*) begin
        case (operation[3:1])
            `DMOP_WORD: read_data = read_raw_data;
            `DMOP_BYTE: begin
                case (ADDR[1:0])
                    2'b00: read_data = {{24{read_raw_data[7]}}, read_raw_data[7:0]};
                    2'b01: read_data = {{24{read_raw_data[15]}}, read_raw_data[15:8]};
                    2'b10: read_data = {{24{read_raw_data[23]}}, read_raw_data[23:16]};
                    2'b11: read_data = {{24{read_raw_data[31]}}, read_raw_data[31:24]};
                    default read_data = 32'hffffffff;
                endcase
            end
            `DMOP_HALF: begin
                case (ADDR[1:0])
                    2'b00: read_data = {{16{read_raw_data[15]}}, read_raw_data[15:0]};
                    2'b10: read_data = {{16{read_raw_data[31]}}, read_raw_data[31:16]};
                    default read_data = 32'hffffffff;
                endcase
            end
            `DMOP_BYTEU: begin
                case (ADDR[1:0])
                    2'b00: read_data = {24'd0, read_raw_data[7:0]};
                    2'b01: read_data = {24'd0, read_raw_data[15:8]};
                    2'b10: read_data = {24'd0, read_raw_data[23:16]};
                    2'b11: read_data = {24'd0, read_raw_data[31:24]};
                    default read_data = 32'hffffffff;
                endcase
            end
            `DMOP_HALFU: begin
                case (ADDR[1:0])
                    2'b00: read_data = {16'd0, read_raw_data[15:0]};
                    2'b10: read_data = {16'd0, read_raw_data[31:16]};
                    default read_data = 32'hffffffff;
                endcase
            end
            default read_data = 32'hffffffff;
        endcase
    end

// 写入
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < `DM_SIZE; i = i + 1) begin
                memory[i] <= 32'd0;
            end
        end else if (operation[0]) begin
            case (operation[3:1])
                `DMOP_WORD: begin
                    memory[ADDR>>2] <= write_data_raw;
`ifdef DEBUG
                    $display("%d@%h: *%h <= %h", $time, PC, {ADDR[31:2], 2'b00}, write_data_raw);
`ifdef LOCAL
                    fd = $fopen(`OUTPUT_PATH, "a");
                    $fwrite(fd, "%d@%h: *%h <= %h\n", $time, PC, {ADDR[31:2], 2'b00},
                            write_data_raw);
                    $fclose(fd);
`endif
`endif
                end
                `DMOP_BYTE: begin
                    case (ADDR[1:0])
                        2'b00: memory[ADDR>>2][7:0] <= write_data_raw[7:0];
                        2'b01: memory[ADDR>>2][15:8] <= write_data_raw[7:0];
                        2'b10: memory[ADDR>>2][23:16] <= write_data_raw[7:0];
                        2'b11: memory[ADDR>>2][31:24] <= write_data_raw[7:0];
                    endcase
`ifdef DEBUG
                    $display("%d@%h: *%h <= %h", $time, PC, {ADDR[31:2], 2'b00},
                             write_data_raw[7:0]);
`ifdef LOCAL
                    fd = $fopen(`OUTPUT_PATH, "a");
                    $fwrite(fd, "%d@%h: *%h <= %h\n", $time, PC, {ADDR[31:2], 2'b00},
                            write_data_raw[7:0]);
                    $fclose(fd);
`endif
`endif
                end
                `DMOP_HALF: begin
                    case (ADDR[1:0])
                        2'b00: memory[ADDR>>2][15:0] <= write_data_raw[15:0];
                        2'b10: memory[ADDR>>2][31:16] <= write_data_raw[15:0];
                    endcase
`ifdef DEBUG
                    $display("%d@%h: *%h <= %h", $time, PC, {ADDR[31:2], 2'b00},
                             write_data_raw[15:0]);
`ifdef LOCAL
                    fd = $fopen(`OUTPUT_PATH, "a");
                    $fwrite(fd, "%d@%h: *%h <= %h\n", $time, PC, {ADDR[31:2], 2'b00},
                            write_data_raw[15:0]);
                    $fclose(fd);
`endif
`endif
                end
            endcase
        end
    end
endmodule
