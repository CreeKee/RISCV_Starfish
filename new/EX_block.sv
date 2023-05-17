`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 09:36:36 PM
// Design Name: 
// Module Name: EX_block
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


module EX_block(
    input ex_reg_d ex_reg,
    input logic [1:0] rs1_sel,
    input logic [1:0] rs2_sel,
    input logic [31:0] mem_wd,
    input logic [31:0] wb_wd,
    output mem_reg_d mem_reg,
    output logic [31:0] br_target,
    output logic [1:0] br_res,
    output logic flush_ex
    );

    logic [31:0] frs1;
    logic [31:0] frs2;
    logic [31:0] alu_inA;
    logic [31:0] alu_inB;

    mux_3t1_nb rs1_fwrd_mux(rs1_sel, ex_reg.rs1, wb_wd, mem_wd, frs1);
    mux_3t1_nb rs2_fwrd_mux(rs2_sel, ex_reg.rs2, wb_wd, mem_wd, frs2);

    mux_3t1_nb alu_srcB_mux(ex_reg.alu_srcB, ex_reg.immed, frs2, 4, alu_inB);
    mux_2t1_nb alu_srcA_mux(ex_reg.alu_srcA, frs1, ex_reg.pc, alu_inA);

    ALU alu(
        .srcA(alu_inA),
        .srcB(alu_inB),
        .alu_fun(ex_reg.alu_fun),
        .result(mem_reg.alu_result)
    );

    Branch_Unit bu(ex_reg.opcode, frs1, frs2);

    assign flush_ex = (ex_reg.opcode == `LOAD);
    assign br_target = alu_inA+ex_reg.immed;

    assign mem_reg.rs2 = frs2;
    assign mem_reg.memWrite = ex_reg.memWrite;
    assign mem_reg.regWrite = ex_reg.regWrite;
    assign mem_reg.memRead2 = ex_reg.memRead2;
    assign mem_reg.rf_wr_sel = ex_reg.rf_wr_sel;
    assign mem_reg.wa = ex_reg.wa;
    

endmodule
