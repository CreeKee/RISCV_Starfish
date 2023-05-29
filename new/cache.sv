/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */
`define TAGRANGE 31-:s_tag
`define INDEXRANGE 7:5
`define OFFSETRANGE (32*cpu_itf.mem_address[4:2]) +: 32

typedef struct packed {
    logic age;
    logic valid;
    logic dirty;
    logic [31:0] addr;
    logic [255:0] data;
} cache_line;


module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter addmask = 32'hFFFFFFE0

)
(
    mem_itf.device cpu_itf,
    mem_itf.controller ca_itf,
    input logic [255:0] readcachebus,
    output logic [255:0] writecachebus

);

    typedef  enum logic [1:0] {
       st_IDLE,
	   st_CHECK,
       st_BUMP,
       st_INGRESS
    }  state_type; 
    state_type  NS,PS; 


cache_line [1:0][num_sets-1:0] trove = 0;
logic test;
logic [1:0] hit;
logic [1:0] state;
logic LRU;
logic [2:0] lineNum;
logic [31:0] strobeMask;

//check if either line has a hit
assign hit = {(trove[0][lineNum].addr[`TAGRANGE] == cpu_itf.mem_address[`TAGRANGE])&&trove[0][lineNum].valid, (trove[1][lineNum].addr[`TAGRANGE] == cpu_itf.mem_address[`TAGRANGE])&&trove[1][lineNum].valid}; 

//calculate line number for clean looking code
assign lineNum = cpu_itf.mem_address[`INDEXRANGE];

//strobing is done by this module, so the param mem will always be 0xF
assign ca_itf.mem_byte_enable = 4'hF;

//determine LRU
assign LRU = trove[1][lineNum].age;

//expand strope mask from bits to bytes
assign strobeMask[7:0] = {8{cpu_itf.mem_byte_enable[0]}};
assign strobeMask[15:8] = {8{cpu_itf.mem_byte_enable[1]}};
assign strobeMask[23:16] = {8{cpu_itf.mem_byte_enable[2]}};
assign strobeMask[31:24] = {8{cpu_itf.mem_byte_enable[3]}};

always_comb begin

    case(PS)

    st_IDLE: 
    begin
        ca_itf.mem_write=1'b0;
        ca_itf.mem_read=1'b0;

        //check for action
        if(cpu_itf.mem_read|cpu_itf.mem_write) NS = st_CHECK;
        else begin 
            NS=st_IDLE;
        end
    end
    
    st_CHECK: 
    begin
        ca_itf.mem_write=1'b0;
        ca_itf.mem_read=1'b0;
        cpu_itf.mem_resp = 1'b0;


        if(cpu_itf.mem_read) begin

            //check for hit
            case(hit)

                2'b00: 
                begin
                    //writeback dirty data
                    if(trove[LRU][lineNum].dirty) NS = st_BUMP;

                    //go directly to reading in new data
                    else begin
                        NS=st_INGRESS;
                    end
                end
                
                2'b01: 
                begin

                    //read from cache
                    cpu_itf.mem_rdata = trove[1][lineNum].data[`OFFSETRANGE];

                    //signal output
                    cpu_itf.mem_resp = 1'b1;

                    //update ages
                    trove[1][lineNum].age = 1'b0;
                    trove[0][lineNum].age = 1'b1;
                    NS=st_IDLE;
                end

                2'b10: 
                begin

                    //read from cache
                    cpu_itf.mem_rdata = trove[0][lineNum].data[`OFFSETRANGE];

                    //signal output
                    cpu_itf.mem_resp = 1'b1;

                    //update ages
                    trove[0][lineNum].age = 1'b0;
                    trove[1][lineNum].age = 1'b1;
                    NS=st_IDLE;
                end

                default: NS=st_IDLE;

            endcase
        end
        else begin

            //check for hit
            case(hit)
                2'b00: 
                begin 

                    //writeback dirty data
                    if(trove[LRU][lineNum].dirty) NS = st_BUMP;

                    //go straight to reading in data
                    else begin
                        NS=st_INGRESS;
                    end
                end
                
                2'b01: 
                begin

                    //write data to cachline, applying strobing
                    trove[1][lineNum].data[`OFFSETRANGE] = (cpu_itf.mem_wdata&strobeMask)|(trove[0][lineNum].data[`OFFSETRANGE] & ~strobeMask);

                    //singal output
                    cpu_itf.mem_resp = 1'b1;

                    //update ages and dirt
                    trove[1][lineNum].age = 1'b0;
                    trove[0][lineNum].age = 1'b1;
                    trove[1][lineNum].dirty = 1'b1;
                    NS=st_IDLE;
                end

                2'b10: 
                begin

                    //write data to cachline, applying strobing
                    trove[0][lineNum].data[`OFFSETRANGE] = (cpu_itf.mem_wdata&strobeMask)|(trove[0][lineNum].data[`OFFSETRANGE] & ~strobeMask);
                    
                    //singal output
                    cpu_itf.mem_resp = 1'b1;

                    //update ages and dirt
                    trove[0][lineNum].age = 1'b0;
                    trove[1][lineNum].age = 1'b1;
                    trove[0][lineNum].dirty = 1'b1;
                    NS=st_IDLE;
                end
                default: NS=st_IDLE;
            endcase
        end
    end

    st_BUMP:
    begin
        
        //set memory address, quantizing given address
        ca_itf.mem_address = (trove[LRU][lineNum].addr & addmask);

        //send cachline to adapter for bursting
        writecachebus = trove[LRU][lineNum].data;
        
        //wait for write to finish
        if(ca_itf.mem_resp) begin 
            NS=st_INGRESS;
            ca_itf.mem_write = 1'b0;
        end

        //continue writing
        else begin
            ca_itf.mem_write = 1'b1;
            NS=st_BUMP;
        end
    end

    st_INGRESS:
    begin

        //set memory address, quantizing given address
        ca_itf.mem_address = cpu_itf.mem_address & addmask;

        //update cachline data
        trove[LRU][lineNum].valid = 1'b1;
        trove[LRU][lineNum].addr = cpu_itf.mem_address; 

        //read from cache line adaptor
        ca_itf.mem_read=1'b1;
        trove[LRU][lineNum].data = readcachebus;

        //wait till read from memory is done
        if(ca_itf.mem_resp) NS=st_CHECK;
        else NS=st_INGRESS;
    end

    default: NS=st_IDLE;

    endcase

end

//update state
always_ff @( posedge cpu_itf.clk ) begin : fsm
    PS<=NS;
end


endmodule : cache
