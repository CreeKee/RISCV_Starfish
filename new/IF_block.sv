`timescale 1ns / 1ps
`include "includes.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2023 10:03:14 PM
// Design Name: 
// Module Name: IF_block
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


module IF_block
#(parameter int WIDTH = 32)
    (
    input if_reg_d reg_out_data,
    input logic[WIDTH-1:0] br_res_ex,
    input logic[WIDTH-1:0] br_target_ex,
    input logic[WIDTH-1:0] mepc,
    input logic[WIDTH-1:0] mtvec,

    output if_reg_d reg_in_data
    );

    logic[1:0] pc_sel = 0;
    mux_4t1_nb #(.n(WIDTH)) pcMUX(.D0(reg_out_data.pc+4), .D1(br_target_ex), .D2(mtvec), .D3(mepc), .SEL(br_res_ex), .D_OUT(reg_in_data.pc));

endmodule
