/*j = 0
for i = 0 to 255:
    j = (j + s[i] + key[i mod keylength]) mod 256   -- for us, keylength is 3
    swap values of s[i] and s[j]
*/

module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);



//s_mem s(addr, clk, wrdata, wren, q); //should q be wrdata too??

    // your code here
enum { IDLE,STARTER, READI, READJ, WRITEI, WRITEJ, LOADI, LOADJ, READ1, READ2, READ3 }state;

logic [7:0] i, j, si, sj, key_part;

always_ff @( posedge clk ) begin
    
    if(~rst_n)begin
        i <= 8'd0;
        j <= 8'd0;
        rdy <= 1'b0;
        wren <= 1'b0;
        wrdata <= 8'd0;
        addr <= 8'd0;
        state <= IDLE;
    end else begin

        case(state)

            IDLE: begin //take first reading of S[i]
                if(en && rdy) begin
                    state<=STARTER;
                    rdy<=1'b0;
                    j<=8'd0;
                    i<=8'd0;
                    addr<=8'd0;
                end else if(en && ~rdy) begin
                    state <= IDLE;
                end else if(~en) begin
                    state <= IDLE;
                    rdy <= 1'b1;
                end
            end

            STARTER: begin //take first reading of S[i]
                
                    addr<=i;
                    state<=READI;
                    wren<=1'b0;

            end

       /*     READ1: begin //take first reading of S[i]
                state<=READI;
            end
*/
            READI: begin //calculates values for j
                si<=rddata;
                j<=(j+rddata+key_part) % 256;
                addr<=(j+rddata+key_part) % 256;
                state <= READ3;
                wren<=1'b0;
            end

      /*      READ2: begin //take first reading of S[i]
                state<=READ3;
                addr<=j;
            end
*/
            READ3: begin //take first reading of S[i] //fit a write in here
                state<=READJ;
                wrdata<=si;
                wren<=1'b1;
                addr<=j;
            end

            READJ: begin //write to s[j] with the values of si //write second state, and get of
                sj<=rddata;
                wren<=1'b1;
                state<=WRITEI;
                wrdata<=rddata;
                addr<=i;
            end

     /*       LOADJ: begin
                wren<=1'b1;
                state<=WRITEJ;
            end
*/
  /*          WRITEJ: begin
                wren<=1'b1;

                state<=WRITEI;
            end
*/
       /*     LOADI: begin
                wren<=1'b1;
                state<=WRITEI;
            end
*/
            WRITEI: begin
                wren<=1'b0;
                if(i<=254)begin
                i<=i+1'b1;
                addr<=i+1'b1;
                state<=STARTER;
                end else begin
                state<=IDLE;
                rdy<=1'b1;
                end
            end
        
        default: state<=IDLE;
        endcase
    end



end

always @(*) begin
    case (i % 3)
       0:  key_part = key[23:16];  // Access the most significant 8 bits
       1:  key_part = key[15:8];   // Access the middle 8 bits
       2:  key_part = key[7:0];    // Access the least significant 8 bits
        default: key_part = 8'b0;  // Default case (shouldn't happen, but safe fallback)
    endcase
end

endmodule: ksa
