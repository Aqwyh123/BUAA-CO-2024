`ifndef MACROS_V
`define MACROS_V

`default_nettype none  // 强制使用显式端口声明

// `define LOCAL // 是否本地测试
`ifdef LOCAL
`timescale 1ns / 1ps
`endif

// 指令格式定义
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
`define IMM_MSB 15
`define IMM_LSB 0
`define INDEX_MSB 25
`define INDEX_LSB 0

// 内存地址空间定义
`define DM_LSA 32'h00000000
`define DM_MSA 32'h00002fff
`define IM_LSA 32'h00003000
`define IM_MSA 32'h00006fff
`define TIMER0_LSA 32'h00007f00
`define TIMER0_MSA 32'h00007f0b
`define TIMER1_LSA 32'h00007f10
`define TIMER1_MSA 32'h00007f1b
`define INT_LSA 32'h00007f20
`define INT_MSA 32'h00007f23

// 指令地址定义
`define PC_INIT 32'h00003000
`define EXC_ADDR 32'h00004180

// CP0 寄存器定义
`define SR_NUMBER 12
`define CAUSE_NUMBER 13
`define EPC_NUMBER 14

`define IM_SIZE 6
`define IM_MSB 15
`define IM_LSB 10

`define EXL_SIZE 1
`define EXL_POS 1

`define IE_SIZE 1
`define IE_POS 0

`define BD_SIZE 1
`define BD_POS 31

`define IP_SIZE 6
`define IP_MSB 15
`define IP_LSB 10

`define EXCCODE_SIZE 5
`define EXCCODE_MSB 6
`define EXCCODE_LSB 2

// 控制器流水级定义
`define STAGE_DEFAULT 0
`define STAGE_FETCH 1
`define STAGE_DECODE 2
`define STAGE_EXECUTE 3
`define STAGE_MEMORY 4
`define STAGE_WRITEBACK 5

// 控制信号定义
`define T_SIZE 3
`define TUSE_IGNORE 3'd3 // 0 <= Tuse <= 3
`define TNEW_IGNORE -3'd1 // -1 <= Tnew <= 3

`define BRANCH_SIZE 2
`define BRANCH_DISABLE 2'b00
`define BRANCH_UNLIKELY 2'b01
`define BRANCH_LIKELY 2'b10

`define JUMP_SIZE 2
`define JUMP_DISABLE 2'b00
`define JUMP_INDEX 2'b01
`define JUMP_REG 2'b10
`define JUMP_EPC 2'b11

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

`define ALUSRC_SIZE 3
`define ALUSRC1_SIZE 1
`define ALUSRC2_SIZE 2
`define ALUSRC_IGNORE 3'b000
`define ALUSRC1_RS 1'b0
`define ALUSRC1_RT 1'b1
`define ALUSRC2_RT 2'b00
`define ALUSRC2_IMM_SHAMT 2'b01
`define ALUSRC2_S 2'b10
`define ALUSRC2_RS 2'b11

`define ALUOP_SIZE 4
`define ALUOP_NOOP 4'b0000
`define ALUOP_ADD 4'b0001
`define ALUOP_ADDU 4'b0010
`define ALUOP_SUB 4'b0011
`define ALUOP_SUBU 4'b0100
`define ALUOP_AND 4'b0101
`define ALUOP_OR 4'b0110
`define ALUOP_XOR 4'b0111
`define ALUOP_NOR 4'b1000
`define ALUOP_SLL 4'b1001
`define ALUOP_SRL 4'b1010
`define ALUOP_SRA 4'b1011
`define ALUOP_LT 4'b1100
`define ALUOP_LTU 4'b1101

`define MDUOP_SIZE 3
`define MDUOP_NOOP 3'b000
`define MDUOP_MULT 3'b001
`define MDUOP_MULTU 3'b010
`define MDUOP_DIV 3'b011
`define MDUOP_DIVU 3'b100
`define MDUOP_MTHI 3'b101
`define MDUOP_MTLO 3'b110

`define DELAY_SIZE 4
`define DELAY_MUTI 4'd5
`define DELAY_DIV 4'd10

`define MEMWRITE_SIZE 2
`define MEMWRITE_DISABLE 2'b00
`define MEMWRITE_WORD 2'b01
`define MEMWRITE_HALF 2'b10
`define MEMWRITE_BYTE 2'b11

`define DEOP_SIZE 3
`define DEOP_NOOP 3'b000
`define DEOP_WORD 3'b001
`define DEOP_BYTE_UNSIGNED 3'b010
`define DEOP_BYTE_SIGNED 3'b011
`define DEOP_HALF_UNSIGNED 3'b100
`define DEOP_HALF_SIGNED 3'b101

`define REGSRC_SIZE 3
`define REGSRC_IGNORE 3'b000
`define REGSRC_ALU 3'b000
`define REGSRC_MEM 3'b001
`define REGSRC_PC8 3'b010
`define REGSRC_HI 3'b011
`define REGSRC_LO 3'b100
`define REGSRC_CP0 3'b101

`define REGDST_SIZE 2
`define REGDST_IGNORE 2'b00
`define REGDST_RT 2'b00
`define REGDST_RD 2'b01
`define REGDST_RA 2'b10

`define REGWRITE_SIZE 2
`define REGWRITE_DISABLE 2'b00
`define REGWRITE_UNCOND 2'b01
`define REGWRITE_COND 2'b10

`define EXCEPTION_SIZE 2
`define EXCEPTION_NONE 2'b00
`define EXCEPTION_RI 2'b01
`define EXCEPTION_SYSCALL 2'b10

// 冒险信号定义
`define FWD_FROM_SIZE 2
`define FWD_FROM_DISABLE 2'b00
`define FWD_FROM_DE 2'b01
`define FWD_FROM_EM 2'b10
`define FWD_FROM_MW 2'b11

// 异常码定义
`define EXCCODE_SIZE 5
`define EXCCODE_NONE 5'd0
`define EXCCODE_INT 5'd0
`define EXCCODE_ADEL 5'd4
`define EXCCODE_ADES 5'd5
`define EXCCODE_SYSCALL 5'd8
`define EXCCODE_RI 5'd10
`define EXCCODE_OV 5'd12

`endif
