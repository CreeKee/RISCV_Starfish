`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 05:07:06 PM
// Design Name: 
// Module Name: Immed_Gen
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


module Immed_Gen(
    input logic [31:0] ir,
    output logic [31:0] immed
    );


    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    assign OPCODE = opcode_t'(ir[6:0]); //- Cast input enum 

    always_comb begin

        case(OPCODE)

        AUIPC: immed = {{{ir[31:12]}},{12{1'b0}}};                  //U_type

        LUI: immed = {{{ir[31:12]}},{12{1'b0}}};                    //U_type

        JAL: immed = {{12{ir[31]}}, {ir[19:12]}, {ir[20]}, {ir[30:21]}, {1'b0}};    //J_type

        JALR: immed = {{21{ir[31]}}, {ir[30:25]}, {ir[24:20]}};     //I_type

        LOAD: immed = {{21{ir[31]}}, {ir[30:25]}, {ir[24:20]}};     //I_type

        BRANCH: immed = {{20{ir[31]}}, {ir[7]}, {ir[30:25]}, {ir[11:8]}, {1'b0}};   //B_type

        STORE: immed = {{21{ir[31]}}, {ir[30:25]}, {ir[11:7]}};     //S_type

        OP_IMM: immed = {{21{ir[31]}}, {ir[30:25]}, {ir[24:20]}};   //I_type

        default immed = 0;

        endcase

    end  
endmodule
