module task5(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

   
    logic clk, rst_n, en, rdy, pt_wren;
    logic done;
    logic [23:0] key;
    logic key_valid;
    logic [7:0] wrdata, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;

    logic [3:0] out0, out1, out2, out3, out4, out5;

    assign clk = CLOCK_50;
    assign rst_n = KEY[3];

    ct_mem ct(ct_addr, clk, wrdata, wren, ct_rddata);
    doublecrack dc(.*);

    enum{IDLE, CRACK, CRACK_WAIT} state;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            state <= IDLE;
            en <= 0;
        end else case(state)
            IDLE: begin
                if (rdy && ~KEY[0] && KEY[3]) begin
                    en <= 1;
                    state <= CRACK;
                end
            end

            CRACK: begin
                en <= 0;
                state <= CRACK_WAIT;
            end

            CRACK_WAIT: begin
                if(rdy) begin
                    state <= IDLE;
                end
            end

        endcase

    end

    hex_display h0(out0, key_valid, HEX0);
    hex_display h1(out1, key_valid, HEX1);
    hex_display h2(out2, key_valid, HEX2);
    hex_display h3(out3, key_valid, HEX3);
    hex_display h4(out4, key_valid, HEX4);
    hex_display h5(out5, key_valid, HEX5);


always_comb begin

    if (key_valid)begin
        out0 <= key[3:0];
        out1 <= key[7:4];
        out2 <= key[11:8];
        out3 <= key[15:12];
        out4 <= key[19:16];
        out5 <= key[23:20];
    end else begin  
        out0 <= 4'bx;
        out1 <= 4'bx;
        out2 <= 4'bx;
        out3 <= 4'bx;
        out4 <= 4'bx;
        out5 <= 4'bx;
    end

    
end

    // your code here

endmodule: task5

module hex_display (
    input logic [3:0] bin, // 4-bit input
    input key_valid,
    output logic [6:0] seg // 7-segment display output
);

    always_comb begin
        if (key_valid) begin
        case (bin)
            4'h0: seg = 7'b1000000; // Display 0
            4'h1: seg = 7'b1111001; // Display 1
            4'h2: seg = 7'b0100100; // Display 2
            4'h3: seg = 7'b0110000; // Display 3
            4'h4: seg = 7'b0011001; // Display 4
            4'h5: seg = 7'b0010010; // Display 5
            4'h6: seg = 7'b0000010; // Display 6
            4'h7: seg = 7'b1111000; // Display 7
            4'h8: seg = 7'b0000000; // Display 8
            4'h9: seg = 7'b0011000; // Display 9
            4'hA: seg = 7'b0001000; // Display A
            4'hB: seg = 7'b0000011; // Display B
            4'hC: seg = 7'b1000110; // Display C
            4'hD: seg = 7'b0100001; // Display D
            4'hE: seg = 7'b0000110; // Display E
            4'hF: seg = 7'b0001110; // Display F
        endcase
        end else begin
            seg = 7'b1111111;
        end
    end
endmodule
