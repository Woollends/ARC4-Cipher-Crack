`timescale 1ps / 1ps
module tb_rtl_ksa();
    logic clk;
    logic rst_n;
    logic en;
    logic rdy;
    logic [23:0] key;
    logic [7:0] addr;
    logic [7:0] rddata;
    logic [7:0] wrdata;
    logic wren;

    // Some selected S values to test
    logic [7:0] S_mem [0:5]; // A smaller memory for testing purposes

    // Instantiate the Unit Under Test (UUT)
    ksa uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .en(en), 
        .rdy(rdy), 
        .key(key), 
        .addr(addr), 
        .rddata(rddata), 
        .wrdata(wrdata), 
        .wren(wren)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10 time units
    end

    // Initialize control signals and memory
    initial begin
        // Initialize control signals
        rst_n = 0;
        en = 0;
        key = 24'h00033C; // Example key from your problem statement
        #10;

        // Initialize memory S with selected values for testing
        S_mem[0] = 8'h00;
        S_mem[1] = 8'h01;
        S_mem[2] = 8'h02;
        S_mem[3] = 8'h03;
        S_mem[4] = 8'h04;
        S_mem[5] = 8'h05;
        
        rst_n = 1; // Release reset
        #10;
        
        en = 1; // Start the KSA
        #100;
          en = 0;
        wait (rdy); // Wait for KSA to complete
        
        
        $display("KSA process complete.");
        $stop;
    end

endmodule        
