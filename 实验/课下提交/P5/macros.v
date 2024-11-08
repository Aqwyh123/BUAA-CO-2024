`ifndef MACROS_V
`define MACROS_V

`default_nettype none  // 强制使用显式端口声明

`define DEBUG // 是否综合

`ifdef DEBUG
`define INPUT_PATH "code.txt"

// `define LOCAL // 是否本地调试

`ifdef LOCAL
`define OUTPUT_PATH "output.txt"
`endif

`endif

`define PC_INIT 32'h00003000
`define IM_BEGIN 3072
`define IM_SIZE 4096
`define DM_SIZE 3072

`define STAGE_DEFAULT 0
`define STAGE_FETCH 0
`define STAGE_DECODE 1
`define STAGE_EXECUTE 2
`define STAGE_MEMORY 3
`define STAGE_WRITEBACK 4

`define OPCODE_MSB 31
`define OPCODE_LSB 26
`define FUNCT_MSB 5
`define FUNCT_LSB 0
`define RS_MSB 25
`define RS_LSB 21
`define RT_MSB 20
`define RT_LSB 16
`define RD_MSB 15
`define RD_LSB 11
`define SHAMT_MSB 10
`define SHAMT_LSB 6
`define IMM_OFF_MSB 15
`define IMM_OFF_LSB 0
`define INDEX_MSB 25
`define INDEX_LSB 0

`define T_USE_IGNORE 2'd3
`define T_NEW_IGNORE 2'd0

`define EXTOP_SIZE 2
`define EXTOP_IGNORE 2'b00
`define EXTOP_ZERO 2'b00
`define EXTOP_SIGN 2'b01
`define EXTOP_UPPER 2'b10

`define CMPSRC_SIZE 1
`define CMPSRC_IGNORE 1'b0
`define CMPSRC_RT 1'b0
`define CMPSRC_ZERO 1'b1

`define CMPOP_SIZE 3
`define CMPOP_IGNORE 3'b000
`define CMPOP_EQ 3'b000
`define CMPOP_NE 3'b001
`define CMPOP_LT 3'b010
`define CMPOP_LE 3'b011
`define CMPOP_GT 3'b100
`define CMPOP_GE 3'b101

`define BRANCH_SIZE 2
`define BRANCH_DISABLE 2'b00
`define BRANCH_COND 2'b01
`define BRANCH_COND_LINK 2'b10

`define JUMP_SIZE 2
`define JUMP_DISABLE 2'b00
`define JUMP_INDEX 2'b01
`define JUMP_REG 2'b10

`define ALUSRC_SIZE 3
`define ALUSRC_IGNORE 3'b000
`define ALUSRC1_RS 1'b0
`define ALUSRC1_RT 1'b1
`define ALUSRC2_RT 2'b00
`define ALUSRC2_IMM_SHAMT 2'b01
`define ALUSRC2_S 2'b10
`define ALUSRC2_RS 2'b11

`define REGSRC_SIZE 2
`define REGSRC_IGNORE 2'b00
`define REGSRC_ALU 2'b00
`define REGSRC_MEM 2'b01
`define REGSRC_PC 2'b10

`define REGDST_SIZE 2
`define REGDST_IGNORE 2'b00
`define REGDST_RT 2'b00
`define REGDST_RD 2'b01
`define REGDST_RA 2'b10

`define REGWRITE_SIZE 1
`define REGWRITE_DISABLE 1'b0
`define REGWRITE_ENABLE 1'b1

`define ALUOP_SIZE 4
`define ALUOP_IGNORE 4'b0000
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
`define ALUOP_LTU 4'b1011

`define DMOP_SIZE 4
`define DMOP_IGNORE 4'b0000
`define DMOP_WORD 3'b000
`define DMOP_BYTE 3'b001
`define DMOP_HALF 3'b010
`define DMOP_BYTEU 3'b011
`define DMOP_HALFU 3'b100
`define MEMREAD 1'b0
`define MEMWRITE 1'b1

`endif
