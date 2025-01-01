module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    // your code here
    logic key_valid_1, key_valid_2;
    logic en_c;
    logic [23:0] key_1, key_2;
    logic [7:0] ct_addr_1, ct_addr_2;
    logic in_fail_1, in_fail_2;
    logic [7:0] pt_addr, pt_addr_1, pt_addr_2;
    logic [7:0] pt_wrdata, pt_wrdata_1, pt_wrdata_2;
    logic pt_wren, pt_wren_1, pt_wren_2;
    logic both_rdy;
    logic rdy_1, rdy_2;
    logic run_mem_1, run_mem_2;
    logic [7:0] pt_rddata;
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);
    // for this task only, you may ADD ports to crack
    crack c1(clk, rst_n, both_rdy, en_c, 1'b0, rdy_1, key_1, key_valid_1, ct_addr_1, ct_rddata, in_fail_1, pt_wrdata_1, pt_wren_1, pt_addr_1, run_mem_1);
    crack c2(clk, rst_n, both_rdy, en_c, 1'b1, rdy_2, key_2, key_valid_2, ct_addr_2, ct_rddata, in_fail_2, pt_wrdata_2, pt_wren_2, pt_addr_2, run_mem_2);

    enum{IDLE, WAIT_TO_START, CRACK, CRACKED_1, CRACKED_2} state;

always_ff @(posedge clk)begin

    if(~rst_n)begin
        en_c <= 0;
        rdy <= 1'b1;
        key_valid <= 0;
        run_mem_1 <= 0;
        run_mem_2 <= 0;
    end else begin
        
        case(state)

        IDLE:begin
            if(en && rdy_1 && rdy_2)begin
                en_c <= 1;
                rdy <= 0;
                state <= WAIT_TO_START;
                both_rdy <= 1;
                pt_wren <= 0;
            end
        end

        WAIT_TO_START: begin
            state <= CRACK;
        end

        CRACK:begin
            en_c <= 0;

            if(key_valid_1 == 1)begin
                key_valid <= key_valid_1;
                state <= CRACKED_1;
                run_mem_1 <= 1;
            end else if (key_valid_2 == 1)begin 
                key_valid <= key_valid_2;
                state <= CRACKED_2;
                run_mem_2 <= 1; 
            end else if (in_fail_1 && in_fail_2)begin
                both_rdy <= 1;
            end else begin
                both_rdy <= 0;
            end
        end

       CRACKED_1:begin
            pt_addr <= pt_addr_1;
            pt_wren <= pt_wren_1;
            pt_wrdata <= pt_wrdata_1;
            key <= key_1;
            if(rdy_1)begin
                state <= IDLE;
            end
       end

       CRACKED_2:begin
            pt_addr <= pt_addr_2;
            pt_wren <= pt_wren_2;
            pt_wrdata <= pt_wrdata_2;
            key <= key_2;
            if(rdy_2)begin
                state <= IDLE;
            end
       end

       default:begin
            state <= IDLE;
         end
         
        endcase
    end
end

always_comb begin

    if(ct_addr_1 == ct_addr_2)begin
        ct_addr = ct_addr_1;
    end else if(ct_addr_1 > ct_addr_2) begin
        ct_addr = ct_addr_1;
    end else begin
        ct_addr = ct_addr_2;
    end
end

    // your code here

endmodule: doublecrack
