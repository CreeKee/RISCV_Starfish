`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2023 04:41:46 PM
// Design Name: 
// Module Name: Forwarder
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

typedef struct packed {
    
    logic [4:0] register;
    logic [1:0] sel;

} forward_pack;

module Forwarder(
    input logic clk,
    input logic [4:0] adr1,
    input logic [4:0] adr2,
    input logic [4:0] wa,
    input logic regWrite,
    output logic [1:0] rs1_sel,
    output logic [1:0] rs2_sel
    );
    logic regw_reg;
    logic[4:0] adr1_reg;
    logic[4:0] adr2_reg;
    logic[4:0] wa_reg;

    forward_pack selshifts[2]  = {0,0};

    always_comb begin
        if(adr1_reg == selshifts[0].register) rs1_sel = selshifts[0].sel;
        else if(adr1_reg == selshifts[1].register) rs1_sel = selshifts[1].sel;
        else rs1_sel = 0;

        if(adr2_reg == selshifts[0].register) rs2_sel = selshifts[0].sel;
        else if(adr2_reg == selshifts[1].register) rs2_sel = selshifts[1].sel;
        else rs2_sel = 0;
    end

    always_ff @ (posedge clk) begin

        if(regw_reg && (wa_reg != 0)) begin
            if(selshifts[0].sel[0] == 0 || selshifts[0].register == wa_reg) begin
                selshifts[0].register <= wa_reg;
                selshifts[0].sel <= 2'b01;

                selshifts[1].sel <= selshifts[1].sel<<1;
            end
            else if(selshifts[1].sel[0] == 0 || selshifts[1].register == wa_reg) begin
                selshifts[1].register <= wa_reg;
                selshifts[1].sel <= 2'b01;

                selshifts[0].sel <= selshifts[0].sel<<1;
            end
            else begin
                selshifts[1].sel <= selshifts[1].sel<<1;
                selshifts[0].sel <= selshifts[0].sel<<1;
            end
        end
        else begin
            selshifts[1].sel <= selshifts[1].sel<<1;
            selshifts[0].sel <= selshifts[0].sel<<1;
        end

        adr1_reg<=adr1;
        adr2_reg<=adr2;
        wa_reg<=wa;
        regw_reg<=regWrite;

    end

endmodule
