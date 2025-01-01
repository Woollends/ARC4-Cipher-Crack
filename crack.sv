module crack(input logic clk, input logic rst_n, input logic both_rdy,
             input logic en, input logic start_val, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
             output logic in_fail, output logic [7:0] pt_wrdata, 
             output logic pt_wren, output logic [7:0] pt_addr, input logic run_mem
         /* any other ports you need to add */);

    // For Task 5, you may modify the crack port list above,
    // but ONLY by adding new ports. All predefined ports must be identical.

    // this memory must have the length-prefixed plaintext if key_valid
    logic rst_a, en_a, rdy_a;
    logic [7:0] pt_rddata;
    logic [7:0] i;
    logic [7:0] pt_addr_1;
    logic [7:0] pt_wrdata_1;
    logic [7:0] pt_addr_2;
    logic pt_wrden_2;
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);
    arc4 a4(clk, rst_a, en_a, rdy_a, key, ct_addr, ct_rddata, pt_addr_1, pt_rddata, pt_wrdata_1, pt_wren_1);

    enum{IDLE, READY, CRACK, WAIT_CRACK, ADD_KEY, SOLVED, MEM_1, LOAD_MEM, RW_MEM, WAIT_MEM} state;

    always_ff@(posedge clk) begin
        if(~rst_n) begin
            rst_a <= 0;
            //key <= 24'b000111100100010111111101;
	        key <= start_val; // start val, 1 or 0 for new crack
            en_a <= 0;
            key_valid <= 0;
            rdy <= 1;
            in_fail <= 0;
            state <= IDLE;
            pt_wrden_2 <= 0;
        end else case(state)

            IDLE: begin
                if(en) begin
                    state <= READY;
                end
            end

            READY: begin
                if(both_rdy) begin //if both cracks are ready (both in_fails are 1) we can start next key
                    rst_a <= 1;
                    if(rdy_a && ~key_valid) begin
                        en_a <= 1;
                        state <= CRACK;
                        rdy <= 0;
                    end
                end
            end

            CRACK: begin
                en_a <= 0;
                in_fail <= 0;
                state <= WAIT_CRACK;
            end

            WAIT_CRACK: begin
                if(((pt_wrdata < 8'h20) ||  (pt_wrdata > 8'h7E)) && pt_wren) begin
                    state <= READY;
                    key <= key + 2; //key + 2 for new crack
                    in_fail <= 1; //let other crack know this one has failed
                    rst_a <= 0;
                end else if (rdy_a) begin
                    state <= SOLVED;
                end
            end

            SOLVED: begin
                key_valid <= 1;
                state <= LOAD_MEM;
                
            end

            LOAD_MEM: begin

                if(run_mem) begin
                    state <= WAIT_MEM;
                    i<=0;
                    pt_addr_2 <= 0;
                end

            end

            MEM_1: begin
                if(i <= 255) begin
                    i <= i + 1;
                    state <= WAIT_MEM;
                    pt_addr_2 <= i + 1;
                    pt_wrden_2 <= 0;
                end else begin
                    rdy <= 1;
                end
            end

            WAIT_MEM: begin
                state <= RW_MEM;
            end

            RW_MEM: begin
                state <= MEM_1;
                pt_wrden_2 <= 1;
            end
     


        endcase
    
    
    
    end

always_comb begin

    if(run_mem) begin
        pt_addr <= pt_addr_2;
        pt_wrdata <= pt_rddata;
        pt_wren <= pt_wrden_2;
    end else begin
        pt_addr <= pt_addr_1;
        pt_wrdata <= pt_wrdata_1;
        pt_wren <= pt_wren_1;
    end
end



    // your code here

endmodule: crack
