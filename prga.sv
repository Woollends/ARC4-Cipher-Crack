module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
 /*i = 0, j = 0
message_length = ciphertext[0]
for k = 1 to message_length:
    i = (i+1) mod 256
    j = (j+s[i]) mod 256
    swap values of s[i] and s[j]
    pad[k] = s[(s[i]+s[j]) mod 256]

plaintext[0] = message_length
for k = 1 to message_length:
    plaintext[k] = pad[k] xor ciphertext[k]  -- xor each byte of the ciphertext with the corresponding byte of the pad to get the plaintext
*/

//27605 ns
//26875 ps
//26865 ps
//26135 ps
//24675 ps
//23945 ps
    logic [7:0] i, j, message_length, si, sj, k;

    enum { IDLE, STARTER, WAIT_M, M_LENGTH,ADD_I,SET_I,WAIT_I,ADD_J,SET_J,
           WAIT_J,WRITE_I_TO_J,WRITE_I,WRITE_J_TO_I,WRITE_J,WRITE_PAD,
           WAIT_PAD, SECOND_STARTER, PT_ADD, PT_MLENGTH, PT_WAIT, PT_WRITE, WAITTEST, WAITER, WAIT_M_1} state;
    
    always_ff @ (posedge clk)begin
        if(~rst_n)begin
            i <= 8'd1;
            j <= 8'd0;
            k <= 8'd0;
            rdy <= 1'b1;
            s_wren <= 1'b0;
            s_wrdata <= 8'd0;
            s_addr <= 8'd0;
            ct_addr <= 8'd0;
            pt_addr <= 8'd0;
            pt_wrdata <= 8'd0;
            pt_wren <= 1'b0;
            state <= IDLE;
        end else begin
            case(state)   
                IDLE: begin
                    if(en && rdy)begin
                        state <= WAIT_M;
                        rdy <= 1'b0;
                        i <= 8'd1;
                        j <= 8'd0;
                        s_addr <= 1;
                        ct_addr <= 0;
                        pt_addr <= 0;
                        s_wren = 1'b0;
                    end else if(en && ~rdy)begin                            
                        state <= IDLE;
                    end else if(~en)begin
                        state <= IDLE;
                        rdy <= 1'b1;
                    end
                end

           /*     STARTER: begin //state to incriment I and assign adresses
                    
                    //i <= i + 1;
                    
                    
                    state <= WAIT_M;
                end
*/
                WAIT_M: begin //state to wait for message length
       //             message_length <= ct_rddata;
                    state <= WAIT_M_1;
                end

		WAIT_M_1: begin //state to wait for message length
       //             message_length <= ct_rddata;
                    state <= M_LENGTH;
                end

                M_LENGTH: begin //state to ensure message length and si update
                    message_length <= ct_rddata;
                    pt_wrdata <= ct_rddata;
                    pt_wren <= 1'b1;
                    state <= ADD_I;
                end

                ADD_I: begin //state to add i and si
                    k <= k + 1'b1;
                    pt_wren <= 1'b0;
                    if(k < message_length)begin
                        state <= WAIT_I;
                        s_addr <= i;

                    end else begin
                        state <= IDLE;
                        rdy <= 1'b1;
                    end
                end

         /*       SET_I: begin //state to set i
                   // si <= s_rddata;
                    state <= WAIT_I;
                end
        */
                WAIT_I: begin //state to wait for i
                    si <= s_rddata;
                    state <= SET_J;
                    j <= (j+s_rddata)%256;
                    s_addr <= (j+s_rddata)%256;
                end

          /*      ADD_J: begin //state to add j and si
                    j<= (j + si) % 256;
                    state <= SET_J;
                    s_addr <= j+si;
                end
*/
                SET_J: begin //state to set j
                    state <= WAIT_J;
                end

                WAIT_J: begin //state to wait for j
                    sj <= s_rddata;
                    state <= WRITE_J_TO_I;
                    s_wren <= 1'b1;
                    s_wrdata <= si;
                end

          /*      WRITE_I_TO_J: begin //state to write i to j
                    
                    state <= WRITE_I;
                end

                WRITE_I: begin //state to write i
                    s_wren <= 1'b1;
                    state <= WRITE_J_TO_I;
                end
*/
                WRITE_J_TO_I: begin //state to write j to i
                    s_wren <= 1'b1;
                    s_addr <= i;
                    s_wrdata <= sj;
                    state <= WRITE_PAD;
                    pt_addr <= k;
                    ct_addr <= k;
                end

         /*       WRITE_J: begin //state to write j
                    s_wren <= 1'b1;
                    state <= WRITE_PAD;
                    
                end
*/
                WRITE_PAD: begin //state to write pad
                    s_addr <= (si + sj) % 256;
                    state <= WAITTEST;
                    s_wren <= 1'b0;
                    
                    pt_wren <= 1'b0;
                end

                WAITTEST: begin
                    state <= WAIT_PAD;
                  
                end

                WAIT_PAD: begin //state to wait for pad
                    pt_wrdata <= s_rddata ^ ct_rddata;
                    state <= ADD_I;
                    i <= (i + 1) % 256;
                    s_addr <= (i + 1) % 256;
                    pt_wren <= 1'b1;
                end

        

                default: begin
                    rdy <= 1'b0;
                    state <= IDLE;
                end

            endcase
        end
    end
 endmodule: prga