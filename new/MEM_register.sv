`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 11:03:37 PM
// Design Name: 
// Module Name: MEM_register
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


module MEM_register(
    input logic clk,
    input logic reset,
    input logic ld,
    input mem_reg_d mem_reg_in,
    output mem_reg_d mem_reg_out
    );

    always_ff @(posedge clk) begin
        if(reset) mem_reg_out<=0;
        else if(ld) mem_reg_out <= mem_reg_in;
        else mem_reg_out <= mem_reg_out;
    end

endmodule
