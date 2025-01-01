`timescale 1ps/1ps
module tb_rtl_doublecrack();
logic clk;
logic rst_n;
logic en;
logic rdy;
logic [23:0] key;
logic key_valid;
logic [7:0] ct_addr;
logic [7:0] ct_rddata;

// Your testbench goes here.

doublecrack dut(.*);

always #5 clk = ~clk;

always begin
    clk = 0;
    rst_n = 0;
    ct_rddata = 10;
    en = 0;
    #20;
    rst_n = 1;
    #10;
    en = 1;
    #1000;
    en = 0;
    wait(rdy);
    
    $display("Doublecrack process complete.");
    $stop;
end

endmodule: tb_rtl_doublecrack
