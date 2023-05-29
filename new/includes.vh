`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define STORE  7'b0100011
`define OP_IMM 7'b0010011
`define OP_RG3 7'b0110011
`define SYS    7'b1110011

`ifndef STRUCTS
`define STRUCTS

typedef struct packed {
    logic [31:0] pc;
} if_reg_d;

typedef struct packed{

    logic [31:0] pc;

}de_reg_d;

typedef struct packed{

    logic [31:0] pc;
    logic [1:0] size;
    logic sign;

    logic regWrite;
    logic memWrite;
    logic memRead2;
    logic [3:0] alu_fun;
    logic alu_srcA;
    logic [1:0] alu_srcB;
    logic rf_wr_sel;
    logic [6:0] opcode;
    logic [2:0] func3;

    logic [31:0] immed;

    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [4:0] wa;
} ex_reg_d;

typedef struct packed{
    logic [31:0] alu_result;
    logic [1:0] size;
    logic sign;

    logic [31:0] rs2;
    logic regWrite;
    logic memWrite;
    logic memRead2;
    logic rf_wr_sel;

    logic [4:0] wa;
}mem_reg_d;

typedef struct packed{
    logic [31:0] alu_result;

    logic regWrite;
    logic rf_wr_sel;

    logic [4:0] wa;
}wb_reg_d;

`endif
