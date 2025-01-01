module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here

logic en_p, rdy_p, en_k, rdy_k, en_i, rdy_i, wren, toggle;

logic [7:0] addr, rddata, wrdata, addr_k, wrdata_k, addr_i, wrdata_i, q, s_addr, s_wrdata;
logic wren_i, wren_k;

s_mem s(addr, clk, wrdata, wren, q);
prga pr(clk, rst_n, en_p, rdy_p, key, s_addr, q, s_wrdata, s_wren, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata, pt_wren);
ksa ks(clk, rst_n, en_k, rdy_k, key, addr_k, q, wrdata_k, wren_k);
init in(clk, rst_n, en_i, rdy_i, addr_i, wrdata_i, wren_i);
    // your code here




enum {IDLE, INIT, WAIT_INIT, KSA, WAIT_KSA, PRGA, WAIT_PRGA} state;

always_ff @(posedge clk) begin
    if(~rst_n) begin
        en_p <= 0;
        en_k <= 0;
        en_i <= 0;
        toggle <= 1'b0;
        state <= IDLE;
        rdy <= 1;
    end else begin

         case(state)

            IDLE: begin
                if(en && rdy_i)begin
                    state <= INIT;
                    en_i <= 1'b1;
                    rdy <= 0;
                end
            end

            INIT: begin
                en_i <= 0;
                state <= WAIT_INIT;
            end

            WAIT_INIT: begin
                if(rdy_i) begin
                    en_k <= 1;
                    state <= KSA;
                end
            end

            KSA: begin
                en_k <= 0;
                state <= WAIT_KSA;
            end

            WAIT_KSA: begin
                if(rdy_k) begin
                    en_p <= 1;
                    state <= PRGA;
                end
            end

            PRGA: begin
                en_p <= 0;
                state <= WAIT_PRGA;
            end

            WAIT_PRGA: begin
                if(rdy_p) begin
                    rdy <= 1;
                    state <= IDLE;
                end
            end

        default: begin
            state <= IDLE;
        end
    endcase
    end
end

always_comb begin
    
    case(state)
        INIT: begin
            addr <= addr_i; 
            wrdata <= wrdata_i;
            wren <= wren_i;   
            rddata <= 8'b0;
        end
        
        WAIT_INIT: begin
            addr <= addr_i; 
            wrdata <= wrdata_i;
            wren <= wren_i;   
            rddata <= 8'b0;
        end

        KSA: begin
            addr <= addr_k;
            wrdata <= wrdata_k;
            wren <= wren_k;
        end
        
        WAIT_KSA: begin
            addr <= addr_k;
            wrdata <= wrdata_k;
            wren <= wren_k;
        end

        PRGA: begin
            addr <= s_addr;
            wrdata <= s_wrdata;
            wren <= s_wren;
        end

        WAIT_PRGA: begin
            addr <= s_addr;
            wrdata <= s_wrdata;
            wren <= s_wren;
        end

        default: begin
            addr <= addr_i; 
            wrdata <= wrdata_i;
            wren <= wren_i;   
            rddata <= 8'b0;
        end

    endcase
end
endmodule: arc4
