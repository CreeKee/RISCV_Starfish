`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2023 10:25:26 PM
// Design Name: 
// Module Name: Branch_Unit
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


module Branch_Unit(
    input logic [2:0] func3,
    input logic [6:0] opcode,
    input logic [31:0] frs1, 
    input logic [31:0] frs2, 
    output logic [1:0] br_re
    );


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
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    logic br_eq;
    logic br_lt;
    logic br_ltu;

    assign br_eq = (frs1==frs2);
    assign br_lt = $signed(frs1) < $signed(frs2);
    assign br_ltu = frs1 < frs2;


    always_comb begin

        case(OPCODE)

            JALR: br_re = 1;

            JAL: br_re = 1;

            BRANCH:
                case(func3)
                    
                    3'b000: //BEQ
                        br_re = {0,br_eq};
                                        
                    3'b001: //BNE
                        br_re = {0,~br_eq};
                                  
                    3'b100: //BLT
                        br_re = {0,br_lt};
                                                                                
                    3'b101: //BGE
                        br_re = {0,~br_lt};
                                                                         
                    3'b110: //BLTU
                        br_re = {0,br_ltu};
                                                                                                                        
                    3'b111: //BGEU
                        br_re = {0,~br_ltu};

                    default br_re = 0;
                endcase

            default: br_re = 0;

        endcase

    end

endmodule
