`timescale 1ns / 1ps
`include "includes.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2023 09:01:30 PM
// Design Name: 
// Module Name: DE_register
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


module DE_register(
    input logic clk,
    input logic reset,
    input logic ld,
    input de_reg_d de_reg_in,
    output de_reg_d de_reg_out
    );

    always_ff @(posedge clk) begin

        if(reset) de_reg_out.pc<=0;
        else if(ld) de_reg_out <= de_reg_in;
        else de_reg_out <= de_reg_out;

    end

endmodule
