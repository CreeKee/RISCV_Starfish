`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 09:43:34 PM
// Design Name: 
// Module Name: EX_register
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


module EX_register(
    input logic clk,
    input logic reset,
    input logic ld,
    input ex_reg_d ex_reg_in,
    output ex_reg_d ex_reg_out
    );

    always_ff @(posedge clk) begin
        if(reset) ex_reg_out.pc<=0;
        else if(ld) ex_reg_out <= ex_reg_in;
        else ex_reg_out <= ex_reg_out;
    end
endmodule
