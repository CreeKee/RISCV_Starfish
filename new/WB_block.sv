`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2023 04:01:21 PM
// Design Name: 
// Module Name: WB_block
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


module WB_block(
    input wb_reg_d wb_reg,
    input logic [31:0] mem_data_out,
    output logic [31:0] wd
    );

    mux_2t1_nb regmux(wb_reg.rf_wr_sel, wb_reg.alu_result, mem_data_out, wd);
endmodule
