`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2023 01:16:02 PM
// Design Name: 
// Module Name: decoder
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


module decoder(
    input logic [31:0] ir,

    output logic regWrite,
    output logic memWrite,
    output logic memRead2,
    output logic [3:0] alu_fun,
    output logic alu_srcA,
    output logic [1:0] alu_srcB,
    output logic rf_wr_sel,
    output logic [6:0] opcode 
    );

    logic [2:0] func3;
    logic func7;

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
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    assign opcode = ir[6:0];
    assign func3 = ir[14:12];
    assign func7 = ir[30];

        always_comb
    begin 
        //- schedule all outputs to avoid latch
        regWrite = 1'b0;
		memWrite = 1'b0;
		

		case(OPCODE)
		
            AUIPC:
            begin
                alu_fun  = 4'b0000;
                alu_srcA = 1'b1;
                alu_srcB = 2'b00;
                rf_wr_sel = 1'b0; 

                regWrite = 1'b1;
            end
		
			LUI:
			begin
				alu_fun = 4'b1001; 
				alu_srcA = 1'b0; 
                alu_srcB = 2'b00;
				rf_wr_sel = 1'b0;  

                regWrite = 1'b1;
			end
			
			JAL:
			begin
                alu_fun  = 4'b0000;
                alu_srcA = 1'b1;
                alu_srcB = 2'b10;    
				rf_wr_sel = 1'b0;

                regWrite = 1'b1;
			end			
			
			JALR:
			begin
                alu_fun  = 4'b0000;
                alu_srcA = 1'b1;
                alu_srcB = 2'b10;
				rf_wr_sel = 2'b0;

                regWrite = 1'b1;
			end
			
			LOAD: 
			begin
				alu_fun = 4'b0000; 
				alu_srcA = 1'b0; 
				alu_srcB = 2'b01; 
				rf_wr_sel = 1'b1; 

                memRead2 = 1'b1;
			end
			
			BRANCH:
			begin
                /*TODO and handled elsewhere*/
			end
			
			STORE:
			begin
                alu_fun  = 4'b0000;
                alu_srcA = 1'b0;
				alu_srcB = 2'b00; 
                rf_wr_sel = 1'b0;

                memWrite = 1'b1;
			end
			
			OP_IMM:
			begin
                alu_srcA = 1'b0;
                alu_srcB = 2'b00;
				rf_wr_sel = 1'b0;

                regWrite = 1'b1;
				
				case(func3)
					3'b000: // instr: ADDI
					begin
						alu_fun = 4'b0000;
					end
					
					3'b010: //SLTI
					begin
						alu_fun = 4'b0010;;  
					end
					
					3'b011: //SLTIU
					begin
						alu_fun = 4'b0011; 
					end
					
					3'b110: //ORI
					begin
						alu_fun = 4'b0110; 
					end
					
					3'b100: //XORI
					begin
						alu_fun = 4'b0100; 
					end
					
					3'b111: //ANDI
					begin
						alu_fun = 4'b0111; 
					end
					
					3'b001: //SLLI
					begin
						alu_fun = 4'b0001; 
					end
					
					3'b101: //SRLI and SRAI
					begin
					   if(func7==1'b0) alu_fun = 4'b0101;
					   else alu_fun = 4'b1101;
					end
					
					default:
					begin
						alu_fun = 4'b0000;

					end
			     endcase
			end
					
            OP_RG3:
			begin
                alu_srcA = 1'b0; 
                alu_srcB = 2'b01; 
				rf_wr_sel = 1'b0; 

                regWrite = 1'b1;

				case(func3)
					3'b000: // instr: ADD/SUB
					begin
					   if(func7==0)alu_fun = 4'b0000;
						else alu_fun = 4'b1000;

					end

					3'b010: //SLT
					begin
						alu_fun = 4'b0010;
					end
					
					3'b011: //SLTIU
					begin
						alu_fun = 4'b0011; 
					end
					
					3'b110: //ORI
					begin
						alu_fun = 4'b0110;
					end
					
					3'b100: //XORI
					begin
						alu_fun = 4'b0100;
					end
					
					3'b111: //ANDI
					begin
						alu_fun = 4'b0111; 
					end
					
					3'b001: //SLLI
					begin
						alu_fun = 4'b0001;
					end
					
					3'b101: //SRLI and SRAI
					begin
					   if(func7==1'b0) alu_fun = 4'b0101;
					   else alu_fun = 4'b1101;
					end
					
					default:
					begin
                        alu_fun = 4'b0000;
					end
				endcase	
			end					

            SYS:
            begin
                //TODO interrupts or something
                alu_fun  = 4'b0000;
                alu_srcA = 1'b0;
                alu_srcB = 2'b01; 
                if(func3 == 3'b001) begin
                    rf_wr_sel = 1'b0;
				    regWrite = 1'b1;
                end
                else rf_wr_sel = 1'b0;
            end

			default:
			begin
				 alu_srcB = 2'b00; 
				 rf_wr_sel = 2'b00; 
				 alu_srcA = 1'b0; 
				 alu_fun = 4'b0000;
			end
			
			endcase

    end


endmodule
