`timescale 1ns / 1ps
`include "includes.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2023 09:36:18 PM
// Design Name: 
// Module Name: Starfish
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

module Starfish(
    input logic clk
    );

    logic [31:0] ir;
    logic [31:0] IOBUS_IN;
    logic [31:0] dout2;
    logic memWE2 = 0;
    logic memRDEN1 = 1;
    logic IOBUS_WR = 0;


/*execute block
**************************************************/
    logic [1:0] rs1_sel;
    logic [1:0] rs2_sel;
    logic [31:0] br_target;
    logic [1:0] br_res;
    logic flush_ex;
    logic ex_ld = 1;
/***************************************************/

    logic reset = 0;
    logic pcWrite = 1;

    if_reg_d if_reg_in = 0;
    if_reg_d if_reg_out = 0;

    de_reg_d de_reg_in = 0;
    de_reg_d de_reg_out = 0;

    ex_reg_d ex_reg_in = 0;
    ex_reg_d ex_reg_out = 0;
    assign de_reg_in.pc = if_reg_out.pc;

    mem_reg_d mem_reg_in = 0;
    mem_reg_d mem_reg_out = 0;

    wb_reg_d wb_reg_in = 0;
    wb_reg_d wb_reg_out = 0;

/***************************************************/

    IF_register IF_reg(clk, reset, pcWrite, if_reg_in, if_reg_out);
    IF_block IF(if_reg_out, br_res, br_target, 0, 0, if_reg_in);

    DE_register DE_reg(clk, 0, 1, de_reg_in, de_reg_out);
    DE_block DE(ir, ex_reg_in);

    EX_register EX_reg(clk, flush_ex, ex_ld, ex_reg_in, ex_reg_out);
    EX_block EX(ex_reg_out, rs1_sel, rs2_sel, mem_reg_out.alu_result, wb_reg_out.alu_result, mem_reg_in, br_target, br_res, flush_ex);

/***************************************************/

    OTTER_mem_byte memory (
        .MEM_CLK(clk),
        .MEM_ADDR1(if_reg_out.pc),
        .MEM_ADDR2(mem_reg_out.alu_result),
        .MEM_DIN2(mem_reg_out.rs2),
        .MEM_WRITE2(mem_reg_out.memWrite),
        .MEM_READ1(memRDEN1),
        .MEM_READ2(mem_reg_out.memRead2),
        .ERR(),
        .MEM_DOUT1(ir),
        .MEM_DOUT2(dout2),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),
        .MEM_SIZE(ir[13:12]),
        .MEM_SIGN(ir[14])
        );

    RegFile REG_FILE(
        .en(0),
        .adr1(ir[19:15]),
        .adr2(ir[24:20]),
        .wa(0),
        .clk(clk),
        .rs1(ex_reg_in.rs1),
        .rs2(ex_reg_in.rs2),
        .wd(0)
    );

    Forwarder fwrdr(clk, ir[19:15], ir[24:20], ir[11:7], regWrite, rs1_sel, rs2_sel);

endmodule
