`timescale 1ns / 1ps
`include "includes.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 12:54:21 PM
// Design Name: 
// Module Name: DE_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DE_block(
    input logic [31:0] ir,
    output ex_reg_d ex_reg_in
    );


    wire [31:0] jalr, branch, jal, pc, ir, U_type, I_type, S_type, J_type, B_type, rs1, rs2, CSR_reg, dout2, result, wd, srcA, srcB, mtvec, mepc;
    wire [3:0] alu_fun;
    wire [2:0] pcSource;
    wire [1:0] alu_srcB, rf_wr_sel;
    wire reset, PCWrite, memRDEN1, memRDEN2, memWE2, regWrite, alu_srcA, IO_WR, br_eq, br_lt, br_ltu, csr_WE, int_taken, csr_mie;

    decoder dcdr(ir, ex_reg_in.regWrite, ex_reg_in.memWrite, ex_reg_in.memRead2, ex_reg_in.alu_fun, ex_reg_in.alu_srcA, ex_reg_in.alu_srcB, ex_reg_in.rf_wr_sel, ex_reg_in.opcode);

    Immed_Gen imgen(ir, immed);

    assign ex_reg_in.immed = immed;
    assign ex_reg_in.wa = ir[11:7];


endmodule
