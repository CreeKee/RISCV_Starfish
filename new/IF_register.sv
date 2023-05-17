`timescale 1ns / 1ps
`include "includes.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2023 08:47:45 PM
// Design Name: 
// Module Name: IF_register
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


module IF_register(
    input logic clk,
    input logic reset,
    input logic pcWrite,
    input if_reg_d if_reg_in,
    output if_reg_d if_reg_out
    );

    always_ff @(posedge clk) begin
        if(reset) if_reg_out.pc<=0;
        else if(pcWrite) if_reg_out <= if_reg_in;
        else if_reg_out <= if_reg_out;
    end


endmodule
