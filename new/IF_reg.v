`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2023 09:45:57 PM
// Design Name: 
// Module Name: PC_reg
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


module PC_reg(

    pc_itf.regs pc_itf
    );

    always @ (posedge clk) begin
    
        if(pc_itf.rst) pc_itf.pc <= 0;
        else if(pc_itf.ld) pc_itf.pc <= data;
        else pc_itf.pc <= pc_itf.pc;
    end
endmodule
