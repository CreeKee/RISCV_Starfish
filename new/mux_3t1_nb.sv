`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 09:39:20 PM
// Design Name: 
// Module Name: mux_3t1_nb
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


module mux_3t1_nb#(parameter n=32) (
    input logic [1:0] SEL,
    input logic [n-1:0] D0, 
    input logic [n-1:0] D1, 
    input logic [n-1:0] D2, 
    output logic [n-1:0] D_OUT);  

    
    always_comb
    begin 
        case (SEL) 
                0:      D_OUT = D0;
                1:      D_OUT = D1;
                2:      D_OUT = D2;
                
                default D_OUT = 0;
        endcase 
    end
endmodule
