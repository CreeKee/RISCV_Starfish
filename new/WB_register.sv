`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 11:02:47 PM
// Design Name: 
// Module Name: WB_register
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


module WB_register(
    input logic clk,
    input logic reset,
    input logic ld,
    input wb_reg_d wb_reg_in,
    output wb_reg_d wb_reg_out
    );

    always_ff @(posedge clk) begin
        if(reset) wb_reg_out<=0;
        else if(ld) wb_reg_out <= wb_reg_in;
        else wb_reg_out <= wb_reg_out;
    end
endmodule
