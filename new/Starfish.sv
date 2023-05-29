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

    logic [31:0] ir = 0;
    logic [31:0] IOBUS_IN;
    logic [31:0] dout2;
    logic memWE2 = 0;
    logic memRDEN1 = 1;
    logic IOBUS_WR = 0;

    logic mem_valid1 = 1;
    logic mem_valid2 = 1;

    logic stall_all;
    logic if_stall;
    logic de_stall;
    logic ex_stall;
    logic mem_stall;
    logic wb_stall;

    logic load_squash;
    logic branch_squash;
    logic squash_if;
    logic flush_ex;

    logic load_stall_conf;
    assign load_stall_conf = (ir[19:15] == mem_reg_in.wa)|(ir[24:20] == mem_reg_in.wa);

    assign de_stall = (stall_all|(load_squash&load_stall_conf));
    assign if_stall = (stall_all|(load_squash&load_stall_conf));
    assign ex_stall = stall_all;
    assign mem_stall = stall_all;
    assign wb_stall = stall_all;

    assign flush_ex = (load_squash&load_stall_conf)|squash_if|branch_squash;

    assign squash_if = (br_res != 0);

    assign stall_all = ~(mem_valid1 & mem_valid2);


/*execute block
**************************************************/

    logic [1:0] rs1_sel;
    logic [1:0] rs2_sel;
    logic [31:0] br_target;
    logic [31:0] wd;
    logic [1:0] br_res;
    
/***************************************************/

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

    IF_register IF_reg(clk, 0, ~if_stall, if_reg_in, if_reg_out);
    IF_block IF(if_reg_out, br_res, br_target, 0, 0, if_reg_in);

    DE_register DE_reg(clk, squash_if, ~de_stall, de_reg_in, de_reg_out);
    DE_block DE(de_reg_out, ir, ex_reg_in);

    EX_register EX_reg(clk, flush_ex, ~ex_stall, ex_reg_in, ex_reg_out);
    EX_block EX(ex_reg_out, rs1_sel, rs2_sel, mem_reg_out.alu_result, wd, mem_reg_in, br_target, br_res, load_squash);

    MEM_register MEM_reg(clk, 0, ~mem_stall, mem_reg_in, mem_reg_out);
    assign wb_reg_in.regWrite = mem_reg_out.regWrite;
    assign wb_reg_in.alu_result = mem_reg_out.alu_result;
    assign wb_reg_in.wa = mem_reg_out.wa;
    assign wb_reg_in.rf_wr_sel = mem_reg_out.rf_wr_sel;

    WB_register WB_reg(clk, 0, ~mem_stall, wb_reg_in, wb_reg_out);
    WB_block WB(wb_reg_out, dout2, wd);


/***************************************************/



/***************************************************/
    OTTER_mem_byte memory (
        .MEM_CLK(clk),
        .MEM_ADDR1(if_reg_out.pc),
        .MEM_ADDR2(mem_reg_out.alu_result),
        .MEM_DIN2(mem_reg_out.rs2),
        .MEM_WRITE2(mem_reg_out.memWrite),
        .MEM_READ1(memRDEN1&~de_stall),
        .MEM_READ2(mem_reg_out.memRead2),
        .ERR(),
        .MEM_DOUT1(ir),
        .MEM_DOUT2(dout2),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),
        .MEM_SIZE(mem_reg_out.size),
        .MEM_SIGN(mem_reg_out.sign)
        );


    RegFile REG_FILE(
        .en(wb_reg_out.regWrite),//TODO? stalling
        .adr1(ir[19:15]),
        .adr2(ir[24:20]),
        .wa(wb_reg_out.wa),
        .clk(clk),
        .rs1(ex_reg_in.rs1),
        .rs2(ex_reg_in.rs2),
        .wd(wd)
    );

    Forwarder fwrdr(clk, ir[19:15], ir[24:20], ir[11:7], ex_reg_in.regWrite, rs1_sel, rs2_sel);

always_ff @(posedge clk) begin
    branch_squash <= squash_if;
end

endmodule
