`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 05:09:49 PM
// Design Name: 
// Module Name: mux_2t1_nb
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


module mux_2t1_nb#(parameter n=32) (  
    input logic SEL,
    input logic [n-1:0] D0, 
    input logic [n-1:0] D1, 
    output logic [n-1:0] D_OUT);  

    
    always_comb
    begin 
        case (SEL) 
                0:      D_OUT = D0;
                1:      D_OUT = D1; 
                default D_OUT = 0;
        endcase 
    end

    
endmodule
