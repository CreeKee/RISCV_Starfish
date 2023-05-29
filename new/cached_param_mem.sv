`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2023 02:38:32 PM
// Design Name: 
// Module Name: cached_param_mem
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


module cached_param_mem(
    input logic [31:0] MEM_ADDR1,
    input logic [31:0] MEM_ADDR2,
    input logic MEM_WRITE2,
    input logic MEM_READ1,
    input logic MEM_READ2,
    output logic [31:0] MEM_DOUT1,
    output logic [31:0] MEM_DOUT2,
    output logic MEM_VALID1,
    output logic MEM_VALID2,

    mem_itf inst_itf,
    mem_itf inst_ca_itf,
    mem_itf inst_pmem_itf,
    mem_itf main_itf,
    mem_itf main_ca_itf,
    mem_itf main_pmem_itf,
    mem_itf curr_itf
    );

    logic [255:0] inst_readbus;
    logic [255:0] main_readbus;
    logic [255:0] inst_writebus;
    logic [255:0] main_writebus;

    cache instcache(.cpu_itf(inst_itf), .ca_itf(inst_ca_itf), .readcachebus(inst_readbus), .writecachebus(inst_writebus));
    cacheline_adaptor instcacheline_adaptor(.ca_itf(inst_ca_itf), .pmem_itf(inst_pmem_itf), .readcachebus(inst_readbus), .writecachebus(inst_writebus));

    cache maincache(.cpu_itf(main_itf), .ca_itf(main_ca_itf), .readcachebus(main_readbus), .writecachebus(main_writebus));
    cacheline_adaptor maincacheline_adaptor(.ca_itf(main_ca_itf), .pmem_itf(main_pmem_itf), .readcachebus(main_readbus), .writecachebus(main_writebus));
    
    assign MEM_VALID1 = inst_itf.mem_resp;
    assign MEM_VALID2 = main_itf.mem_resp;

    assign MEM_DOUT1 = inst_itf.mem_rdata;
    assign MEM_DOUT2 = main_itf.mem_rdata;

    ParamMemory #(25, 13, 8, 256, 512,0) memory(curr_itf);

    always_comb begin : scheduler
        case(MEM_VALID1)

            0: curr_itf = inst_pmem_itf;

            1: curr_itf = main_pmem_itf;

        endcase
    end

endmodule
