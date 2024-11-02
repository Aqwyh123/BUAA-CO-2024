`default_nettype none // 强制使用显式端口声明

`define DEBUG // 是否综合

`ifdef DEBUG
`define INPUT_PATH "code.txt"

`define LOCAL // 是否本地调试

`ifdef LOCAL
`define OUTPUT_PATH "output.txt"
`endif

`endif

`define PC_INIT 32'h00003000

`define IM_BEGIN 3072
`define IM_SIZE 4096

`define DM_SIZE 3072

`define ALUSRC1_RS 1'b0
`define ALUSRC1_RT 1'b1
`define ALUSRC2_RT 3'b000
`define ALUSRC2_IMM_SHAMT 3'b001
`define ALUSRC2_ZERO 3'b010
`define ALUSRC2_S 3'b011
`define ALUSRC2_RS 3'b100

`define REGSRC_ALU 2'b00
`define REGSRC_MEM 2'b01

`define REGSRC_PC 2'b10
`define REGDST_RT 2'b00
`define REGDST_RD 2'b01
`define REGDST_RA 2'b10

`define MEMSRC_BYTE 2'b00
`define MEMSRC_HALF 2'b01
`define MEMSRC_WORD 2'b10

`define MEMDST_BYTE 3'b000
`define MEMDST_HALF 3'b001
`define MEMDST_WORD 3'b010
`define MEMDST_BYTEU 3'b100
`define MEMDST_HALFU 3'b101

`define BRANCH_ZERO 2'b01
`define BRANCH_NONZERO 2'b10

`define JUMP_INDEX 2'b01
`define JUMP_REG 2'b10

`define EXTOP_ZERO 2'b00
`define EXTOP_SIGN 2'b01
`define EXTOP_UPPER 2'b10

`define ALUOP_ADD 4'b0000
`define ALUOP_SUB 4'b0001
`define ALUOP_AND 4'b0010
`define ALUOP_OR 4'b0011
`define ALUOP_XOR 4'b0100
`define ALUOP_NOR 4'b0101
`define ALUOP_SLL 4'b0110
`define ALUOP_SRL 4'b0111
`define ALUOP_SRA 4'b1000
`define ALUOP_LT 4'b1001
`define ALUOP_GT 4'b1010
`define ALUOP_LTU 4'b1011
