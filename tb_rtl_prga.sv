`timescale 1ps/1ps
module tb_rtl_prga();

    logic clk, rst_n, en, rdy;
    logic [23:0] key;
    logic [7:0] s_addr, s_rddata, s_wrdata;
    logic s_wren;
    logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;
    logic pt_wren;

    prga DUT(.*);

    always #5 clk = ~clk;

    always begin
        clk = 0;
        rst_n = 0;
        #10;
        rst_n = 1;
        ct_rddata = 49;
        #20;
        en = 1;
        #20;
        en = 0;
        #4000;
        wait(DUT.rdy == 1);
        #50; //see if anything happens after

        $stop;
    end

endmodule: tb_rtl_prga
