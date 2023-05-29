module cacheline_adaptor
(
    mem_itf.device ca_itf,
    mem_itf.controller pmem_itf,
    output logic [255:0] readcachebus,
    input logic [255:0] writecachebus
);

    typedef  enum logic [2:0] {
       st_IDLE,
       st_READ,
       st_WRITE,
       st_RACTIVE,
       st_WACTIVE
    }  line_type; 
    line_type  NS,PS = st_IDLE; 
 
logic [2:0] count = 0;

//pass strobing through as it is not needed
assign pmem_itf.mem_byte_enable = ca_itf.mem_byte_enable;


always_comb begin : blockName
    
    case(PS)

        st_IDLE:
        begin 
            
            //set flags
            ca_itf.mem_resp = 1'b0;
            pmem_itf.mem_write = 1'b0;
            pmem_itf.mem_read = 1'b0;

            //check for action
            if(ca_itf.mem_read) NS=st_READ;
            else if(ca_itf.mem_write) begin 
                NS=st_WRITE;
                //start writing to pmem
                pmem_itf.mem_wdata = writecachebus[32*count+:32];
                
            end
            else NS= st_IDLE;
        end

        st_READ:
        begin
            //pass address to pmem and set flags
            pmem_itf.mem_address = ca_itf.mem_address;
            pmem_itf.mem_read = 1'b1;

            //wait till pmem is ready
            if(pmem_itf.mem_resp == 1'b1) NS=st_RACTIVE;
            else NS=st_READ;
            
        end

        st_WRITE:
        begin
            //pass address to pmem and set flags
            pmem_itf.mem_address = ca_itf.mem_address;
            pmem_itf.mem_write = 1'b1;

            //wait till pmem is ready
            if(pmem_itf.mem_resp == 1'b1) NS=st_WACTIVE;
            else NS=st_WRITE;
        end

        st_RACTIVE:
        begin

            //read burst until pmem is done
            if(pmem_itf.mem_resp == 1'b1) begin
               
                NS = st_RACTIVE;

            end

            //end read
            else begin
                pmem_itf.mem_read = 1'b0;
                NS = st_IDLE;
                ca_itf.mem_resp = 1'b1;
            end
        end

        st_WACTIVE:
        begin
            
            //write burst until pmem is done
            if(pmem_itf.mem_resp == 1'b1) begin
                
                NS = st_WACTIVE;

            end

            //end write
            else begin
                pmem_itf.mem_write = 1'b0;
                NS = st_IDLE;
                ca_itf.mem_resp = 1'b1;
            end
        end


    default: NS = st_IDLE;
    endcase
end


always_ff @( posedge ca_itf.clk ) begin : counter


    case(NS) 
        st_IDLE:
        begin 
            count <= 3'b000;
            if(ca_itf.mem_write) begin

                //start writing
                count <= count+1;
            end

        end

        st_RACTIVE: begin

            //read burst
            if(pmem_itf.mem_resp == 1'b1) begin

                //translate burst to cacheline
                count <= count+1;
                readcachebus[count*32+:32] <= pmem_itf.mem_rdata;
            end
        end

        st_WACTIVE:
        begin

            //write in burst
            if(pmem_itf.mem_resp == 1'b1) begin

                //translate chacnline to burst
                count <= count+1;
                pmem_itf.mem_wdata <= writecachebus[count*32+:32];
            end

        end

        default: count <=0;
    endcase


    PS<=NS;
end

endmodule : cacheline_adaptor